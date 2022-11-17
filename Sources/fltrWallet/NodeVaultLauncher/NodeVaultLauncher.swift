//===----------------------------------------------------------------------===//
//
// This source file is part of the fltrWallet open source project
//
// Copyright (c) 2022 fltrWallet AG and the fltrWallet project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
import Dispatch
import fltrBtc
import Foundation
import NIOCore
import NIOPosix
import NIOConcurrencyHelpers
import NIOTransportServices

public class NodeVaultLauncher: NodeVaultProxy {
    let lock: NIOConcurrencyHelpers.NIOLock = .init()
    internal var state: State = .initialized
    var txHandler: ((Tx.AnyTransaction) -> EventLoopFuture<Void>)!
    var eventHandler: ((WalletEvent) -> EventLoopFuture<Void>)!
    
    public init() {}
}

extension NodeVaultLauncher {
    struct StartedState {
        let node: Node
        let vault: Vault.Clerk
        let model: ViewModel
        let elg: NIOTSEventLoopGroup
        let eventLoop: EventLoop
        let threadPool: NIOThreadPool
        
        init(suspended state: SuspendedState, node: Node) {
            self.vault = state.vault
            self.model = state.model
            self.elg = state.elg
            self.eventLoop = state.eventLoop
            self.threadPool = state.threadPool
            self.node = node
        }
    }
    
    struct SuspendedState {
        let vault: Vault.Clerk
        let model: ViewModel
        let elg: NIOTSEventLoopGroup
        let eventLoop: EventLoop
        let threadPool: NIOThreadPool
        
        init(vault: Vault.Clerk,
             model: ViewModel,
             elg: NIOTSEventLoopGroup,
             eventLoop: EventLoop,
             threadPool: NIOThreadPool) {
            self.vault = vault
            self.model = model
            self.elg = elg
            self.eventLoop = eventLoop
            self.threadPool = threadPool
        }

        init(_ startedState: StartedState) {
            self.vault = startedState.vault
            self.model = startedState.model
            self.elg = startedState.elg
            self.eventLoop = startedState.eventLoop
            self.threadPool = startedState.threadPool
        }
        
        var future: EventLoopFuture<SuspendedState> {
            self.eventLoop.makeSucceededFuture(self)
        }
    }
    
    enum State {
        case initialized
        case started(StartedState)
        case suspended(SuspendedState)
        case failed(Error)
        case stopped
    }
    
    enum IllegalState: Swift.Error, CustomStringConvertible {
        case initialized
        case stopped
        
        var description: String {
            switch self {
            case .initialized:
                return "IllegalState.initialized"
            case .stopped:
                return "IllegalState.stopped"
            }
        }
    }

    func updateModel<T>(keyPath: WritableKeyPath<ViewModel, T>, value: T) throws {
        let state = self.lock.withLock { self.state }
        var model: ViewModel = try {
            switch state {
            case .started(let state):
                return state.model
            case .suspended(let state):
                return state.model
            case .failed(let error):
                preconditionFailure("\(error)")
            case .initialized:
                throw IllegalState.initialized
            case .stopped:
                throw IllegalState.stopped
            }
        }()
            
        DispatchQueue.main.async {
            model[keyPath: keyPath] = value
        }
    }
    
    func walletDependencies() -> (NIOTSEventLoopGroup, EventLoop, NIOThreadPool) {
        let elg = NIOTSEventLoopGroup(loopCount: 1)
        let eventLoop = elg.next()
        let threadPool = NIOThreadPool(numberOfThreads: Settings.numberOfThreads)
        threadPool.start()
        return (elg, eventLoop, threadPool)
    }
    
    func removeCoinFiles() {
        try? FileManager.default.removeItem(
            atPath: Vault.pathString(from: GlobalFltrWalletSettings.CoinRepoFileName + ".1",
                                      in: GlobalFltrWalletSettings.DataFileDirectory))
        try? FileManager.default.removeItem(
            atPath: Vault.pathString(from: GlobalFltrWalletSettings.CoinRepoFileName + ".2",
                                      in: GlobalFltrWalletSettings.DataFileDirectory))
        
        HD.Source.allCases.compactMap {
            $0.fileName
        }
        .forEach {
            try? FileManager.default.removeItem(
                atPath: Vault.pathString(from: $0,
                                          in: GlobalFltrWalletSettings.DataFileDirectory))
        }
    }

    public func newWallet(year: Load.ChainYear, callback: @escaping (Result<[String], Swift.Error>) -> Void) {
        self.firstRun(mode: .new, year: year, callback: callback)
    }
    
    public func recoverWallet(entropy bytes: [UInt8],
                              year: Load.ChainYear,
                              callback: @escaping (Result<[String], Swift.Error>) -> Void) {
        self.firstRun(mode: .recover(bytes), year: year, callback: callback)
    }
    
    enum FirstRunMode {
        case recover([UInt8])
        case new
        
        var isNew: Bool {
            switch self {
            case .new: return true
            case .recover: return false
            }
        }
        
        var bytes: [UInt8]? {
            switch self {
            case .recover(let bytes): return bytes
            case .new: return nil
            }
        }
        
    }
    
    private func firstRun(mode: FirstRunMode,
                          year: Load.ChainYear,
                          callback: @escaping (Result<[String], Swift.Error>) -> Void) {
        try! AppStarter.prepare(new: mode.isNew, year: year)
        self.removeCoinFiles()

        let (elg, eventLoop, threadPool) = self.walletDependencies()
        let properties = GlobalFltrWalletSettings.WalletPropertiesFactory(eventLoop, threadPool)
        properties.reset()
        
        return Vault.initializeAll(eventLoop: eventLoop,
                                   threadPool: threadPool,
                                   fileIO: GlobalFltrWalletSettings.NonBlockingFileIOClientFactory(threadPool),
                                   entropy: mode.bytes)
        .recover {
            preconditionFailure("\($0)")
        }
        .map {
            $0.words
        }
        .whenComplete { result in
            func closeAll(callback: @escaping () -> Void) {
                threadPool.shutdownGracefully { _ in
                    elg.shutdownGracefully { _ in
                        callback()
                    }
                }
            }

            closeAll {
                switch result {
                case .success(let result):
                    callback(.success(result))
                case .failure(let error):
                    callback(.failure(error))
                }
            }
        }
    }
}

extension NodeVaultLauncher {
    @usableFromInline
    func estimatedHeight(callback: @escaping (Int?) -> Void) {
        let state = self.lock.withLock { self.state }
        switch state {
        case .started(let startedState):
            switch (startedState.model.tip, startedState.model.estimatedHeight) {
            case (-1, -1):
                callback(nil)
            case (let lhs, let rhs) where lhs < rhs:
                callback(rhs)
            case (let lhs, _):
                callback(lhs)
            }
        case .suspended(let suspendedState):
            callback(
                suspendedState.model.estimatedHeight == -1
                    ? nil
                    : suspendedState.model.estimatedHeight
            )
        case .failed, .initialized, .stopped:
            callback(nil)
        }
    }

    var node: Node? {
        let state = self.lock.withLock { self.state }
        switch state {
        case .started(let state):
            return state.node
        case .failed, .initialized, .stopped, .suspended:
            return nil
        }
    }

    @usableFromInline
    var vault: Vault.Clerk? {
        let state = self.lock.withLock { self.state }
        switch state {
        case .started(let state):
            return state.vault
        case .suspended(let state):
            return state.vault
        case .failed, .initialized, .stopped:
            return nil
        }
    }
}

public extension NodeVaultLauncher {
    @inlinable
    var selectableYears: SelectableYears {
        switch GlobalFltrWalletSettings.Network {
        case .main: return .main
        case .testnet: return .testnet
        }
    }
    
}

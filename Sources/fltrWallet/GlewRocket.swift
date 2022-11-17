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
import BackgroundTasks
import fltrBtc
import Combine
import Dispatch
import LoadNode
import SwiftUI

fileprivate func isMain() {
    dispatchPrecondition(condition: .onQueue(.main))
}

public final class GlewRocket<Model: ViewModel & ObservableObject> {
    var callbacks: [() -> Void] = []
    var state = State.reset
    let launcherClientFactory: () -> NodeVaultProxy
    var cancellable: AnyCancellable?
    
    public init(launcher: @escaping () -> NodeVaultProxy) {
        self.launcherClientFactory = launcher
    }
}

extension GlewRocket {
    enum State {
        case reset
        case starting(NodeVaultProxy, Model)
        case stopRequestWhileStarting(NodeVaultProxy, Model)
        case running(NodeVaultProxy, Model)
        case stopping(NodeVaultProxy, Model)
        case startRequestWhileStopping(NodeVaultProxy, Model)
        
        var nodeVault: NodeVaultProxy? {
            self.checkRunning()?.0
        }
        
        var model: Model? {
            self.checkRunning()?.1
        }
        
        private func checkRunning() -> (NodeVaultProxy, Model)? {
            switch self {
            case .starting(let nodeVault, let model),
                 .stopRequestWhileStarting(let nodeVault, let model),
                 .running(let nodeVault, let model),
                 .stopping(let nodeVault, let model),
                 .startRequestWhileStopping(let nodeVault, let model):
                return (nodeVault, model)
            case .reset:
                return nil
            }
        }
    }
    
    func evaluateAfterStart() {
        switch self.state {
        case .starting(let launcher, let model):
            self.state = .running(launcher, model)
        case .stopRequestWhileStarting(let launcher, let model):
            self.state = .running(launcher, model)
            
            self.stop()
        case .reset, .running, .startRequestWhileStopping, .stopping:
            preconditionFailure()
        }
    }
    
    func evaluateAfterStop() {
        switch self.state {
        case .startRequestWhileStopping(_, let model):
            self.state = .reset
            self.start(model)
        case .stopping:
            self.state = .reset
        case .reset, .running, .starting, .stopRequestWhileStarting:
            preconditionFailure()
        }
        
        let copy = self.callbacks
        self.callbacks.removeAll()
        copy.forEach {
            $0()
        }
    }
}

public extension GlewRocket {
    #if !os(macOS)
    func background(_ model: Model, task: BGProcessingTask) {
        func isStopped() -> Bool {
            switch self.state {
            case .reset:
                return true
            case .running, .startRequestWhileStopping, .starting, .stopRequestWhileStarting, .stopping:
                return false
            }
        }

        guard self.cancellable == nil,
              isStopped()
        else {
            task.setTaskCompleted(success: false)
            return
        }
        
        
        func backgroundStop() {
            self.stop { [weak self] in
                if let self = self {
                    DispatchQueue.main.async {
                        self.cancellable = nil
                        model.background = false
                    }
                }

                // TODO: Remove delay
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                    task.setTaskCompleted(success: true)
                }
            }
        }
        
        task.expirationHandler = {
            DispatchQueue.main.async {
                backgroundStop()
            }
        }

        self.start(model)
        self.cancellable = model.synchedPublisher.sink { value in
            if value {
                backgroundStop()
            }
        }
    }
    #endif
    
    func start(_ model: Model) {
        isMain()
        
        switch self.state {
        case .reset:
            let launcher = self.launcherClientFactory()
            defer {
                launcher.start(model: model) {
                    switch $0 {
                    case .success:
                        DispatchQueue.main.async {
                            self.evaluateAfterStart()
                        }

                    case .failure(let error):
                        logger.error("Cannot launch GlewRocket from start due to error \(error)")
                        preconditionFailure()
                    }
                }
            }
            self.state = .starting(launcher, model)
        case .stopRequestWhileStarting(let launcher, let model):
            self.state = .starting(launcher, model)
        case .stopping(let launcher, let model):
            self.state = .startRequestWhileStopping(launcher, model)
        case .running, .starting, .startRequestWhileStopping:
            break
        }
    }
    
    func stop(optional callback: (() -> Void)? = nil) {
        isMain()
        
        func appendCallback() {
            if let callback = callback {
                self.callbacks.append(callback)
            }
        }
        
        switch self.state {
        case .running(let launcher, let model):
            appendCallback()
            defer {
                launcher.stop {
                    DispatchQueue.main.async {
                        self.evaluateAfterStop()
                    }
                }
            }
            self.state = .stopping(launcher, model)
        case .startRequestWhileStopping(let launcher, let model):
            appendCallback()
            self.state = .stopping(launcher, model)
        case .starting(let launcher, let model):
            appendCallback()
            self.state = .stopRequestWhileStarting(launcher, model)
        case .stopping, .stopRequestWhileStarting:
            appendCallback()
        case .reset:
            callback?()
        }
    }
    
    func firstRun(entropy: [UInt8]?, year: Load.ChainYear = Load.years().last!, callback: @escaping (Result<[String], Swift.Error>) -> Void) {
        isMain()
        
        switch self.state {
        case .reset:
            let launcher = self.launcherClientFactory()
            if let entropy = entropy {
                launcher.recoverWallet(entropy: entropy, year: year, callback: callback)
            } else {
                launcher.newWallet(year: year, callback: callback)
            }
        case .running, .startRequestWhileStopping, .starting,
             .stopRequestWhileStarting, .stopping:
            self.stop {
                DispatchQueue.main.async {
                    self.firstRun(entropy: entropy, year: year, callback: callback)
                }
            }
        }
    }
    
    func fees<Trigger: Publisher>(trigger: Trigger) -> AnyPublisher<Result<FeeEstimate, VaultApiError>, Never>
    where Trigger.Output == Void, Trigger.Failure == Never {
        guard let nodeVault = self.state.nodeVault
        else {
            return Just(.failure(.unavailable)).eraseToAnyPublisher()
        }
        
        return nodeVault.fees(trigger: trigger)
    }
    
    func loadLatestAddress(for repo: HD.Source) -> AnyPublisher<(display: String, encode: String)?, Never> {
        isMain()
        
        guard let nodeVault = self.state.nodeVault
        else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        return Deferred {
            Combine.Future { promise in
                nodeVault.loadLatestAddress(for: repo) { result in
                    promise(
                        result
                            .map(String?.init)
                            .flatMapError({ _ in .success(nil) })
                            .map {
                                switch repo {
                                case .legacySegwit:
                                    return $0.map { ($0, $0) }
                                case .segwit, .taproot:
                                    return $0.map { ($0, $0.uppercased()) }
                                case .legacy0, .legacy0Change,
                                        .legacy44, .legacy44Change,
                                        .legacySegwitChange,
                                        .segwit0, .segwit0Change,
                                        .segwitChange,
                                        .taprootChange:
                                    preconditionFailure()
                                }
                            }
                    )
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func loadLatestAddress(for repo: HD.Source,
                           callback: @escaping (Result<String, Swift.Error>) -> Void) {
        isMain()
        
        guard let nodeVault = self.state.nodeVault
        else {
            return callback(.failure(ServiceUnavailable()))
        }
        
        nodeVault.loadLatestAddress(for: repo) { result in
            callback(result)
        }
    }
    
    func pay(amount: UInt64,
             to address: AddressDecoder,
             cost rate: Double,
             callback: @escaping (Result<Void, Swift.Error>) -> Void) {
        isMain()
        
        guard let nodeVault = self.state.nodeVault
        else {
            return callback(.failure(ServiceUnavailable()))
        }

        nodeVault.pay(amount: amount,
                      to: address,
                      cost: rate) {
            callback($0)
        }
    }
    
    func estimateCost(amount: UInt64,
                      to address: AddressDecoder,
                      costRate: Double)
    -> AnyPublisher<UInt64, Swift.Error> {
        isMain()
        
        return Deferred {
            Combine.Future { promise in
                guard let nodeVault = self.state.nodeVault
                else {
                    return promise(.failure(ServiceUnavailable()))
                }
                
                nodeVault.estimateCost(amount: amount,
                                       to: address,
                                       costRate: costRate,
                                       callback: promise)
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    enum PrivateKeyError: Swift.Error {
        case serviceUnavailable
        case internalError(Swift.Error)
        
        init(_ error: Swift.Error) {
            switch error {
            case is ServiceUnavailable:
                self = .serviceUnavailable
            default:
                self = .internalError(error)
            }
        }
    }
    
    func loadPrivateKey() -> AnyPublisher<Vault.WalletSeedCodable, PrivateKeyError> {
        isMain()
        
        return Deferred {
            Combine.Future { promise in
                guard let nodeVault = self.state.nodeVault
                else {
                    return promise(.failure(.serviceUnavailable))
                }
                
                nodeVault.loadPrivateKey { result in
                    promise(result.mapError(PrivateKeyError.init))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    enum TransactionsError: Swift.Error {
        case serviceUnavailable
        case internalError(Swift.Error)
        
        init(_ error: Swift.Error) {
            switch error {
            case is ServiceUnavailable:
                self = .serviceUnavailable
            default:
                self = .internalError(error)
            }
        }
    }
    
    func history() -> AnyPublisher<(History, [Int : UInt32]), VaultApiError> {
        isMain()
        
        return Deferred {
            Combine.Future { promise in
                guard let nodeVault = self.state.nodeVault
                else {
                    return promise(.failure(.unavailable))
                }
                
                nodeVault.history { result in
                    promise(result.mapError(VaultApiError.init))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    enum BIP39DecodeError: Swift.Error {
        case illegalWords
    }
    
    func bip39DecodeAsync(words: [String]) -> AnyPublisher<[UInt8], BIP39DecodeError> {
        isMain()
        
        return Deferred {
            Combine.Future { promise in
                guard let decode = self.bip39Decode(words: words)
                else {
                    return promise(.failure(.illegalWords))
                }
                
                return promise(.success(decode))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func bip39Decode(words: [String]) -> [UInt8]? {
        BIP39.Language.english.entropyBytes(from: words)
    }
    
    
    func isValid(_ word: String) -> AnyPublisher<(Bool, String?), BIP39DecodeError> {
        if let match = BIP39.Language.english.words(for: word).first {
            let exact = match == word
            return Just((exact, match))
                .setFailureType(to: BIP39DecodeError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: BIP39DecodeError.illegalWords)
                .eraseToAnyPublisher()
        }
    }
    
    func validate(_ word: String) -> [String] {
        BIP39.Language.english.words(for: word)
    }
}

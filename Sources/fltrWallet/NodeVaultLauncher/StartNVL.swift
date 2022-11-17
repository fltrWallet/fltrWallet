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
import NIO

extension NodeVaultLauncher {
    public func start(model: ViewModel, callback: @escaping (Result<Void, Swift.Error>) -> Void) {
        self.start(model: model)
        .whenComplete { result in
            callback(result)
        }
    }
    
    func startHelper(suspended state: SuspendedState? = nil, model: ViewModel) -> EventLoopFuture<Void> {
        let suspended: EventLoopFuture<SuspendedState> = state?.future
            ?? {
                let (elg, eventLoop, threadPool) = self.walletDependencies()
                
                let clerkFuture = Vault.Clerk.factory(eventLoop: eventLoop,
                                                      threadPool: threadPool,
                                                      tx: { tx in
                                                        let txHandler = self.lock.withLock { self.txHandler }
                                                        return txHandler!(tx)
                                                      },
                                                      event: { walletEvent in
                                                        let eventHandler = self.lock.withLock { self.eventHandler }
                                                        return eventHandler!(walletEvent)
                                                      })
                return clerkFuture.map {
                    SuspendedState(vault: $0,
                                   model: model,
                                   elg: elg,
                                   eventLoop: eventLoop,
                                   threadPool: threadPool)
                }
            }()
        
        func load(from state: SuspendedState) -> EventLoopFuture<(pubKeys: [ScriptPubKey],
                                                                  available: Tally,
                                                                  pendingReceive: Tally,
                                                                  pendingSpend: Tally)> {
            state.vault.load(properties: GlobalFltrWalletSettings.WalletPropertiesFactory(state.eventLoop,
                                                                                          state.threadPool))
            .flatMap {
                let pubKeysFuture = state.vault.scriptPubKeys()
                let tallyFuture = state.vault.availableCoins()
                
                return pubKeysFuture.and(tallyFuture)
                .map { pubKeys, tally in
                    (pubKeys: pubKeys,
                     available: tally.available,
                     pendingReceive: tally.pendingReceive,
                     pendingSpend: tally.pendingSpend)
                }
                .always {
                    switch $0 {
                    case .success((_, let available, let receive, _)):
                        let active = available.total()
                        DispatchQueue.main.async {
                            state.model.active = active
                            state.model.pending = receive.total()
                        }
                    case .failure(let error):
                        logger.error("NodeVaultLauncher \(#function) - Failure loading "
                                        + "suspended state, properties, pub keys and/or coin tally "
                                        + "with error \(error)")
                        preconditionFailure()
                    }
                }
            }
        }
        
        func createNode(suspended state: SuspendedState,
                        pubKeys: [ScriptPubKey],
                        available tally: Tally) -> EventLoopFuture<Node> {
            let outpoints = tally.map(\.outpoint)
            let node = AppStarter.createNode(threadPool: state.threadPool,
                                             walletDelegate: self)
            
            return node.addScriptPubKeys(pubKeys)
            .flatMap {
                node.addOutpoints(outpoints)
            }
            .map {
                node
            }
        }
        
        func add(pendingSpent coins: Tally, to node: Node) {
            let transactions: [Tx.AnyTransaction] = coins
            .compactMap { coin in
                switch coin.spentState {
                case .pending(let spent):
                    return spent.tx
                case .spent, .unspent:
                    return nil
                }
            }
            transactions.forEach {
                try! node.addTransaction($0)
            }
        }
        
        
        func start(suspended state: SuspendedState,
                   node: Node) -> EventLoopFuture<Void> {
            node.start()
            .hop(to: state.eventLoop)
            .always {
                switch $0 {
                case .success:
                    self.lock.withLockVoid {
                        self.state = .started(StartedState(suspended: state, node: node))

                        self.txHandler = { tx in
                            return node.sendTransaction(tx)
                            .map {
                                logger.trace("NodeVaultLauncher TXHANDLER - Sending transaction with id (\($0))")
                            }
                        }
                        
                        self.eventHandler = { event in
                            state.eventLoop.flatSubmit {
                                NodeVaultLauncher.handleWalletEvent(model: state.model,
                                                                    node: node,
                                                                    vault: state.vault,
                                                                    event: event,
                                                                    eventLoop: state.eventLoop)
                            }
//                            .hop(to: state.eventLoop)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        state.model.running = true
                        state.model.suspended = false
                    }
                case .failure(let error):
                    logger.error("NodeVaultLauncher \(#function) - Failure starting Node: \(error)")
                    preconditionFailure()
                }
            }
        }
        
        return suspended.flatMap { state in
            load(from: state)
            .flatMap { loaded in
                createNode(suspended: state,
                           pubKeys: loaded.pubKeys,
                           available: loaded.available
                           + loaded.pendingReceive
                           + loaded.pendingSpend)
                .flatMap { node in
                    add(pendingSpent: loaded.pendingSpend, to: node)
                    
                    return start(suspended: state, node: node)
                }
            }
        }
    }
    
    internal func start(model: ViewModel) -> EventLoopFuture<Void> {
        let state = self.lock.withLock { self.state }
        switch state {
        case .initialized:
            return self.startHelper(model: model)
        case .suspended(let state):
            return self.startHelper(suspended: state, model: model)
        case .failed(let error):
            preconditionFailure("\(error)")
        case .stopped, .started:
            preconditionFailure()
        }
    }

}

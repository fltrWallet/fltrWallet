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
import NIOTransportServices

extension NodeVaultLauncher {
    func stopHelper(model: ViewModel,
                    elgThreadPool: (NIOTSEventLoopGroup, NIOThreadPool)? = nil,
                    node: Node? = nil,
                    vault: Vault.Clerk? = nil,
                    eventLoop: EventLoop,
                    callback: @escaping () -> Void) {
        struct NotRunning: Swift.Error {}
        
        let nodeStop: EventLoopFuture<Void> = {
            node?.stop()
                ?? eventLoop.makeFailedFuture(NotRunning())
        }()
        .map {
            self.lock.withLockVoid {
                self.txHandler = nil
                self.eventHandler = nil
            }

            DispatchQueue.main.async {
                model.synched = false
                model.suspended = true
                model.tip = -1
            }
        }
        .recover { error in
            guard !(error is NotRunning) else { return }
            
            logger.error("WalletClient \(#function) - Node stop failed with error \(error)")
        }

        let vaultStop: EventLoopFuture<Void> = {
            nodeStop.flatMap {
                vault?.stop()
                    ?? eventLoop.makeFailedFuture(NotRunning())
            }
        }()
        .map {
            logger.info("Vault.Clerk - 💰Stop Successful ✅")
            DispatchQueue.main.async {
                model.running = false
                model.suspended = false
                model.tip = -1
            }
        }
        .recover { error in
            guard !(error is NotRunning) else { return }

            logger.error("WalletClient \(#function) - Vault.Clerk "
                         + "stop failed with error \(error)")
        }
        
        vaultStop.whenComplete {
            switch $0 {
            case .success: break
            case .failure(let error): preconditionFailure("\(error)")
            }
            
            func handleError(errorOptional: Error?, function: StaticString, module: String) {
                if let error = errorOptional {
                    logger.error("WalletClient \(function) - Failed shutdown of \(module) "
                                    + "with error \(error)")
                } else {
                    logger.info("WalletClient - \(module) Stop Successful ✅")
                }
            }

            if let (elg, threadPool) = elgThreadPool {
                threadPool.shutdownGracefully { errorOptional in
                    handleError(errorOptional: errorOptional,
                                function: #function,
                                module: "NIOThreadPool")
                    
                    elg.shutdownGracefully { errorOptional in
                        handleError(errorOptional: errorOptional,
                                    function: #function,
                                    module: "NIOTSEventLoopGroup")
                        callback()
                    }
                }
            } else {
                callback()
            }
        }
    }
    
    public func suspend(callback: @escaping () -> Void) {
        let state = self.lock.withLock { self.state }
        switch state {
        case .started(let state):
            self.stopHelper(model: state.model,
                            elgThreadPool: nil,
                            node: state.node,
                            vault: nil,
                            eventLoop: state.eventLoop) {
                self.lock.withLockVoid {
                    self.state = .suspended(SuspendedState(state))
                }
                callback()
            }
        case .failed(let error):
            logger.error("WalletClient - In error state \(error)")
            callback()
        case .initialized, .stopped, .suspended:
            logger.info("WalletClient - Already suspended")
            callback()
        }
    }
    
    public func stop(callback: @escaping () -> Void) {
        let state = self.lock.withLock { self.state }
        switch state {
        case .started(let state):
            self.stopHelper(model: state.model,
                            elgThreadPool: (state.elg, state.threadPool),
                            node: state.node,
                            vault: state.vault,
                            eventLoop: state.eventLoop) {
                self.lock.withLockVoid {
                    self.state = .stopped
                }
                callback()
            }
        case .suspended(let state):
            self.stopHelper(model: state.model,
                            elgThreadPool: (state.elg, state.threadPool),
                            vault: state.vault,
                            eventLoop: state.eventLoop) {
                self.lock.withLockVoid {
                    self.state = .stopped
                }
                callback()
            }
        case .failed(let error):
            logger.error("WalletClient - Already stopped with error \(error)")
            callback()
        case .initialized, .stopped:
            logger.info("WalletClient - Already stopped")
            callback()
        }
    }
}

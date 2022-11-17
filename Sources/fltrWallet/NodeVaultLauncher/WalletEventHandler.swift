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
    static func handleWalletEvent(model: ViewModel,
                                  node: Node,
                                  vault: Vault.Clerk,
                                  event: WalletEvent,
                                  eventLoop: EventLoop) -> EventLoopFuture<Void> {
        switch event {
        case .scriptPubKey(let newScriptPubKey):
            logger.trace("WalletClient \(#function) - Added new pubkey \(newScriptPubKey)")
            return node.addScriptPubKeys([newScriptPubKey])

        case .tally(let tally):
            _ = tally
            
            switch tally {
            case .receiveUnconfirmed(let value):
                DispatchQueue.main.async {
                    model.pending += value
                    model.coinSound?.play()
                }
            case .receivePromoted(let value):
                DispatchQueue.main.async {
                    precondition(model.pending >= value)
                    model.active += value
                    model.pending -= value
                }
            case .receiveConfirmed(let value):
                DispatchQueue.main.async {
                    model.active += value
                    model.coinSound?.play()
                }
            case .spentUnconfirmed(let value),
                 .spentConfirmed(let value):
                DispatchQueue.main.async {
                    precondition(model.active >= value)
                    model.active -= value
                }
            case .spentPromoted:
                DispatchQueue.main.async {
                    model.active += 0 // trigger update event
                }
            case .rollback:
                return vault.availableCoins()
                .always {
                    switch $0 {
                    case .success((let available, let pendingReceive, let pendingSpend)):
                        let availableTotal = available.total()
                        let pendingReceiveTotal = pendingReceive.total()
                        let pendingSpendTotal = pendingSpend.total()
                        DispatchQueue.main.async {
                            model.active = availableTotal
                            model.pending = pendingReceiveTotal
                        }
                        logger.info("WalletClient \(#function) - Rollback reset tally "
                                    + "available[\(availableTotal)] "
                                    + "pendingReceive[\(pendingReceiveTotal)] "
                                    + "pendingSpend[\(pendingSpendTotal)]")
                    case .failure(let error):
                        logger.error("WalletClient - Update of wallet funds "
                                        + "failed with error \(error)")
                        DispatchQueue.main.async {
                            model.active = 0
                            model.pending = 0
                        }
                    }
                }
                .map { _ in () }
                
            }
        }
        return eventLoop.makeSucceededVoidFuture()
    }
}

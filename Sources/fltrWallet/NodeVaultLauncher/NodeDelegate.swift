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
import fltrBtc
import HaByLo
import fltrNode

extension NodeVaultLauncher: NodeDelegate {
    public func newTip(height: Int, commit: @escaping  () -> Void) {
        logger.info("NodeDelegate \(#function) - new tip received \(height)")
        
        do {
            try self.updateModel(keyPath: \.tip, value: height)
            commit()
        } catch {
            // don't commit
            logger.error("NodeVaultLauncher \(#function) - Cannot update model due to error \(error)")
        }
    }
    
    public func rollback(height: Int, commit: @escaping () -> Void) {
        logger.info("NodeDelegate \(#function) - rollback \(height)")
        self.vault!.rollback(to: height).whenComplete { _ in
            commit()
        }
    }
    
    public func transactions(height: Int, events: [TransactionEvent], commit: @escaping (TransactionEventCommitOutcome) -> Void) {
        func strictOutcome(commitOutcome: inout TransactionEventCommitOutcome,
                           from: TransactionEventCommitOutcome) {
            switch from {
            case .strict:
                logger.info("NodeDelegate \(#function) - .strict outcome (rollback) due to funding transaction event")
                commitOutcome = .strict
            case .relaxed:
                break
            }
        }
        
        var commitOutcome: TransactionEventCommitOutcome = .relaxed
        
        var voidFuture: Future<Void>!
        func enqueue<T>(_ future: @escaping () -> Future<T>) {
            if voidFuture == nil {
                voidFuture = future().map { _ in () }
            } else {
                voidFuture = voidFuture.flatMap { future().map { _ in () } }
            }
        }
        
        for event in events {
            switch event {
            case .new(let funding):
                logger.info("NodeDelegate \(#function) - funding transaction received height \(height) with data \(funding)")
                enqueue {
                    self.vault!.addConfirmed(funding: funding, height: height)
                    .flatMap { outcome in
                        self.node!.addOutpoints([funding.outpoint])
                        .map { outcome }
                    }
                    .map {
                        strictOutcome(commitOutcome: &commitOutcome, from: $0)
                    }
                    .always { result in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            logger.error("NodeDelegate \(#function) - Add Confirmed failed with \(error)")
                            preconditionFailure()
                        }
                    }
                }
            case .spent(let spent):
                let identified = Tx.AnyIdentifiableTransaction(spent.tx)
                logger.info("NodeDelegate \(#function) - spent outpoint \(spent.outpoint) at \(height) with txId \(identified.txId)")
                
                enqueue {
                    self.vault!.spentConfirmed(outpoint: spent.outpoint,
                                               height: height,
                                               changeIndices: spent.changeIndices,
                                               tx: spent.tx)
                    .flatMap {
                        self.node!.removeOutpoint(spent.outpoint)
                    }
                    .always { result in
                        switch result {
                        case .success:
                            if self.node!.removeTransaction(identified.txId) {
                                logger.info("NodeDelegate \(#function) - transaction \(identified.txId) removed from mempool due to transaction confirmation event")
                            }
                        case .failure(let error):
                            logger.error("NodeDelegate \(#function) - Error (\(error)) while processing spent outpoint [\(spent.outpoint)][id:\(identified.txId)]")
                        }
                    }
                }
            }
        }

        voidFuture.whenComplete { _ in
            commit(commitOutcome)
        }
    }
    
    @inlinable // build core 11 without inlinable in release builds
    public func unconfirmedTx(height: Int, events: [TransactionEvent]) {
        logger.info("NodeDelegate \(#function) - unconfirmed events \(events)")
        
        self.estimatedHeight { estimated in
            guard let height = estimated
            else {
                logger.error("WalletClient \(#function) - Cannot get current height for unconfirmed tx")
                return
            }
            
            var voidFuture: Future<Void>!
            func enqueue<T>(_ future: @escaping () -> Future<T>) -> Future<Void> {
                if voidFuture == nil {
                    voidFuture = future().map { _ in () }
                } else {
                    voidFuture = voidFuture.flatMap { future().map { _ in () } }
                }
                
                return voidFuture
            }

            events.forEach {
                switch $0 {
                case .new(let funding):
                    enqueue {
                        self.vault!.addUnconfirmed(funding: funding, height: height)
                    }
                    .whenComplete {
                        switch $0 {
                        case .success:
                            logger.info("WalletClient \(#function) - Received unconfirmed funding transaction \(funding)")
                        case .failure(let error):
                            logger.error("WalletClient \(#function) - Failed add unconfirmed "
                                        + "transaction \(funding) with error \(error)")
                        }
                    }
                case .spent(let spent):
                    enqueue {
                        self.vault!.spentUnconfirmed(outpoint: spent.outpoint,
                                                     height: height,
                                                     changeIndices: spent.changeIndices,
                                                     tx: spent.tx)
                    }
                    .whenComplete {
                        switch $0 {
                        case .success:
                            logger.info("WalletClient \(#function) - Unconfirmed spend of outpoint \(spent.outpoint)")
                        case .failure(let error):
                            logger.error("WalletClient \(#function) - Unconfirmed spend of outpoint "
                                         + "\(spent.outpoint) failed with error \(error)")
                        }
                    }
                }
            }
        }
    }
    
    public func estimatedHeight(_ current: ConsensusChainHeight.CurrentHeight) {
        logger.info("NodeDelegate \(#function) - estimated height \(current)")
        try? self.updateModel(keyPath: \.estimatedHeight, value: current.value)
    }
    
    public func filterEvent(_ filter: CompactFilterEvent) {
        logger.trace("NodeDelegate \(#function) - filter events \(filter)")
        try? self.updateModel(keyPath: \.compactFilterEvent, value: filter)
    }
    
    public func syncEvent(_ event: SyncEvent) {
        switch event {
        case .synched:
            logger.trace("NodeVaultLauncher \(#function) - 🍒🆂🆈🅽🅲🅷🅴🅳🍀")
            try? self.updateModel(keyPath: \.synched, value: true)
        case .tracking:
            logger.trace("NodeVaultLauncher \(#function) - Tracking...")
            try? self.updateModel(keyPath: \.synched, value: false)
        }
    }
}

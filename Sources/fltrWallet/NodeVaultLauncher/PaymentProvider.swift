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
import Dispatch
import NIO

public extension NodeVaultLauncher {
    func estimateCost(amount: UInt64,
                      to address: AddressDecoder,
                      costRate: Double,
                      callback: @escaping (Result<UInt64, Error>) -> Void) {
        guard let vault = self.vault
        else {
            return callback(.failure(ServiceUnavailable()))
        }
        
        vault.estimateCost(amount: amount,
                           to: address,
                           costRate: costRate)
        .whenComplete(callback)
    }
    
    func pay(amount: UInt64, to: AddressDecoder, cost rate: Double, callback: @escaping (Result<Void, Error>) -> Void) {
        guard let vault = self.vault
        else {
            return callback(.failure(ServiceUnavailable()))
        }
        
        self.estimatedHeight { height in
            guard let height = height
            else {
                return callback(.failure(ServiceUnavailable()))
            }
            
            vault.pay(amount: amount, to: to, costRate: rate, height: height)
            .whenComplete { result in
                callback(result)
            }
        }
    }
}

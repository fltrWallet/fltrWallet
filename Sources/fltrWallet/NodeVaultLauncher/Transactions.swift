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
import NIO

public extension NodeVaultLauncher {
    func history(callback: @escaping (Result<(History, [Int : UInt32]), Swift.Error>) -> Void) {
        guard let vault = self.vault,
              let node = self.node
        else {
            return callback(.failure(ServiceUnavailable()))
        }
        
        return vault.history { height in
            node.blockHeaderLookup(for: height)
            .map {
                try? $0?.serialView().timestamp
            }
        }
        .whenComplete(callback)
    }
}

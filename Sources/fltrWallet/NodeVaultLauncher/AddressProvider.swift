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
    func loadLatestAddress(for repo: HD.Source,
                           callback: @escaping (Result<String, Error>) -> Void) {
        guard let vault = self.vault
        else {
            return callback(.failure(ServiceUnavailable()))
        }
        
        switch repo {
        case .legacySegwit, .segwit, .taproot:
            break
        case .legacy0, .legacy0Change,
                .legacy44, .legacy44Change,
                .legacySegwitChange,
                .segwit0, .segwit0Change,
                .segwitChange,
                .taprootChange:
            preconditionFailure()
        }
        
        vault.lastAddress(for: repo)
        .whenComplete(callback)
    }
}

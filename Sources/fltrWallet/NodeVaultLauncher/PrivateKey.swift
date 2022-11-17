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
    func loadPrivateKey(callback: @escaping (Result<Vault.WalletSeedCodable, Error>) -> Void) {
        let state = self.lock.withLock { self.state }

        switch state {
        case .started(let state):
            let properties = GlobalFltrWalletSettings.WalletPropertiesFactory(state.eventLoop, state.threadPool)
            properties.loadPrivateKey()
            .whenComplete(callback)
        case .initialized, .stopped, .suspended:
            callback(.failure(ServiceUnavailable()))
        case .failed(let error):
            callback(.failure(error))
        }
    }
}

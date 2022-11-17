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
import NIOConcurrencyHelpers


public enum GlewSettings: UInt8, Hashable {
    case main
    case mainTrace
    case simulatorMain
    case simulatorMainTrace
    
    public func setup() {
        switch self {
        case .main:
#if DEBUG
            Settings = .mainProdMultiConnection
            GlobalFltrWalletSettings = .live
#endif
            LOG_LEVEL = .Info
        case .mainTrace:
#if DEBUG
            Settings = .mainProdMultiConnection
            GlobalFltrWalletSettings = .live
#endif
            LOG_LEVEL = .Trace
        case .simulatorMain:
#if DEBUG
            Settings = .mainProdMultiConnection
            GlobalFltrWalletSettings = .simulatorMain
#endif
            LOG_LEVEL = .Info
        case .simulatorMainTrace:
#if DEBUG
            Settings = .mainProdMultiConnection
            GlobalFltrWalletSettings = .simulatorMain
#endif
            LOG_LEVEL = .Trace
        }
    }
}

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
public extension SendModel {
    enum AddressError: Swift.Error, CustomStringConvertible {
        case empty
        case invalidRecipient
        
        public var description: String {
            switch self {
            case .empty:
                return "Address is empty"
            case .invalidRecipient:
                return "Not a valid bitcoin address"
            }
        }
    }
}

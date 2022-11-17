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
    enum AmountError: Swift.Error, CustomStringConvertible, Equatable {
        case amount
        case dust(UInt64)
        case empty
        case insufficient
        case max
        
        public var description: String {
            switch self {
            case .amount:
                return "Not a valid amount"
            case .dust(let amount):
                return "Below minimum amount of \(amount)"
            case .empty:
                return "Amount is empty"
            case .insufficient:
                return "Insufficient funds available"
            case .max:
                return "Over maximum amount"
            }
        }
    }
}

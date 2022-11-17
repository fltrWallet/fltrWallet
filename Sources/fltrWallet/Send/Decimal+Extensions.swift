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
import Foundation

extension Decimal {
    mutating func toString() -> String {
        NSDecimalString(&self, nil)
    }
    
    static func convert(_ amount: String) -> Decimal? {
        guard let _ = Double(amount),
              let decimal = Decimal(string: amount),
              decimal.isNormal,
              decimal > .zero
        else {
            return nil
        }
        
        return decimal
    }
}

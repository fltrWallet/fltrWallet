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

enum CurrencyUnit: UInt64, Hashable, Identifiable, CustomStringConvertible, CaseIterable {
    case btc = 100_000_000
    case mBtc = 100_000
    case sats = 1
    
    static func bestString(_ sats: UInt64) -> String {
        var candidate = Self.btc.toString(sats)
        let remaining = [ Self.mBtc, Self.sats, ]
        for r in remaining {
            let next = r.toString(sats)
            if next.count <= candidate.count {
                candidate = next
            }
        }
        
        return candidate
    }
    
    static let formatter5: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 5
        return numberFormatter
    }()

    static let formatter8: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 8
        return numberFormatter
    }()

    
    var roundingDecimals: Int {
        switch self {
        case .btc: return 8
        case .mBtc: return 5
        case .sats: return 0
        }
    }
    
    var description: String {
        switch self {
        case .btc: return "BTC"
        case .mBtc: return "mBTC"
        case .sats: return "Sats"
        }
    }
    
    var formatter: NumberFormatter {
        switch self {
        case .btc: return Self.formatter8
        case .mBtc, .sats: return Self.formatter5
        }
    }
    
    var id: UInt64 {
        self.rawValue
    }
    
    func sats(_ decimal: Decimal) -> UInt64 {
        var result = decimal * Decimal(self.rawValue)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &result, 0, .plain)
        
        return NSDecimalNumber(decimal: rounded).uint64Value
    }
    
    func convert(_ sats: UInt64) -> String {
        let decimal = Decimal(sats) / Decimal(self.rawValue)
        var rounded = self.round(decimal)
        
        return rounded.toString()
    }
    
    func decimal(from sats: UInt64) -> Decimal {
        let decimal = Decimal(sats) / Decimal(self.rawValue)
        return self.round(decimal)
    }
    
    func round(_ decimal: Decimal) -> Decimal {
        var decimal = decimal
        var rounded = Decimal()
        NSDecimalRound(&rounded, &decimal, self.roundingDecimals, .plain)
        
        return rounded
    }
    
    func toString(_ sats: UInt64) -> String {
        let decimal = self.decimal(from: sats)
        let num = self.formatter.string(for: decimal)!
        return num + " \(String(describing: self))"
    }
}

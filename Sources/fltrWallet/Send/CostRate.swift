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
extension SendModel {
    enum CostRateClass: UInt8, CaseIterable, Identifiable, CustomStringConvertible {
        case low
        case medium
        case high
        
        var description: String {
            switch self {
            case .low: return "Economy"
            case .medium: return "Medium"
            case .high: return "Priority"
            }
        }
        
        var id: UInt8 {
            self.rawValue
        }
    }
    
    struct CostRate: Identifiable {
        let `class`: CostRateClass
        private let feeEstimate: FeeEstimate
        static let nudgeFeePercent: Double = 0.01
        
        
        init(`class`: CostRateClass, feeEstimate: FeeEstimate) {
            self.class = `class`
            self.feeEstimate = feeEstimate
        }
        
        var costPerVByte: Double {
            switch self.class {
            case .low:
                return feeEstimate.low + Self.nudgeFeePercent * feeEstimate.low
            case .medium:
                return feeEstimate.medium + Self.nudgeFeePercent * feeEstimate.medium
            case .high:
                return feeEstimate.high + Self.nudgeFeePercent * feeEstimate.high
            }
        }
        
        var id: [UInt8] {
            [ self.class.id ]
            + self.costPerVByte.bitPattern.littleEndianBytes
        }
    }
}

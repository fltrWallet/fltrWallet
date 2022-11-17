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
import SwiftUI

public protocol ViewModel: NSObject {
    var background: Bool { get set }
    var estimatedHeight: Int { get set }
    var firstRunComplete: Bool { get set }
    var tip: Int { get set }
    var running: Bool { get set }
    var suspended: Bool { get set }
    var active: UInt64 { get set }
    var pending: UInt64 { get set }
    var synched: Bool { get set }

    var synchedPublisher: Published<Bool>.Publisher { get }
    
    var compactFilterEvent: CompactFilterEvent? { get set }
    
    var coinSound: PlaySound? { get }
}

public extension ViewModel {
    var total: UInt64 {
        self.active + self.pending
    }
}

extension ViewModel {
    var debugDescription: String {
        var str: [String] = []
        str.append("background launch(\(self.background))")
        str.append("estimatedHeight(\(self.estimatedHeight))")
        str.append("suspended(\(self.suspended))")
        str.append("tip(\(self.tip))")
        str.append("pending tally (\(self.pending))")
        str.append("active tally(\(self.active))")
        str.append("ready(\(self.synched))")
        return "Model(" + str.joined(separator: ", ") + ")"
    }
}

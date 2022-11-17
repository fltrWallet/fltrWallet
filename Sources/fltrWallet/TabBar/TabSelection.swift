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
import SwiftUI
import fltrBtc

enum TabSelection: String, Hashable, Identifiable {
    case home
    case funds
    case settings
    
    var id: Int {
        switch self {
        case .home: return 0
        case .funds: return 1
        case .settings: return 2
        }
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home),
             (.funds, .funds),
             (.settings, .settings): return true
        default: return false
        }
    }
    
    private var data: (text: String, image: String, fill: String) {
        switch self {
        case .home: return ("Home", "house", "house.fill")
        case .funds: return ("Funds", "wallet.pass", "wallet.pass.fill")
        case .settings: return ("Settings", "gearshape", "gearshape.fill")
        }
    }
    
    var text: String {
        self.data.text
    }
    
    var image: String {
        self.data.image
    }
    
    var fill: String {
        self.data.fill
    }
}

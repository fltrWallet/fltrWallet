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

public extension Text {
    var heading: Text {
        self
            .font(.system(size: 40, weight: .light))
            .foregroundColor(Color("newGray"))
    }
}

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

struct HeadingView: View {
    var textSize: CGFloat = 30
    
    var body: some View {
        Text("fltrWallet")
            .font(.system(size: textSize, weight: .semibold, design: Font.Design.rounded))
            .foregroundColor(Color("newGray"))
            .tracking(5)
            .padding(.top, 10)
    }
}

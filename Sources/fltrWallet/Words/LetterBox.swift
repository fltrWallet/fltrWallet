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

public struct LetterBox: View {
    let text: String
    
    @Environment(\.lineWidth) var lineWidth
    
    public init(_ text: String) {
        self.text = text
    }
    
    public var body: some View {
        Text(text)
            .foregroundColor(Color("newGray"))
            .frame(width: 25, height: 25)
            .font(.system(size: 16))
            .background(
                ZStack {
                    BlurView(radius: 2)
                    
                    Circle()
                        .strokeBorder(lineWidth: lineWidth)
                        .foregroundColor(Color("newGray"))
                }
                .clipShape(Circle())
            )
    }
}


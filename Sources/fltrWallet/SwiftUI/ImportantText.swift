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

public struct ImportantView<Content: View>: View {
    var content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content()
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(
            BlurView(radius: 2.6)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(lineWidth: 0.9)
                        .foregroundColor(Color("fltrGreen"))
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
        )
        .padding()
    }
}

public struct FormatImportantText: View {
    var text: () -> Text
    
    public init(text: @escaping () -> Text) {
        self.text = text
    }

    public var body: some View {
        text()
            .fontWeight(.light)
            .allowsTightening(true)
            .lineLimit(100)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .foregroundColor(Color("newGray"))
    }
}

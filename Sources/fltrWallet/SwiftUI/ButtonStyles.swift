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

public struct RoundedRectangleButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 34
    var padding: CGFloat = 20
    var width: CGFloat = 130
    
    @ScaledMetric(relativeTo: .title3) var fontSize = 22 as CGFloat
    
    @Environment(\.isEnabled) var isEnabled
    
    @Environment(\.buttonBackground) var backgroundColor
    @Environment(\.buttonColor) var buttonColor
    @Environment(\.colorScheme) var color
    
    var tint: Color = .clear
    
    let roundedRectangle = RoundedRectangle(cornerRadius: 34)
    
    public func makeBody(configuration: Configuration) -> some View {
        func colorWhenPressed() -> Color {
            configuration.isPressed
                ? backgroundColor
                : tint
        }

        return configuration.label
            .font(.system(size: fontSize, weight: .light, design: .rounded))
            .lineLimit(1)
            .allowsTightening(true)
            .minimumScaleFactor(1)
            .frame(width: width)
            .padding(padding)
            .foregroundColor(
                buttonColor
                    .opacity(isEnabled ? 1.0 : 0.5)
            )
            .overlay(
                roundedRectangle
                    .strokeBorder(lineWidth: LineWidthThin)
                    .foregroundColor(buttonColor)
                    .opacity(isEnabled ? 1.0 : 0.5)
            )
            .background(
                colorWhenPressed()
                    .background(
                        BlurView(radius: 2)
                    )
                    .clipShape(roundedRectangle)
            )
            .contentShape(
                roundedRectangle
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

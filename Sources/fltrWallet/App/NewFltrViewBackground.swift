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
import fltrUI
import SwiftUI

struct NewFltrViewBackground: View {
    struct BackgroundTexture: View {
        @EnvironmentObject var model: Orientation.Model
        @Environment(\.colorScheme) var color: ColorScheme

        var startPoint: UnitPoint {
            if model.isVertical {
                return .top
            } else {
                if model.isLeft {
                    return .leading
                } else {
                    return .trailing
                }
            }
        }
        
        var endPoint: UnitPoint {
            if model.isVertical {
                return .bottom
            } else {
                if model.isLeft {
                    return .trailing
                } else {
                    return .leading
                }
            }
        }

        var body: some View {
            Image("backgroundTexture")
                .renderingMode(.original)
                .resizable(resizingMode: .tile)
                .mask(
                    LinearGradient(gradient: Gradient(colors: [.white, .black]),
                                   startPoint: startPoint,
                                   endPoint: endPoint)
                        .luminanceToAlpha()
                )
                .opacity(color.isDark ? 0.07 : 0.3)
                .scaleEffect(1.14)
        }
    }

    @Environment(\.colorScheme) var color: ColorScheme

    var body: some View {
        ZStack {
            Color("fltrBackground")
            BackgroundTexture()
        }
    }
}

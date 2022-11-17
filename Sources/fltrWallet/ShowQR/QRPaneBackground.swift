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

struct QRPaneBackground: View {
    @Environment(\.colorScheme) var color
    @EnvironmentObject var orientation: Orientation.Model
    
    var points: (start: UnitPoint, end: UnitPoint) {
        if orientation.isVertical {
            return (start: .topLeading, end: .bottomTrailing)
        } else {
            if orientation.isLeft {
                return (start: .bottomLeading, end: .topTrailing)
            } else {
                return (start: .topTrailing, end: .bottomLeading)
            }
        }
    }
    
    var body: some View {
        Group {
            if color.isLight {
                LinearGradient(gradient: Gradient(colors: [.fltrQrOrange, .fltrQrOrange, .fltrQrRed]),
                               startPoint: points.start, endPoint: points.end)
            } else {
                LinearGradient(gradient: Gradient(colors: [.fltrQrGray1, .black]),
                               startPoint: points.start, endPoint: points.end)
            }
        }
    }
}

struct Background_Previews: PreviewProvider {
    static var previews: some View {
        QRPaneBackground()
            .ignoresSafeArea()
        QRPaneBackground()
            .ignoresSafeArea()
            .preferredColorScheme(.dark)
    }
}

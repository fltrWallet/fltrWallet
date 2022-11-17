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

struct NewLogoView: View {
    struct Logo: View {
        var template: Bool = false
        
        var body: some View {
            Image("logo")
                .renderingMode(self.template ? .template : .original)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
    
    @Environment(\.colorScheme) var color
    
    var body: some View {
        Logo()
        .background(
            ZStack {
                Logo(template: true)
                    .foregroundColor(Color("logoDropShadow"))
                    .blur(radius: 12, opaque: false)
                    .scaleEffect(1.30)
                    .offset(x: 15, y: 60)
                    .opacity(color.isDark ? 0.2 : 0.13)
                Logo(template: true)
                    .shadow(color: color.isDark ? .black : .white, radius: 15)
                    .opacity(color.isDark ? 0.4 : 1.0)
                Logo(template: true)
                    .shadow(color: color.isDark ? .black : .white, radius: 3)
                    .opacity(color.isDark ? 0.6 : 1.0)
            }
            .compositingGroup()
        )
    }
}

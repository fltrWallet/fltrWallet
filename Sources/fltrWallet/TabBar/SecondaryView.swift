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

struct SecondaryView<Content: View>: View {
    @EnvironmentObject var orientation: Orientation.Model
    let TabHeight: CGFloat = 100
    @Environment(\.colorScheme) var color
    
    var content: () -> Content
    
    var edges: Edge.Set {
        .init(self.edge)
    }
    
    var edge: Edge {
        if orientation.isVertical {
            return .bottom
        } else {
            if orientation.isLeft {
                return .trailing
            } else {
                return .leading
            }
        }
    }
    
    var body: some View {
        ZStack {
            content()
                .environment(\.fltrTabBarHeight, TabHeight)
                .environment(\.fltrTabBarEdge, .longAfter)
                .ignoresSafeArea(.keyboard)
                .ignoresSafeArea(.container, edges: edges)

            LongStack(spacing: 0) {
                Spacer()
                    .ignoresSafeArea()
            }
            c2: {
                LongStack {
                    Divider()
                        .ignoresSafeArea()
                        .background(Color.gray)
                }
                c2: {
                    Spacer()
                }
                .ignoresSafeArea()
                .frame(minWidth: orientation.isVertical ? 0 : TabHeight,
                       maxWidth: orientation.isVertical ? .infinity : TabHeight,
                       minHeight: orientation.isVertical ? TabHeight : 0,
                       maxHeight: orientation.isVertical ? TabHeight : .infinity)
                .background(
                    ZStack {
                        BlurView(radius: 2.5)
                            .opacity(color.isDark ? 0.7 : 0.4)

                        ZStack {
                            Color("barBackground")
                            
                            color.isDark ? Color.black.opacity(0.5) : Color.clear
                        }
                        .compositingGroup()
                        .blendMode(.darken)
                        .opacity(color.isDark ? 0.8 : 1)
                        
                    }
                    .compositingGroup()
                )
            }
            .ignoresSafeArea()
        }
    }
}

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

struct WordsGridView: View {
    let words: [String]
    var close: (Bool) -> Void
    
    @Environment(\.colorScheme) var color
    
    @EnvironmentObject var orientation: Orientation.Model
    
    let columns = [
        GridItem(.fixed(30)),
        GridItem(.fixed(100))
    ]
    
    var body: some View {
        RecoveryPhraseView {
            HStack(spacing: 50) {
                LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                    ForEach(Array(zip(words.indices, words).prefix(6)), id: \.0) {
                        LetterBox("\($0.0 + 1)")
                        
                        Text("\($0.1.capitalized)")
                            .fontWeight(.semibold)
                            .allowsTightening(true)
                            .lineLimit(1)
                            .foregroundColor(Color("fltrGreen"))
                            .transition(.opacity)
                    }
                }
                
                LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                    ForEach(Array(zip(words.indices, words).suffix(6)), id: \.0) {
                        LetterBox("\($0.0 + 1)")
                        
                        Text("\($0.1.capitalized)")
                            .fontWeight(.semibold)
                            .allowsTightening(true)
                            .lineLimit(1)
                            .foregroundColor(Color("fltrGreen"))
                            .transition(.opacity)
                    }
                }
            }
            .font(.system(size: 19))
            .frame(maxWidth: 310, alignment: .center)
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .padding(.top, orientation.isVertical ? 25 : 0)
        } buttons: {
            Button("Close", action: { close(true) })
                .background((color.isDark ? Color.black : Color.white).clipShape(RoundedRectangle(cornerRadius: 40)).opacity((color.isDark ? 0.2 : 0.6)))
                .background(BlurView(radius: 3).clipShape(RoundedRectangle(cornerRadius: 40)).opacity(0.4))
                .buttonStyle(RoundedRectangleButtonStyle())
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            if let word = words.first,
               !word.elementsEqual("...") {
                close(true)
            }
        }
    }
}

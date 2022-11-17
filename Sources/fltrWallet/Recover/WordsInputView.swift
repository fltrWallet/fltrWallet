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
import Combine
import SwiftUI

struct WordsInputView: View {
    let cancel: () -> Void
    
    @Environment(\.colorScheme) var color
    @EnvironmentObject var model: WordsInputModel
    @EnvironmentObject var orientation: Orientation.Model
    
    let columns = [
        GridItem(.fixed(30)),
        GridItem(.flexible()),
    ]

    var body: some View {
        ScrollView(.vertical) {
            Text("Recovery Phrase")
                .heading
                .padding(.top, 20)
            
            LongStack {
                HStack(spacing: 10) {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                        ForEach(Array(zip(model.words.indices, model.errors).prefix(6)), id: \.0) { word, errorOptional in
                            LetterBox("\(word + 1)")
                            
                            SendField(placeholder: "Word \(word + 1)",
                                      data: $model.words[word].value,
                                      error: errorOptional,
                                      fontSize: 12)
                        }
                    }
                    
                    LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                        ForEach(Array(zip(model.words.indices, model.errors).suffix(6)), id: \.0) { word, errorOptional in
                            LetterBox("\(word + 1)")
                            
                            SendField(placeholder: "Word \(word + 1)",
                                      data: $model.words[word].value,
                                      error: errorOptional,
                                      fontSize: 12)
                        }
                    }
                }
                .font(.system(size: 19))
                .frame(alignment: .center)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .padding(.top, orientation.isVertical ? 25 : 0)
            } c2: {
                VStack {
                    Spacer(minLength: 0)
                    
                    ImportantView {
                        FormatImportantText {
                            Text("Please enter your 12 word recovery seed phrase in English.")
                        }
                    }
                    
                    HStack {
                        Button {
                            cancel()
                        } label: {
                            Text("Back")
                        }
                        .background((color.isDark ? Color.black : Color.white).clipShape(RoundedRectangle(cornerRadius: 40)).opacity((color.isDark ? 0.2 : 0.6)))
                        .background(BlurView(radius: 3).clipShape(RoundedRectangle(cornerRadius: 40)).opacity(0.4))
                        .buttonStyle(RoundedRectangleButtonStyle())
                        .padding(.latBeforeAfter, 10)

                        Button {
                            model.submitPress = ()
                        } label: {
                            Text("Submit")
                        }
                        .background((color.isDark ? Color.black : Color.white).clipShape(RoundedRectangle(cornerRadius: 40)).opacity((color.isDark ? 0.2 : 0.6)))
                        .background(BlurView(radius: 3).clipShape(RoundedRectangle(cornerRadius: 40)).opacity(0.4))
                        .buttonStyle(RoundedRectangleButtonStyle())
                        .environment(\.buttonBackground, Color("fltrGreen").opacity(0.5))
                        .disabled(model.disableSubmit || model.submitBusy || model.year == nil)
                        .padding(.latBeforeAfter, 10)
                    }
                    .padding(.bottom, 15)

                    Spacer(minLength: 0)
                }
            }
        }
        .combine(model)
        .alert(isPresented: $model.submitError) {
            Alert(title: Text("Unexpected error in form input recovering wallet"),
                  message: nil,
                  dismissButton: .cancel(Text("Dismiss")))
        }
    }
}

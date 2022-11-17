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
import LoadNode
import Orientation

struct RecoveryYear: View {
    @State var chainYears: [Load.ChainYear] = Load.years()
    @Binding var selected: Load.ChainYear?

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var orientation: Orientation.Model
    
    var forwardAction: () -> Void
    
    init(selected: Binding<Load.ChainYear?>,
         forwardAction: @escaping () -> Void) {
        self._selected = selected
        self.forwardAction = forwardAction
    }
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter
    }()
    
    @Environment(\.colorScheme) var color: ColorScheme
    let columns = [ GridItem(.adaptive(minimum: 120)) ]
    var backgroundColor = Color("fltrGreen")
    var body: some View {
        ScrollView {
        LongStack {
            VStack {
                Spacer(minLength: 0)

                LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
                    ForEach(chainYears.reversed()) { year in
                        Button {
                            selected = year
                        } label: {
                            Text(year.date(), formatter: Self.dateFormatter)
                        }
                        .background(selected == year
                                    ? RoundedRectangle(cornerRadius: 40).foregroundColor(backgroundColor.opacity(color.isDark ? 0.55 : 0.4))
                                    : RoundedRectangle(cornerRadius: 40).foregroundColor(Color.clear))
                    }
                    .foregroundColor(Color("newGray"))
                }
                .animation(nil)
                .buttonStyle(RoundedRectangleButtonStyle(padding: 8, width: 100))
                .environment(\.buttonBackground, backgroundColor.opacity(color.isDark ? 0.25 : 0.15))
                .padding(20)
                .padding(.top, orientation.isVertical ? 10 : 30)
                
                Spacer(minLength: 0)
            }
        } c2: {
            VStack {
                Spacer(minLength: 0)

                ImportantView {
                    VStack {
                        FormatImportantText {
                            Text("Select Year: ").bold()
                            + Text("When was the first transaction made?")
                        }
                        .padding(.bottom, 5)
                        
                        FormatImportantText {
                            Text("Select the year when the wallet was first created. Choose the earliest year available if you do not know.\nMake sure you have a fast connection when recovering a wallet.")
                        }
                        .lineLimit(1)
                        .padding(.bottom, 10)
                        
                        FormatImportantText {
                            Text("Wallets created by ")
                            + Text("fltrWallet").bold()
                            + Text(" cannot be older than ")
                            + Text("2022").bold()
                            + Text(".")
                        }
                    }
                }
                
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Close")
                    }
                    .background((color.isDark ? Color.black : Color.white).clipShape(RoundedRectangle(cornerRadius: 40)).opacity((color.isDark ? 0.2 : 0.6)))
                    .background(BlurView(radius: 3).clipShape(RoundedRectangle(cornerRadius: 40)).opacity(0.4))
                    .buttonStyle(RoundedRectangleButtonStyle())
                    .padding(.latBeforeAfter, 10)

                    Button {
                        forwardAction()
                    } label: {
                        Text("Next")
                    }
                    .background((color.isDark ? Color.black : Color.white).clipShape(RoundedRectangle(cornerRadius: 40)).opacity((color.isDark ? 0.2 : 0.6)))
                    .background(BlurView(radius: 3).clipShape(RoundedRectangle(cornerRadius: 40)).opacity(0.4))
                    .buttonStyle(RoundedRectangleButtonStyle())
                    .disabled(selected == nil)
                    .padding(.latBeforeAfter, 10)
                }
                .padding(.bottom, 15)
                
                Spacer(minLength: 0)
            }

        }
        .onAppear {
            selected = chainYears.last
        }
        }
        .frame(maxWidth: orientation.isVertical ? 550 : 800)
        .frame(maxWidth: .infinity)
    }
}

final class YYY: ObservableObject {
    @Published var years: [Load.ChainYear]
    
    init() {
        self.years = Load.years()
    }
}

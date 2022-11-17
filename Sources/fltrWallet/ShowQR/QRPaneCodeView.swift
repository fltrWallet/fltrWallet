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

extension NewQrPane {
    struct CodeView: View {
        let address: (display: String, encode: String)?
        @ScaledMetric var fontSize = 13 as CGFloat
        @State var width: CGFloat = 0
        
        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                NewDisplayQrCodeView(text: address?.encode)
                    .padding(20)
                    .border(Color.white, width: 20)
                    .cornerRadius(24)
                    .padding(.top, 30)
                    .padding([ .leading, .trailing ], 70)
                Group {
                    if let address = address?.display {
                        ZStack {
                            AddressModalView(text: address, width: width)
                                .padding(.horizontal, 30)
                            
                            Text("ABC")
                                .fontWeight(.light)
                                .lineLimit(1)
                                .font(Font.system(size: fontSize, design: .monospaced))
                                .hidden()
                        }
                        
                    } else {
                        Text("")
                            .font(Font.system(size: fontSize, design: .monospaced))
                            .fontWeight(.light)
                            .animation(.none)
                    }
                }
                .padding(.top, 12)
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                    .onAppear {
                        width = geo.size.width
                    }
                    .onChange(of: geo.size.width) { _ in
                        width = geo.size.width
                    }
                }
            )
        }
    }
}

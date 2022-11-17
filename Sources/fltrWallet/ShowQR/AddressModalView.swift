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

struct AddressModalView: View {
    var text: String
    let width: CGFloat
    
    @State var modalEnable = false
    @ScaledMetric var fontSize = 13 as CGFloat

    
    var body: some View {
        Text("\(text)")
            .font(Font.system(size: fontSize, design: .monospaced))
            .fontWeight(.light)
            .truncationMode(.middle)
            .minimumScaleFactor(1)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .opacity(modalEnable ? 0 : 1)
            .contentShape(Rectangle())
            .onTapGesture {
                self.modalEnable = true
            }
            .opacity(modalEnable ? 0 : 1)
            .overlay(
                InnerView(modalEnable: $modalEnable,
                          text: text,
                          width: width)
                    .foregroundColor(Color("newGray"))
            )
            .zIndex(100)
            .animation(.none)
    }
}

extension AddressModalView {
    struct InnerView: View {
        @Binding var modalEnable: Bool
        var text: String
        let width: CGFloat

        @ScaledMetric var fontSize = 13 as CGFloat
        
        var body: some View {
            ZStack {
                Color.clear
                    .overlay(
                        Color
                            .clear
                            .ignoresSafeArea()
                            .frame(width: UIScreen.main.bounds.size.width,
                                   height: UIScreen.main.bounds.size.height)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                modalEnable = false
                            }
                            .disabled(!modalEnable)
                    )

                
                ZStack {
                    BlurView(radius: 2)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    BlurView(radius: 2)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .blendMode(.multiply)
                        .opacity(0.15)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(lineWidth: LineWidthThin)

                    Text("\(text)")
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                        .lineLimit(.max)
                        .font(Font.system(size: fontSize + 4, design: .monospaced))
                        .fixedSize(horizontal: false, vertical: true)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = text
                            }) {
                                Text("Copy to clipboard")
                                Image(systemName: "doc.on.doc")
                            }
                        }
                        .padding(20)
                }
                .compositingGroup()
                .padding()
                .frame(maxHeight: 50)

            }
            .frame(width: width)
            .compositingGroup()
            .opacity(modalEnable ? 1 : 0)
        }
    }
}

struct AddressModalView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            NewLogoView()
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder().foregroundColor(.gray))
            AddressModalView(text: "tb1p74334dv2yy92x564xucd8x0rv6h2v65djj8j8mjg26fam204ud4qrqu4c3",
            width: 200)
            NewLogoView()
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder().foregroundColor(.gray))
        }
    }
}

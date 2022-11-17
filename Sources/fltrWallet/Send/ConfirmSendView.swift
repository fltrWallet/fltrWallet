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

struct ConfirmSendView<Content: View>: View {
    @Binding var confirm: SendModel.ConfirmSend?
    @EnvironmentObject var orientation: Orientation.Model
    
    var action: ((SendModel.ConfirmSend) -> Void)?
    var content: () -> Content
    
    var body: some View {
        content()
        .sheet(item: $confirm) { confirm in
            ScrollView {
                VStack {
                    Text("Confirm Transaction")
                        .heading
                        .padding(.vertical)
                    
                    VStack(spacing: 20) {
                        VStack(spacing: 5) {
                            Text("Recipient")
                                .fontWeight(.medium)
                            Text(confirm.address)
                                .font(.system(size: 20, weight: .light, design: .monospaced))
                                .lineLimit(.max)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 50)
                        .padding(.bottom, 35)
                        
                        
                        HStack {
                            Text("Amount")
                                .fontWeight(.medium)
                                .padding(.leading, 50)
                            Spacer()
                            Text(confirm.unit.toString(confirm.amount))
                                .padding(.trailing, 50)
                        }
                        
                        HStack {
                            Text("Cost")
                                .fontWeight(.medium)
                                .padding(.leading, 50)
                            Spacer()
                            Text("\(confirm.unit.toString(confirm.costEstimate))")
                                .padding(.trailing, 50)
                        }
                        
                        HStack {
                            Spacer()
                            
                            (Text("fee rate ")
                             + Text("\(confirm.costRate.costPerVByte, specifier: "%.0f")")
                             + Text(" sat\(confirm.costRate.costPerVByte >= 2 ? "s" : "") per byte"))
                                .font(.system(size: 16, weight: .light))
                                .italic()
                                .opacity(0.8)
                                .padding(.trailing, 50)
                        }
                        .offset(y: -15)
                        
                        HStack {
                            Text("Total")
                                .fontWeight(.medium)
                                .padding(.leading, 50)
                            Spacer()
                            Text("\(confirm.unit.toString(confirm.costEstimate + confirm.amount))")
                                .padding(.trailing, 50)
                        }
                        .background(
                            VStack(alignment: .center, spacing: 0) {
                                Rectangle()
                                    .fill()
                                    .foregroundColor(Color("newGray"))
                                    .frame(maxWidth: .infinity, maxHeight: LineWidthThin)
                                    .padding(.trailing, 40)
                                    .padding(.leading, 40)
                                    .offset(y: -15)
                                
                                
                                Spacer()
                            }
                        )
                    }
                    .frame(maxWidth: 400)
                    .padding(.bottom, 100)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            self.confirm = nil
                        } label: {
                            Text("Cancel")
                        }
                        .buttonStyle(RoundedRectangleButtonStyle())
                        
                        Spacer()
                        
                        Button {
                            self.confirm = nil
                            action?(confirm)
                        } label: {
                            Text("Confirm")
                        }
                        .buttonStyle(RoundedRectangleButtonStyle())
                        .environment(\.buttonBackground, Color.green.opacity(0.15))
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .font(.system(size: 20, weight: .light))
                .foregroundColor(Color("newGray"))
                .frame(maxWidth: 450)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, orientation.isVertical ? 60 : 10)
            }
            .background(NewFltrViewBackground()
                            .ignoresSafeArea())
            .environmentObject(orientation)
        }
    }
}

struct ConfirmSendView_Previews: PreviewProvider {
    struct Test1: View {
        @State var confirm: SendModel.ConfirmSend? = .init(address: "tb1ppqvjx9cgudgtc9q5x02v52kw2fymykdafsu0f5z3v2pk06hrcjcq7euwfq",
                                                           amount: 1000000,
                                                           unit: .mBtc,
                                                           costRate: .init(class: .low, feeEstimate: .init(low: 11, medium: 22, high: 33)),
                                                           costEstimate: 1023)
        
        var body: some View {
            ConfirmSendView(confirm: $confirm) {
                Text("Label")
            }
        }
        
    }
    
    static var previews: some View {
        OrientationView {
            Test1()
        }
    }
}

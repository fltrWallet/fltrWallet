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
import fltrVault
import SwiftUI

extension NewHistoryView {
    struct DetailView: View {
        @EnvironmentObject var state: NewHistoryView.HistoryModel
        
        var item: History.InOut
        var dictionary: [Int : UInt32]
        @State var copiedAnimation: Bool = false
        
        @ScaledMetric var addressSize: CGFloat = 14
        
        static let dateFormat: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter
        }()
        
        var date: Text {
            let key = self.item.record.height
            if let value = dictionary[key] {
                let date = Date(timeIntervalSince1970: TimeInterval(value))
                return Text("\(date, formatter: Self.dateFormat)")
            } else {
                return Text("Block height \(key))")
            }
        }
        
        var heading: some View {
            var result: [String] = []
            if self.item.record.pending {
                result.append("Pending")
            }
            if self.item.incoming {
                result.append("Incoming")
            } else {
                result.append("Outgoing")
            }
            result.append("Transaction")
            
            return Text(result.joined(separator: " "))
                .foregroundColor(self.item.record.pending ? Color.fltrQrOrange : Color("newGray"))
                .heading
                .multilineTextAlignment(.center)
        }
        
        func copy(text: String) {
            UIPasteboard.general.string = text
            if let dispatchWorkItem = state.dispatchWorkItemCopyAnimation {
                dispatchWorkItem.cancel()
                withAnimation(nil) {
                    self.copiedAnimation = true
                }
            } else {
                withAnimation {
                    self.copiedAnimation = true
                }
            }
            let dispatchWorkItem: DispatchWorkItem = .init {
                withAnimation {
                    self.state.dispatchWorkItemCopyAnimation = nil
                    self.copiedAnimation = false
                }
            }
            self.state.dispatchWorkItemCopyAnimation = dispatchWorkItem
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + .milliseconds(1_100), execute: dispatchWorkItem)
        }
        
        var body: some View {
            ZStack(alignment: .topLeading) {
                ScrollView(.vertical) {
                    VStack {
                        VStack {
                            heading
                                .padding(.bottom, 3)
                            
                            date
                                .font(.system(size: 26, weight: .light))
                                .foregroundColor(Color("newGray"))
                            
                            Divider()
                                .padding(.top, 13                                                                 )
                                .padding(.bottom, 16)
                                .padding(.horizontal)
                                .opacity(0)
                        }
                        
                        VStack {
                            Text("Amount")
                                .font(.system(size: 30, weight: .light))
                                .foregroundColor(Color("newGray"))
                                .padding(.bottom, 2)
                            
                            state.format(amount: item.record.amount, incoming: item.incoming)
                                .font(.system(size: 22, weight: .light))
                            
                            Divider()
                                .padding(.top, 13)
                                .padding(.bottom, 16)
                        }
                        .padding(.horizontal)
                        
                        VStack {
                            Text(item.incoming ? "Received on" : "Sent to")
                                .font(.system(size: 30, weight: .light))
                                .foregroundColor(Color("newGray"))
                                .padding(.bottom, 3)
                            
                            HStack(alignment: .top, spacing: 20) {
                                Text("\(String(describing: item.record.address ?? "Unknown Address"))")
                                    .lineLimit(.max)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .font(.system(size: addressSize, weight: .light))
                                    .truncationMode(.middle)
                                    .multilineTextAlignment(.center)
                                
                                Button {
                                    self.copy(text: String(describing: item.record.address ?? ""))
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                            .foregroundColor(Color("newGray"))
                            .opacity(item.record.address == nil ? 0 : 1)
                            
                            Divider()
                                .padding(.top, 13)
                                .padding(.bottom, 16)
                        }
                        .padding(.horizontal)
                        
                        VStack {
                            Text("Transaction ID")
                                .font(.system(size: 30, weight: .light))
                                .foregroundColor(Color("newGray"))
                                .padding(.bottom, 3)
                            
                            HStack(alignment: .top, spacing: 20) {
                                Text("\(String(describing: item.record.txId))")
                                    .font(.system(size: addressSize, weight: .light))
                                    .multilineTextAlignment(.center)
                                
                                Button {
                                    self.copy(text: String(describing: item.record.txId))
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                            .foregroundColor(Color("newGray"))
                        }
                        .padding(.horizontal)
                    }
                    .offset(x: 0, y: 20)
                    .padding(30)
                }
                
                DetailMenu()
                
                VStack(alignment: .center) {
                    Spacer()
                    
                    Text("Copied to clipboard")
                        .fontWeight(.light)
                        .padding()
                        .background(
                            ZStack {
                                Color("fltrBackground")
                                
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(lineWidth: LineWidthThin)
                                    .foregroundColor(Color("newGray"))
                            }
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .padding(.bottom)
                .padding(.bottom)
                .opacity(copiedAnimation ? 1 : 0)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                NewFltrViewBackground()
                    .ignoresSafeArea()
            )
        }
    }
}

extension NewHistoryView {
    struct DetailMenu: View {
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            HStack {
                Image(systemName: "xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 23)
                    .padding(.top, 12)
                    .padding(.horizontal, 19)
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
                
                Spacer()
            }
            .foregroundColor(Color("newGray"))
        }
    }
}

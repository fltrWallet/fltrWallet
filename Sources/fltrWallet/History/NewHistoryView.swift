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
import fltrVault
import SwiftUI

struct NewHistoryView: View {
    @StateObject var state: HistoryModel = .init()
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var orientation: Orientation.Model
    @EnvironmentObject var syncModel: SyncModel

    var body: some View {
        SecondaryView {
            LongStack(spacing: 0) {
                FirstPane()
                    .frame(maxWidth: orientation.isVertical ? .infinity : 300,
                           maxHeight: orientation.isVertical ? 200 : .infinity)
            } c2: {
                SecondPane()
            }
            .environmentObject(state)
            .combine(state)
            .sheet(item: $state.detail, onDismiss: { state.detail = nil }) { detail in
                DetailView(item: detail, dictionary: state.history!.1)
                    .spinnerAfterSync(longPadding: 50, latPadding: orientation.latSize * 0.05)
                    .environmentObject(appDelegate)
                    .environmentObject(orientation)
                    .environmentObject(state)
                    .environmentObject(syncModel)
            }
            .alert(item: $state.error) { value in
                Alert(title: Text("Error loading coins \(String(describing: value))"),
                      message: nil,
                      dismissButton: .cancel(Text("Dismiss")))
            }
        }
    }
}

extension NewHistoryView {
    struct FirstPane: View {
        @EnvironmentObject var state: HistoryModel
        @EnvironmentObject var model: AppDelegate
        @EnvironmentObject var orientation: Orientation.Model

        var total: Text {
            var text: [Text] = []
            text.append(Text("Total ").foregroundColor(Color("newGray")))
            text.append(Text("\(state.unit?.toString(model.total) ?? CurrencyUnit.bestString(model.total))").foregroundColor(Color("fltrGreen")))
            return text.reduce(Text(""), +)
        }
        
        var body: some View {
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: state.displayUnits ? "gearshape.fill" : "gearshape")
                            .font(.system(size: 20))
                            .contentShape(Rectangle())
                            .foregroundColor(Color("newGray"))
                            .onTapGesture {
                                state.displayUnits.toggle()
                            }
                            .padding(.horizontal, orientation.isVertical ? 30 : 10)
                    }
                    Spacer()
                }
                
                VStack(spacing: 10) {
                    Text("Transactions")
                        .heading
                    
                    HStack(spacing: 10) {
                        Button {
                            state.unit = nil
                        } label: {
                            Text("Auto")
                                .underline()
                        }

                        Button {
                            state.unit = .btc
                        } label: {
                            Text("BTC")
                                .underline()
                        }

                        Button {
                            state.unit = .mBtc
                        } label: {
                            Text("mBTC")
                                .underline()
                        }

                        Button {
                            state.unit = .sats
                        } label: {
                            Text("Sats")
                                .underline()
                        }
                    }
                    .accentColor(Color("newGray"))
                    .opacity(state.displayUnits ? 1 : 0)
                    .font(.system(size: 15, weight: .ultraLight, design: .monospaced))
                    
                    total
                        .font(.system(size: 25, weight: .light))
                    
                    Spacer()
                    
                    Picker("Filter Selection", selection: $state.receivedSent) {
                        Text("All").tag(HistoryModel.ReceivedSent.all)
                        Text("Received").tag(HistoryModel.ReceivedSent.received)
                        Text("Sent").tag(HistoryModel.ReceivedSent.sent)
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, orientation.isVertical ? 0 : 15)
                }
                .foregroundColor(Color("newGray"))
                .padding(.horizontal)
            }
            .padding(.top, orientation.isVertical ? 0 : 15)
        }
    }
}

extension NewHistoryView {
    struct SecondPane: View {
        @EnvironmentObject var orientation: Orientation.Model
        @EnvironmentObject var state: HistoryModel
        @Environment(\.fltrTabBarHeight) var tabHeight
        @Environment(\.fltrTabBarEdge) var tabEdge
        
        var body: some View {
            ScrollView {
                VStack(spacing: 0) {
                    if let pending = state.pendingFilter {
                        ForEach(pending.reversed()) { item in
                            RowView(item: item, detail: $state.detail, dictionary: state.history?.1 ?? [:])
                        }
                        .foregroundColor(.fltrQrOrange)
                    }
                    
                    if let confirmed = state.confirmedFilter {
                        ForEach(confirmed.reversed()) { item in
                            RowView(item: item, detail: $state.detail, dictionary: state.history?.1 ?? [:])
                        }
                        .foregroundColor(Color("newGray"))
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(.top, 15)
                .padding(.horizontal, 50)
                .padding(tabEdge, orientation.isVertical ? tabHeight : 0)
            }
            .padding(tabEdge, orientation.isVertical ? 0 : tabHeight)
        }
    }
}

struct NewHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        TestEnvironment {
            NewHistoryView()
        }
    }
}

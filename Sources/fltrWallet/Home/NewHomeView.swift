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
import fltrUI
import SwiftUI

struct NewHomeView: View {
    @EnvironmentObject var model: AppDelegate
    @EnvironmentObject var orientation: Orientation.Model
    @EnvironmentObject var syncModel: SyncModel
    @StateObject var sendSheetModel: SendSheetModel = .init()
    
    @State var showSheet: Bool = false
    
    var offsetAmount: Orientation.Direction {
        .longitude(5000 + orientation.longSize - 0.05 * orientation.latSize - 100)
    }
    
    var body: some View {
        ZStack {
            WindowScrollView(direction: .longitude, ignoresSafeArea: true) {
                LongStack(alignment: .center) {
                    VStack(alignment: .center, spacing: 0) {
                        NewLogoView()
                        .frame(minHeight: 0, maxHeight: orientation.longSize * 0.24)
                        .overlay(
                            VStack(alignment: .center, spacing: 0) {
                                Spacer()
                                Group {
                                    SyncView(width: min(orientation.latSize * 0.8, 600),
                                             height: 5.5)
                                        
                                }
                            }
                            .offset(x: 0, y: orientation.size.height * 0.1325)
                        )
                        .padding(.longBefore, orientation.longSize * (orientation.isVertical ? 0.185 : 0.14))
                        .padding(.latBeforeAfter, 100)
                    }
                }
                c2: {
                    Spacer(minLength: 0)
                }
                c3: {
                    ButtonsView {
                        sendSheetModel.startSend()
                    }
                    showQrAction: {
                        showSheet = true
                    }
                    scanQrAction: {
                        sendSheetModel.startScan()
                    }
                    .padding(.longBefore, orientation.isVertical
                                ? orientation.longSize * 0.15
                                : orientation.longSize * 0.08)
                }
                c4: {
                    Spacer(minLength: orientation.isVertical ? orientation.longSize * 0.20 : orientation.longSize * 0.22)
                }
                .background(
                    NewHomeShape()
                        .ignoresSafeArea(.all)
                        .foregroundColor(Color("barBackground"))
                        .frame(width: orientation.isVertical ? orientation.size.width : orientation.size.width + 10000,
                               height: orientation.isVertical ? orientation.size.height + 10000: orientation.size.height)
                        .offset(toOffset(model: orientation, direction: offsetAmount))
                    
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack {
                HeadingView()
                Spacer()
            }
        }
        .fullScreenCover(item: $sendSheetModel.sendOrScan) { choice in
            Group {
                switch choice {
                case .send:
                    SendView(sendSheetModel: sendSheetModel)
                        .background(NewFltrViewBackground().ignoresSafeArea())
                        .transition(.opacity.animation(.easeIn(duration: 0.5)))
                        .spinnerAfterSync()
                case .scan:
                    ScanQrView(sendSheetModel: sendSheetModel)
                        .transition(.opacity.animation(.easeIn(duration: 0.5)))
                }
            }
            .environmentObject(model)
            .environmentObject(orientation)
            .environmentObject(syncModel)
            .environment(\.buttonBackground, Color.orange.opacity(0.1))
            .environment(\.buttonColor, Color("newGray"))
        }
        .sheet(isPresented: $showSheet) {
            NewQrPane()
                .environmentObject(model)
                .environmentObject(orientation)
                .environment(\.buttonBackground, Color.orange.opacity(0.1))
                .environment(\.buttonColor, Color("newGray"))
        }
        .environment(\.buttonBackground, Color.orange.opacity(0.1))
        .environment(\.buttonColor, Color("newGray"))
    }
}

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

struct NewQrBar: View {
    var fontSize: CGFloat = 12
    var showQrAction: () -> Void
    var scanQrAction: () -> Void
    
    @EnvironmentObject var syncModel: SyncModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            NewQrShow(action: showQrAction)
                .padding(.trailing, 20)

            NewQrScan(action: scanQrAction)
                .padding(.leading, 20)
                .disabled(!syncModel.completed)
        }
    }
}

extension NewQrBar {
    struct NewQrShow: View {
        struct QRShowButtonStyle: ButtonStyle {
            @Environment(\.isEnabled) var isEnabled
            @Environment(\.buttonBackground) var backgroundColor

            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .foregroundColor(
                        Color("newGray")
                            .opacity(isEnabled ? 1.0 : 0.5)
                    )
                    .background(
                        (configuration.isPressed
                            ? backgroundColor
                            : Color.clear)
                            .background(BlurView(radius: 2))
                            .clipShape(Circle())
                    )
                    .contentShape(
                        Circle()
                    )
                    .scaleEffect(configuration.isPressed ? 0.98 : 1)
            }
        }

        var fontSize: CGFloat = 12
        var action: () -> Void
        
        var body: some View {
            VStack(spacing: 0) {
                Button(action: action) {
                    Image(systemName: "qrcode")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(0.8)
                        .padding(8)
                        .overlay(
                            Circle()
                                .stroke(Color("newGray"), lineWidth: 0.9)
                        )
                }
                .buttonStyle(QRShowButtonStyle())
                
                Text("Show QR")
                    .font(.system(size: fontSize))
                    .fontWeight(.light)
                    .kerning(0.1)
                    .lineLimit(1)
                    .padding(.top, 5)
            }
            .foregroundColor(Color("newGray"))
        }
    }

    struct NewQrScan: View {
        struct QRScanButtonStyle: ButtonStyle {
            @Environment(\.isEnabled) var isEnabled
            @Environment(\.buttonBackground) var backgroundColor

            func makeBody(configuration: Configuration) -> some View {
                configuration.label
                    .foregroundColor(
                        Color("newGray")
                            .opacity(isEnabled ? 1.0 : 0.5)
                    )
                    .background(
                        (configuration.isPressed
                            ? backgroundColor
                            : Color.clear)
                            .background(BlurView(radius: 2))
                            .clipShape(Rectangle())
                    )
                    .contentShape(
                        Rectangle()
                    )
                    .scaleEffect(configuration.isPressed ? 0.98 : 1)
            }
        }

        var fontSize: CGFloat = 12
        var action: () -> Void
        
        var body: some View {
            VStack(spacing: 0) {
                Button(action: action) {
                    Image(systemName: "barcode.viewfinder")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(8)
                        .overlay(
                            ViewFinderShaper()
                                .stroke(Color("newGray"), lineWidth: 0.9)
                        )
                }
                .buttonStyle(QRScanButtonStyle())
                
                Text("Scan")
                    .font(.system(size: fontSize))
                    .fontWeight(.light)
                    .kerning(0.1)
                    .lineLimit(1)
                    .padding(.top, 5)
            }
        }
    }
}

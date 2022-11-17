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

struct ButtonsView: View {
    var sendAction: () -> Void
    var showQrAction: () -> Void
    var scanQrAction: () -> Void
    
    @EnvironmentObject var orientation: Orientation.Model
    @EnvironmentObject var syncModel: SyncModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Button(action: sendAction) {
                Text("Send")
                    .kerning(4.5)
                    .lineLimit(1)
                    .minimumScaleFactor(1)
            }
            .buttonStyle(RoundedRectangleButtonStyle())
            .frame(minWidth: 185, minHeight: 50)
            .padding(40)
            .disabled(!syncModel.completed)

            NewQrBar(showQrAction: showQrAction, scanQrAction: scanQrAction)
            .frame(minWidth: 140,
                   maxWidth: 180,
                   maxHeight: 100)
        }
    }
}


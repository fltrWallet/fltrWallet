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
import fltrBtc
import SwiftUI

struct ScanQrView: View {
    @ObservedObject var sendSheetModel: SendSheetModel

    @EnvironmentObject var model: AppDelegate
    @EnvironmentObject var orientation: Orientation.Model
    
    var body: some View {
        QrReaderView(match: $sendSheetModel.address) { string in
            if let uri = URLComponents(string: string),
               let query = uri.queryItems,
               let amount = query.filter({ $0.name.lowercased() == "amount" }).first?.value,
               let integerAmount = UInt64(amount) {
                sendSheetModel.amount = integerAmount
            } else {
                sendSheetModel.amount = nil
            }
            return AddressDecoder(decoding: string,
                                  network: GlobalFltrWalletSettings.Network)
        }
        onDismiss: {
            sendSheetModel.dismissScan()
        }
    }
}

extension AddressDecoder: Identifiable {
    public var id: String {
        self.string
    }
}

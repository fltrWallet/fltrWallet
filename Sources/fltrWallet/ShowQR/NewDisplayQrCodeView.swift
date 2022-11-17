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

struct NewDisplayQrCodeView: View {
    let qr = Qr()
    let text: String?
    
    var body: some View {
        if let text = text {
            #if os(macOS)
            Image(nsImage: qr.code(from: text).value)
                .interpolation(.none)
                .resizable()
                .aspectRatio(contentMode: .fit)
            #else
            Image(uiImage: qr.code(from: text).value)
                .interpolation(.none)
                .resizable()
                .aspectRatio(contentMode: .fit)
            #endif
        } else {
            Image(systemName: "xmark.octagon.fill")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(10)
                .background(Color.white)
        }
    }
}

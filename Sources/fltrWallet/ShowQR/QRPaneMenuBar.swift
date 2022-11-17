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
    struct MenuBar: View {
        @Binding var showShare: Bool
        let address: String?
        
        @Environment(\.presentationMode) var presentationMode
        @EnvironmentObject var orientation: Orientation.Model
        
        var body: some View {
            HStack {
                if orientation.compactHorizontal {
                    Image(systemName: "xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 23)
                        .padding(.top, 12)
                        .padding(.horizontal, 19)
                        .onTapGesture {
                            presentationMode.wrappedValue.dismiss()
                        }
                }
                Spacer()
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 23)
                    .padding(.top, 12)
                    .padding(.horizontal, 19)
                    .onTapGesture {
                        showShare = true
                    }
                    .disabled(address == nil)
            }
            .foregroundColor(Color("newGray"))
        }
    }
}

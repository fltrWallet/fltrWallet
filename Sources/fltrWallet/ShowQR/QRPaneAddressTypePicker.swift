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
import HaByLo
import SwiftUI

extension NewQrPane {
    struct AddressTypePicker: View {
        let defaultAddressType = AddressType.taproot
        
        @Binding var selectorIndex: AddressType?
        
        @EnvironmentObject var model: AppDelegate

        var body: some View {
            Picker("Address Type", selection: $selectorIndex) {
                Text("Taproot")
                    .tag(AddressType?.some(.taproot))
                Text("Segwit")
                    .tag(AddressType?.some(.segwit))
                Text("Legacy")
                    .tag(AddressType?.some(.legacy))
            }
            .padding(20)
            .padding(.horizontal, 40)
            .pickerStyle(SegmentedPickerStyle())
            .onAppear {
                selectorIndex = defaultAddressType
            }
        }
    }
}

extension NewQrPane {
    enum AddressType: UInt8, Hashable, Identifiable {
        case legacy
        case segwit
        case taproot
        
        var id: UInt8 {
            self.rawValue
        }
    }
}

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

struct FltrTabSelectionView<A: View, B: View, C: View>: View {
    @Binding var selection: TabSelection
    
    var home: () -> A
    var receive: () -> B
    var settings: () -> C
    
    var body: some View {
        Group {
            if selection == .home {
                home()
                    .frame(maxWidth: .infinity)
            } else if selection == .funds {
                receive()
                    .frame(maxWidth: .infinity)
            } else if selection == .settings {
                settings()
                    .frame(maxWidth: .infinity)
            } else {
                preconditionFailure()
            }
        }
    }
}


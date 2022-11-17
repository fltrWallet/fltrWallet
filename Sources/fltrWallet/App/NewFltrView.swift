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
import fltrUI
import SwiftUI

public struct NewFltrView: View {
    @State var selection: TabSelection = .home
    
    public init() {}
    
    public var body: some View {
        ZStack {
            FltrTabSelectionView(selection: $selection) {
                NewHomeView()
            }
            receive: {
                NewHistoryView()
            }
            settings: {
                SettingsView()
            }
            
            LongStack(alignment: .center) {
                Spacer()
            }
            c2: {
                OrientationFltrTabBarView(selection: $selection)
            }
            .ignoresSafeArea(.all)
        }
        .background(
            NewFltrViewBackground()
                .ignoresSafeArea()
        )
        .spinnerAfterSync()
    }
}

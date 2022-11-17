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

public extension AppDelegate {
    static var running120: Self {
        .init(background: false,
              running: true,
              suspended: false,
              active: 100_000,
              pending: 20_000,
              estimatedHeight: 10_000,
              tip: 9_000,
              synched: false,
              glewRocket: GlewRocket(launcher: { NodeVaultLauncherTesting() }))
    }
}

public struct TestEnvironment<Content: View>: View {
    @StateObject var model: AppDelegate = .running120
    
    var content: () -> Content
    
    public init(firstRun: Bool? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        
        if let firstRun = firstRun {
            UserDefaults.standard.setValue(firstRun, forKey: "firstRunComplete")
        }
    }
    
    public var body: some View {
        OrientationView {
            content()
                .buttonStyle(RoundedRectangleButtonStyle())
                .onAppear {
                    model.glewRocket.start(model)
                }
                .environmentObject(model)
        }
    }
}

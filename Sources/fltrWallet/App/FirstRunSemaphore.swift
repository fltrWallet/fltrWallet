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
import SwiftUI

fileprivate final class FirstRunModel: ObservableObject {
    @Published var initializeComplete = true
}

public struct FirstRunSemaphore<FirstRun: View, Content: View>: View {
    @StateObject fileprivate var state = FirstRunModel()
    @EnvironmentObject var appDelegate: AppDelegate
    
    var content: () -> Content
    var firstRun: (Binding<Bool>) -> FirstRun
   
    public init(resetFirstRunComplete: Bool? = nil,
                @ViewBuilder content: @escaping () -> Content,
                firstRun: @escaping (Binding<Bool>) -> FirstRun) {
        if let reset = resetFirstRunComplete {
            UserDefaults.standard.setValue(reset, forKey: "firstRunComplete")
        }
        self.content = content
        self.firstRun = firstRun
    }
    
    @ViewBuilder
    public var body: some View {
            if appDelegate.firstRunComplete, state.initializeComplete {
                content()
                .transition(
                    .asymmetric(insertion: .identity,
                                removal: .scale)
                    .animation(.easeIn(duration: 0.5))
                )
            } else {
                firstRun($state.initializeComplete)
                    .onAppear {
                        state.initializeComplete = false
                    }
                    .transition(
                        .opacity
                        .animation(.easeIn(duration: 1))
                    )

            }
    }
}

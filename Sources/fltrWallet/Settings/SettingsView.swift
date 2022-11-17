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
import LocalAuthentication
import SwiftUI

struct SettingsView: View {
    @State var showWords = false
    @EnvironmentObject var model: AppDelegate
    @EnvironmentObject var orientation: Orientation.Model
    @Environment(\.buttonColor) var buttonColor
    @StateObject var words: WordsState = .init()
    
    var body: some View {
        SecondaryView {
            SettingsNavigationView(showWords: $showWords)
        }
        .fullScreenCover(isPresented: $showWords) {
            WordsView(words: words.words) { _ in
                showWords = false
                words.reset()
            }
            .combine(words)
            .environmentObject(model)
            .environmentObject(orientation)
            .environment(\.buttonColor, buttonColor)
            .onDisappear {
                showWords = false
                words.reset()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    struct Preview: View {
        @StateObject var model = AppDelegate.running120
        
        var body: some View {
            OrientationView {
                SettingsView()
                .onAppear {
                    model.glewRocket.start(model)
                }
                .environmentObject(model)
            }
        }
    }

    static var previews: some View {
        Preview()
    }
}

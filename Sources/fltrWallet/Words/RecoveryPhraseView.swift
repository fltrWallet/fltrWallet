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

struct RecoveryPhraseView<Content: View, Buttons: View>: View {
    var content: () -> Content
    var buttons: () -> Buttons
    
    @Environment(\.colorScheme) var color
    @EnvironmentObject var orientation: Orientation.Model
    @State var screenshot: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                VStack {
                    
                    Text("Recovery Phrase")
                        .heading
                        .padding(.top, 20)
                    
                    LongStack(spacing: 50) {
                        content()
                    }
                c2: {
                    ImportantView {
                        VStack {
                            FormatImportantText {
                                Text("Important!\n").bold()
                                + Text("Write down the ")
                                + Text("recovery phrase with pen and paper")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color("fltrBackgroundInverted"))
                                + Text(". Keep it in a ")
                                + Text("safe place")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color("fltrBackgroundInverted"))
                                + Text(". It can be used for wallet recovery in case of ")
                                + Text("loss")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color("fltrBackgroundInverted"))
                                + Text(" or ")
                                + Text("failure")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color("fltrBackgroundInverted"))
                                + Text(".")
                            }
                            .padding(.bottom, 15)
                            
                            FormatImportantText {
                                Text("Do not take ")
                                + Text("screenshots")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color("fltrBackgroundInverted"))
                                + Text(", as it can compromise the ")
                                + Text("security")
                                    .fontWeight(.medium)
                                    .foregroundColor(Color("fltrBackgroundInverted"))
                                + Text(" of your wallet.")
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: 500)
                }
                    buttons()
                        .padding(.vertical)
                        .padding(.bottom)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
            screenshot = true
        }
        .alert(isPresented: $screenshot) {
            Alert(
                title: Text("Warning: Screenshot taken"),
                message: Text("Only store the passphrase through pen and paper"),
                dismissButton: .default(Text("Close"))
            )
        }
    }
}

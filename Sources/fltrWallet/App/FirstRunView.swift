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
import LoadNode

public struct FirstRunView: View {
    @Binding var initializeComplete: Bool
    
    @StateObject var firstRun: FirstRunModel = .init()
    @EnvironmentObject var orientation: Orientation.Model
    
    @Environment(\.colorScheme) var color

    @EnvironmentObject var model: AppDelegate
    
    public init(initializeComplete: Binding<Bool>) {
        self._initializeComplete = initializeComplete
    }
    
    var choice: some View {
        ScrollView {
        LongStack(alignment: .center) {
            HStack {
                Spacer()
                VStack {
                    Text("First Launch")
                        .heading
                    
                    NewLogoView()
                        .frame(minHeight: 50, maxHeight: 200)
                        .padding(.bottom, 20)
                }
                Spacer()
            }
        } c2: {
            WelcomeText {
                self.firstRun.chosenView = .new
            } recoverAction: {
                self.firstRun.chosenView = .recover
            }
            .padding(.horizontal, 32)
            .padding(.bottom)
            .padding(.bottom)
        } c3: {
            Spacer()
        }
    }
        .frame(maxWidth: orientation.isVertical ? 550 : 800)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    func newOrRecover(_ choice: FirstRunModel.NewOrRecover) -> some View {
        switch choice {
        case .new:
            WordsView(words: firstRun.words) { _ in
                initializeComplete = true
            }
            .environmentObject(model)
            .environmentObject(orientation)
            .onAppear {
                initializeComplete = false
                firstRun.newWallet(model: self.model)
            }
        case .recover:
            RecoverView(initializeComplete: $initializeComplete)
                .environmentObject(model)
                .environmentObject(firstRun)
                .environmentObject(orientation)
        }
    }
    
    public var body: some View {
        choice
        .fullScreenCover(
            item: $firstRun.chosenView,
            content: newOrRecover(_:)
        )
        .background(
            NewFltrViewBackground()
            .ignoresSafeArea()
        )
    }
}

struct RecoverView: View {
    @Binding var initializeComplete: Bool
    @EnvironmentObject var firstRun: FirstRunView.FirstRunModel
    @EnvironmentObject var model: AppDelegate
    @StateObject var wordsInputModel = WordsInputModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        TwoPane { rightAction in//(submitDisabled: $wordsInputModel.disableSubmit) {
            RecoveryYear(selected: $wordsInputModel.year) {
                rightAction()
            }
        } right: { leftAction in
            WordsInputView() {
                leftAction()
            }
        }
        .background(NewFltrViewBackground()
                        .ignoresSafeArea())
        .onChange(of: model.firstRunComplete, perform: {
            if $0 { initializeComplete = true }
            presentationMode.wrappedValue.dismiss()
        })
        .environmentObject(wordsInputModel)
    }
}

extension FirstRunView {
    final class FirstRunModel: ObservableObject {
        enum NewOrRecover: UInt8, Identifiable {
            case new
            case recover
            
            var id: UInt8 { self.rawValue }
        }
        
        @Published var chosenView: NewOrRecover? = nil
        @Published var words: [String]? = nil
        
        func newWallet(model: AppDelegate) {
            model.glewRocket.firstRun(entropy: nil) { wordsResult in
                DispatchQueue.main.async {
                    model.firstRunComplete = true
                    guard let gotWords = try? wordsResult.get()
                    else {
                        preconditionFailure("expected to load words from GlewModel")
                    }
                    
                    self.words = gotWords
                }
            }
        }
    }
}

extension FirstRunView {
    struct WelcomeText: View {
        var newAction: () -> Void
        var recoverAction: () -> Void
        
        @Environment(\.colorScheme) var color
        @EnvironmentObject var orientation: Orientation.Model
        @State var recoverWidth: CGFloat = 0
        
        var welcomeHeading: Text {
            Text("Welcome to fltrWallet")
                .font(.system(size: 28, weight: .light))
                
        }
        
        var subHeading: Text {
            Text("Where your transaction and public key history is forever safe!")
                .font(.system(size: 18, weight: .thin))
                .italic()
                .foregroundColor(Color("fltrBackgroundInverted"))
        }
        
        var optionText: Text {
            Text("You have the option to create a new wallet or to recover a wallet previously created by fltrWallet.")
                .fontWeight(.light)
        }
        
        var newText: Text {
            (
                Text("Create a new wallet")
                    .fontWeight(.medium)
                    .foregroundColor(Color("fltrBackgroundInverted"))
                +
                Text(" with a fresh unusused private key.")
            )
                .fontWeight(.light)
        }
        
        var recoverText: Text {
            (
                Text("Recover Wallet")
                    .fontWeight(.medium)
                    .foregroundColor(Color("fltrBackgroundInverted"))
                + Text(" using a twelve word seed phrase. ")
                + Text("fltrWallet")
                    .fontWeight(.medium)
                    .foregroundColor(Color("fltrBackgroundInverted"))
                + Text(" can import from most ")
                + Text("BIP32")
                    .fontWeight(.medium)
                    .foregroundColor(Color("fltrBackgroundInverted"))
                + Text(" or ")
                + Text("HD")
                    .fontWeight(.medium)
                    .foregroundColor(Color("fltrBackgroundInverted"))
                + Text(" wallets. The blockchain will be scanned for historical transactions, which can be a lengthy process. ")
            )
                .fontWeight(.light)
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                welcomeHeading
                    .padding(.horizontal, 20)
                    .padding(.top)
                    .padding(.top)
                
                subHeading
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.leading, 25)
                    .padding(.trailing, 70)
                    .padding(.bottom)
                    .padding(.bottom)

                newText
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 5)
                    
                    Button {
                        newAction()
                    } label: {
                        Text("New Wallet")
                    }
                    .buttonStyle(RoundedRectangleButtonStyle())
                    .background((color.isDark ? Color("fltrGreen").opacity(0.5) :Color("fltrGreen").opacity(0.25)).clipShape(RoundedRectangle(cornerRadius: 40)).opacity((color.isDark ? 0.2 : 0.6)))
                    .background(BlurView(radius: 3))
                    .padding(.bottom)
                    .environment(\.buttonBackground, Color("fltrGreen").opacity(0.5))
                    .scaleEffect(0.85)
                    .minimumScaleFactor(0.6)

                Divider()
                    .padding(.bottom, 30)
                
                recoverText
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 5)
                    
                    Button {
                        recoverAction()
                    } label: {
                        Text("Recover Wallet")
                    }
                    .buttonStyle(RoundedRectangleButtonStyle(width: 200))
                    .background(Color("fltrBackground").clipShape(RoundedRectangle(cornerRadius: 40)).opacity((color.isDark ? 0.2 : 0.6)))
                    .background(BlurView(radius: 3))
                    .padding(.bottom)
                    .scaleEffect(0.85)
                    .minimumScaleFactor(0.6)
            }
            .foregroundColor(Color("newGray"))
        }
    }
}

struct FirstRunView_Previews: PreviewProvider {
    static var previews: some View {
        TestEnvironment {
            FirstRunSemaphore(resetFirstRunComplete: false) {
                Text("First Run Completed Successfully")
            }
            firstRun: { initializeComplete in
                FirstRunView(initializeComplete: initializeComplete)
            }
        }
    }
}

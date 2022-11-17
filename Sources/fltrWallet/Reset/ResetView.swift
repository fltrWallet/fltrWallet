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

extension ResetView {
    final class ReviewModel: ObservableObject {
        private var cancellables = Set<AnyCancellable>()
        @Published var cover = false
        @Published var reviewed = false
        
        
        func didReview() {
            self.reviewed = true
        }
        func start() {
            
        }
        
        func stop() {
            cancellables.removeAll()
        }
    }
    
    final class DeleteModel: ObservableObject {
        @Published var word: String = ""
        @Published var wordError: String?
        @Published var invalid: Bool = true
        @Published var pending = false
        
        private var cancellables = Set<AnyCancellable>()
        
        var deletePublisher: AnyPublisher<Bool, Never> {
            $word
                .compactMap { $0 }
                .map {
                    $0
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .uppercased()
                }
                .debounce(for: 0.2, scheduler: DispatchQueue.main)
                .removeDuplicates()
                .map {
                    !$0.elementsEqual("DELETE")
                }
                .eraseToAnyPublisher()
        }
        
        func start() {
            deletePublisher
                .assign(to: \.invalid, on: self)
                .store(in: &cancellables)

            $word
                .map { _ -> String? in
                    nil
                }
                .assign(to: \.wordError, on: self)
                .store(in: &cancellables)
            
            $word
                .compactMap {
                    let uppercased = $0.uppercased()
                    guard !$0.elementsEqual(uppercased)
                    else { return nil }

                    return uppercased
                }
                .receive(on: DispatchQueue.main)
                .assign(to: \.word, on: self)
                .store(in: &cancellables)

            $invalid
                .combineLatest(
                    $word
                )
                .map { invalid, word -> String? in
                    guard !word.elementsEqual(""),
                          invalid
                    else { return nil }
                    
                    return "Enter DELETE to confirm"
                }
                .debounce(for: 1, scheduler: DispatchQueue.main)
                .assign(to: \.wordError, on: self)
                .store(in: &cancellables)
        }
        
        func stop() {
            self.cancellables.removeAll()
        }
    }
}

struct ResetView: View {
    @StateObject var review: ReviewModel = .init()
    @StateObject var state: DeleteModel = .init()
    @EnvironmentObject var model: AppDelegate
    @EnvironmentObject var orientation: Orientation.Model
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var color
    
    @ViewBuilder
    var text1: Text {
        Text("Ensure")
            .fontWeight(.medium)
            .foregroundColor(Color("fltrBackgroundInverted"))
        + Text(" you have written down the ")
        + Text("twelwe word passphrase")
            .fontWeight(.medium)
            .foregroundColor(Color("fltrBackgroundInverted"))
        + Text(" so that the wallet can be recovered. All funds will be ")
        + Text("lost")
            .fontWeight(.medium)
            .foregroundColor(Color("fltrBackgroundInverted"))
        + Text(" without the passphrase.")
    }
    
    @ViewBuilder
    var text2: Text {
        Text("To proceed with ")
        + Text("deletion")
            .fontWeight(.medium)
            .foregroundColor(Color("fltrBackgroundInverted"))
        + Text(" and ")
        + Text("reset fltrWallet,")
            .fontWeight(.medium)
            .foregroundColor(Color("fltrBackgroundInverted"))
        + Text(" please ")
        + Text("copy")
            .fontWeight(.medium)
            .foregroundColor(Color("fltrBackgroundInverted"))
        + Text(" and ")
        + Text("verify")
            .fontWeight(.medium)
            .foregroundColor(Color("fltrBackgroundInverted"))
    }
    
    @ViewBuilder
    var text3: Text {
        Text(" the ")
        + Text("passphrase")
            .fontWeight(.medium)
            .foregroundColor(Color("fltrBackgroundInverted"))
        + Text(" below. The ")
        + Text("Continue")
            .fontWeight(.medium)
            .foregroundColor(Color("fltrBackgroundInverted"))
        + Text(" button will ")
        + Text("enable")
            .fontWeight(.medium)
            .foregroundColor(Color("fltrBackgroundInverted"))
        + Text(" once passphrase ")
        + Text("review")
            .fontWeight(.medium)
            .foregroundColor(Color("fltrBackgroundInverted"))
        + Text(" is complete.")
    }
    
    @ViewBuilder
    var balanceBox: some View {
        HStack {
            Spacer(minLength: 0)
            
            ImportantView {
                FormatImportantText {
                    Text("Current Balance\n\(model.total) Sats")
                    .font(.system(size: 24))
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical)
            }

            Spacer(minLength: 0)
        }

    }
    
    @ViewBuilder
    func formatRedButton<Label: View>(_ button: () -> Button<Label>) -> some View {
        button()
            .buttonStyle(RoundedRectangleButtonStyle())
            .environment(\.buttonColor, .red)
            .environment(\.buttonBackground, color.isDark
                          ? .red.opacity(0.25)
                          : .red.opacity(0.20))
            .background(
                RoundedRectangle(cornerRadius: 40)
                .fill(color.isDark
                      ? Color.red.opacity(0.05)
                      : Color.red.opacity(0.02))
            )
    }
    
    @ViewBuilder
    var reviewButton: some View {
        Button {
            review.cover = true
        } label: {
            Text("Passphrase")
        }
        .buttonStyle(RoundedRectangleButtonStyle())
        .scaleEffect(min(1, orientation.size.width/450))
    }
    
    @ViewBuilder
    func continueButton(_ action: @escaping () -> Void) -> some View {
        Button {
            guard review.reviewed
            else { return }
            
            return action()
        } label: {
            Text("Continue")
        }
        .buttonStyle(RoundedRectangleButtonStyle())
        .disabled(!review.reviewed)
        .saturation(review.reviewed ? 1 : 0)
        .scaleEffect(min(1, orientation.size.width/450))
    }
    
    @ViewBuilder
    var cancelButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Cancel")
        }
        .buttonStyle(RoundedRectangleButtonStyle())
        .scaleEffect(min(1, orientation.size.width/450))
    }
    
    @ViewBuilder
    var resetButton: some View {
        formatRedButton {
            Button {
                defer { state.pending = true }
                
                guard state.pending == false
                else { return }
                
                model.glewRocket.stop {
                    defer { state.pending = false }
                    model.firstRunComplete = false
                    model.objectWillChange.send()
                }
            } label: {
                Text("Reset")
                    .fontWeight(.medium)
            }
        }
        .disabled(state.invalid || state.pending)
        .saturation(state.invalid ? 0 : 1)
        .scaleEffect(min(1, orientation.size.width/450))
    }
    
    @ViewBuilder
    var deleteText: Text {
        Text("Enter the word ")
        + Text("DELETE")
            .fontWeight(.medium)
            .foregroundColor(Color("fltrBackgroundInverted"))
        + Text(" in the text field below to confirm ")
        + Text("removal")
            .fontWeight(.medium)
            .foregroundColor(Color("fltrBackgroundInverted"))
        + Text(".\n\n")
        + Text("The wallet will be ")
        + Text("reset")
            .fontWeight(.medium)
            .foregroundColor(Color("fltrBackgroundInverted"))
        + Text(" and you will be taken back to the first view. You will then be given the option to create a ")
        + Text("new wallet")
            .fontWeight(.medium)
            .foregroundColor(Color("fltrBackgroundInverted"))
        + Text(" or ")
        + Text("recover")
            .fontWeight(.medium)
            .foregroundColor(Color("fltrBackgroundInverted"))
        + Text(" a previous one.")
    }
    
    var body: some View {
        TwoPane { goRight in
            VStack(alignment: .leading) {
                text1
                .fontWeight(.light)
                .padding(.vertical)
                .padding(.horizontal, 50)
                
                balanceBox
                .padding(.horizontal)

                (text2 + text3)
                .fontWeight(.light)
                .padding(.vertical)
                .padding(.horizontal, 50)

                HStack {
                    reviewButton

                    Spacer(minLength: 0)
                    
                    continueButton(goRight)
                }
                .padding(.vertical)
                .padding(.horizontal, 20)
            }
        } right: { _ in
            VStack {
                deleteText
                .fontWeight(.light)
                .padding(.vertical)
                .padding(.horizontal, 50)

                SendField(placeholder: "Confirm",
                          data: $state.word,
                          error: state.wordError)
                    .padding(.vertical)
                    .frame(maxWidth: 200)
            
                HStack {
                    cancelButton
                    
                    Spacer(minLength: 0)
                    
                    resetButton
                }
                .padding(.vertical)
                .padding(.horizontal, 20)
            }
            .onAppear {
                state.start()
            }
            .onDisappear {
                state.stop()
            }
        }
        .frame(maxWidth: 550)
        .frame(maxWidth: .infinity)
        .foregroundColor(Color("newGray"))
        .padding(.vertical, 15)
        .fullScreenCover(isPresented: $review.cover, onDismiss: { review.cover = false }) {
            ResetView.WordsReview(didReview: review.didReview)
            .environmentObject(model)
            .environmentObject(orientation)
        }
    }
}

extension ResetView {
    struct WordsReview: View {
        var didReview: () -> Void
        @StateObject var words: WordsState = .init()
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            WordsView(words: words.words) {
                defer {
                    presentationMode.wrappedValue.dismiss()
                    words.reset()
                }
                
                guard $0
                else { return }
                
                didReview()
            }
            .combine(words)
            .onDisappear(perform: words.reset)
        }
    }
}

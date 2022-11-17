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

public enum SpinnerAfterSync {}

extension SpinnerAfterSync {
    final class SpinnerModel: CombineObservable, ObservableObject {
        @Published var syncCompleted: Bool = false
        @Published var spinner: Bool = false
        var cancellables: Set<AnyCancellable> = []
        
        func startPublishers(_ model: AppDelegate) {
            $syncCompleted
                .combineLatest(model.$synched)
                .map { completed, synched -> Bool in
                    guard completed
                    else { return false }
                    
                    return !synched
                }
                .removeDuplicates()
                .sink { value in
                    withAnimation {
                        self.spinner = value
                    }
                }
                .store(in: &cancellables)
        }
    }
}

public extension SpinnerAfterSync {
    struct SpinnerAfterSyncViewModifier: ViewModifier {
        @EnvironmentObject var syncModel: SyncModel
        @StateObject var spinnerModel: SpinnerModel = .init()
        let longPadding: CGFloat?
        let latPadding: CGFloat?

        public func body(content: Content) -> some View {
            ZStack {
                content

                LongStack(spacing: 0) {
                    LatStack(spacing: 0) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .zIndex(1_000_000)
                            .opacity(spinnerModel.spinner ? 1 : 0)
                    } c2: {
                        Spacer()
                    }
                } c2: {
                    Spacer()
                }
                .padding(.longBeforeAfter, longPadding ?? 0)
                .padding(.latBeforeAfter, latPadding ?? 10)

            }
            .onAppear {
                syncModel.$completed
                .assign(to: \.syncCompleted, on: spinnerModel)
                .store(in: &spinnerModel.cancellables)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .combine(spinnerModel)
        }
    }
}

public extension View {
    func spinnerAfterSync(longPadding: CGFloat? = nil,
                          latPadding: CGFloat? = nil) -> some View {
        self.modifier(SpinnerAfterSync.SpinnerAfterSyncViewModifier(longPadding: longPadding, latPadding: latPadding))
    }
}

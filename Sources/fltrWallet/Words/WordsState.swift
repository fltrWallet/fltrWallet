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
import fltrBtc
import SwiftUI

final class WordsState: ObservableObject, CombineObservable {
    @Published var words: [String]?
    var cancellables: Set<AnyCancellable> = .init()
    
    init() {
        self.reset()
    }
    
    func startPublishers(_ model: AppDelegate) {
        model.$running
            .filter { $0 }
            .map { _ in () }
            .map {
                model.glewRocket.loadPrivateKey()
                    .map(Vault.WalletSeedCodable?.init)
                    .replaceError(with: nil)
            }
            .switchToLatest()
            .map {
                $0.flatMap {
                    BIP39.words(fromRandomness: $0.entropy, language: $0.language)
                }
            }
            .map {
                $0?.words()
            }
            .sink { words in
                withAnimation(.easeInOut(duration: 1)) {
                    self.words = words
                }
            }
            .store(in: &cancellables)
    }
    
    func reset() {
        self.words = (0..<12).map { _ in "..." }
    }
}

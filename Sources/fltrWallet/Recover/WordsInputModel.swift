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
import LoadNode
import SwiftUI

extension WordsInputModel {
    struct Word: Hashable, Identifiable, ExpressibleByStringLiteral, CustomStringConvertible {
        var description: String { self.value }
        var id: String { self.value }
        var value: String
        
        init(stringLiteral value: String) {
            self.value = value
        }
    }
    
    enum WordsInputError: Swift.Error {
        case empty([Array<Word>.Index])
    }

    typealias WordsResult = Result<[Word], WordsInputError>
}

final class WordsInputModel: CombineObservable, ObservableObject {
    var cancellables: Set<AnyCancellable> = []
    
    #if DEBUG
    @Published var words: [Word] = [ "abandon",
                                     "abandon",
                                     "abandon",
                                     "abandon",
                                     "abandon",
                                     "abandon",
                                     "abandon",
                                     "abandon",
                                     "abandon",
                                     "abandon",
                                     "abandon",
                                     "about", ]
    #else
    @Published var words: [Word] = [ "", "", "", "",
                                     "", "", "", "",
                                     "", "", "", "" ]
    #endif
    
    @Published var year: Load.ChainYear?
    @Published var errors: [String?] = .init(repeating: nil, count: 12)
    @Published var submitError: Bool = false
    var disableSubmit: Bool = true
    var submitBusy: Bool = false
    
    @Published var submitPress: Void = ()
    func startPublishers(_ appDelegate: AppDelegate) {
        $errors
            .map {
                $0.reduce(true) { $0 && $1 == nil }
            }
            .combineLatest($words)
            .map { noError, words in
                words.reduce(false) {
                    $0 || $1.value == ""
                } || !noError
            }
            .assign(to: \.disableSubmit, on: self)
            .store(in: &cancellables)
        
        
        self.combiner
            .combineLatest($year)
            .sink {
                do {
                    guard !self.submitBusy
                    else { return }
                    
                    let words = try $0.0.get()
                        .map(\.value)
                        .map(cleanup(_:))
                    guard let decode = appDelegate.glewRocket.bip39Decode(words: words),
                          let year = $0.1
                    else {
                        self.submitError = true
                        return
                    }
                    precondition(decode.count == 16)
                    self.disableSubmit = true
                    self.submitBusy = true
                    appDelegate.glewRocket.firstRun(entropy: decode, year: year) { result in
                        guard let _ = try? result.get()
                        else {
                            DispatchQueue.main.async {
                                self.submitError = true
                                self.submitBusy = false
                            }
                            return
                        }
                        
                        DispatchQueue.main.async {
                            appDelegate.firstRunComplete = true
                            appDelegate.objectWillChange.send()
                        }
                    }
                } catch {
                    self.submitError = true
                }
            }
            .store(in: &cancellables)
        
        func cleanup(_ value: String) -> String {
            value
                .trimmingCharacters(in: .whitespaces)
                .lowercased()
        }
        
        changed($words)
            .compactMap { opt -> (Int, String, [String])? in
                guard let opt = opt
                else { return nil }
                
                let lowercased = cleanup(opt.value.value)
                let results = appDelegate.glewRocket.validate(lowercased)
                return (opt.index, lowercased, results)
            }
            .map { index, inputWord, results -> AnyPublisher<(Int, String?), Never> in
                let errorPublisher: AnyPublisher<String?, Never> = {
                    if results.count == 0 {
                        return Just("❌ invalid word")
                            .delay(for: 0.5, scheduler: DispatchQueue.main)
                            .eraseToAnyPublisher()
                    } else if results.contains(inputWord) {
                        return Just(nil)
                            .eraseToAnyPublisher()
                    } else {
                        return Just(results.map(\.capitalized).joined(separator: ", "))
                            .eraseToAnyPublisher()
                    }
                }()
                
                let checksumPublisher: AnyPublisher<String?, Never> = {
                    if results.contains(inputWord) {
                        let words: [String] = {
                            var copy = self.words.map(\.value)
                            copy[index] = inputWord
                            return copy
                        }()
                        
                        guard words.reduce(true, { $0 && !$1.isEmpty })
                        else { return Just(nil).eraseToAnyPublisher() }
                        
                        return appDelegate.glewRocket.bip39DecodeAsync(words: words.map(cleanup(_:)))
                            .map { _ in nil }
                            .replaceError(with: "❌ invalid checksum")
                            .eraseToAnyPublisher()
                    } else {
                        return Just(nil).eraseToAnyPublisher()
                    }
                }()
                
                let mappedErrorPublisher = errorPublisher.map { (index, $0) }
                let mappedChecksumPublisher = checksumPublisher.map { (11, $0) }

                return mappedErrorPublisher
                    .combineLatest(mappedChecksumPublisher)
                    .map { error, checksum -> [(Int, String?)] in
                        if let _ = checksum.1  {
                            return [ error, checksum ]
                        } else {
                            return [ checksum, error ]
                        }
                    }
                    .flatMap {
                        $0.publisher
                    }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .sink {
                self.errors[$0.0] = $0.1
            }
            .store(in: &cancellables)
            
    }
    
    var wordsResult: AnyPublisher<WordsResult, Never> {
        $words
        .removeDuplicates()
        .debounce(for: 0.2, scheduler: DispatchQueue.main)
        .map { words in
            func hasEmpty() -> [Array<Word>.Index] {
                words.indices
                .compactMap {
                    words[$0].value.isEmpty ? $0 : nil
                }
            }
            
            let errorIndices = hasEmpty()
            guard errorIndices.isEmpty
            else {
                return .failure(.empty(errorIndices))
            }

            return .success(words)
        }
        .eraseToAnyPublisher()
    }

    func submitEvent<T: Publisher>(_ publisher: T) -> AnyPublisher<T.Output, Never>
    where T.Failure == Never {
        let submitter = $submitPress.dropFirst()
            .scan(0) { last, _ in
                last + 1
            }
        
        return publisher
            .combineLatest(submitter)
            .removeDuplicates {
                $0.1 == $1.1
            }
            .map(\.0)
            .eraseToAnyPublisher()
    }
    
    func changed<T: Publisher, E>(_ publisher: T) -> AnyPublisher<(index: Int, value: E)?, Never>
    where T.Output == Array<E>, E: Equatable, T.Failure == Never {
        publisher
        .scan((Array<E>(), Array<E>())) { acc, next in
            (acc.1, next)
        }
        .map { last, current in
            guard last.count == current.count
            else {
                return nil
            }
            
            return zip(last, current)
            .enumerated()
            .compactMap { index, z in
                z.0 == z.1 ? nil : (index, z.1)
            }
            .first
        }
        .eraseToAnyPublisher()
    }
    
    var combiner: AnyPublisher<WordsResult, Never> {
        submitEvent(wordsResult)
            .eraseToAnyPublisher()
    }
}

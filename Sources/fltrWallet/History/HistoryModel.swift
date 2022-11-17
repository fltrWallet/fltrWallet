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
import fltrVault
import SwiftUI

extension NewHistoryView {
    final class HistoryModel: ObservableObject, CombineObservable {
        @Published var history: (History, [Int : UInt32])? = nil
        @Published var confirmedFilter: [History.InOut]?
        @Published var pendingFilter: [History.InOut]?
        @Published var receivedSent: ReceivedSent = .all
        @Published var detail: History.InOut?
        @Published var unit: CurrencyUnit? = nil
        @Published var displayUnits: Bool = false
        var dispatchWorkItemCopyAnimation: DispatchWorkItem?
        var cancellables: Set<AnyCancellable> = []
        var error: VaultApiError?
        
        private func filterHelper(receivedSent: ReceivedSent,
                                  history: History,
                                  pending: Bool) -> [History.InOut]? {
            let result: [History.InOut] = {
                switch receivedSent {
                case .all:
                    return pending ? history.pending : history.confirmed
                case .received:
                    return history.received(pending: pending)
                case .sent:
                    return history.sent(pending: pending)
                }
            }()
            
            return result.isEmpty ? nil : result
        }

        private var confirmedFilterPublisher: AnyPublisher<[History.InOut]?, Never> {
            $history.combineLatest($receivedSent) {
                guard let (history, _) = $0
                else {
                    return nil
                }

                return self.filterHelper(receivedSent: $1, history: history, pending: false)
            }
            .eraseToAnyPublisher()
        }
        
        private var pendingFilterPublisher: AnyPublisher<[History.InOut]?, Never> {
            $history.combineLatest($receivedSent) {
                guard let (history, _) = $0
                else {
                    return nil
                }

                return self.filterHelper(receivedSent: $1, history: history, pending: true)
            }
            .eraseToAnyPublisher()
        }
        
        func startPublishers(_ appDelegate: AppDelegate) {
            appDelegate.refresh(
                appDelegate.glewRocket.history()
            )
            .receive(on: DispatchQueue.main)
            .sink { result in
                switch result {
                case .success(let history):
                    self.history = history
                    if let detail = self.detail,
                       detail.record.pending,
                       let confirmed = history.0.confirmed.first(where: {
                           $0.record.txId == detail.record.txId
                           && $0.incoming == detail.incoming
                       }) {
                        self.detail = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(2)) {
                            self.detail = confirmed
                        }
                    }
                case .failure(let error):
                    guard self.error == nil
                    else { return }
                    self.error = VaultApiError(error)
                }
            }
            .store(in: &cancellables)
            
            self.confirmedFilterPublisher
                .assign(to: \.confirmedFilter, on: self)
                .store(in: &cancellables)
            
            self.pendingFilterPublisher
                .assign(to: \.pendingFilter, on: self)
                .store(in: &cancellables)
        }
        
        func format(amount: UInt64, incoming: Bool) -> Text {
            var string: [Text] = []
            if !incoming {
                string.append(Text("-"))
            }

            let amountText = Text("\(self.unit?.toString(amount) ?? CurrencyUnit.bestString(amount))")
            string.append(amountText)

            if incoming {
                return string.reduce(Text(""), +)
                    .fontWeight(.medium)
                    .foregroundColor(Color("fltrGreen"))
            } else {
                return string.reduce(Text(""), +)
                    .fontWeight(.light)
                    .foregroundColor(Color("newGray"))
            }
        }
    }
}

extension NewHistoryView.HistoryModel {
    enum ReceivedSent: UInt8, Hashable, Identifiable {
        case all
        case received
        case sent
        
        var id: UInt8 { self.rawValue }
    }
}

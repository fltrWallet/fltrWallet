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
import Dispatch

public extension AppDelegate {
    var transactionTrigger: AnyPublisher<Void, Never> {
        self.$pending.prepend(self.pending)
        .combineLatest(self.$active.prepend(self.active))
        .map { pending, active in (pending: pending, active: active) }
        .combineLatest(self.$running.prepend(self.running))
        .filter { _, running in running }
        .map { _, _ in () }
        .debounce(for: 0.1, scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

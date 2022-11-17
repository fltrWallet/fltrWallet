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

public protocol CombineObservable: AnyObject {
    var cancellables: Set<AnyCancellable> { get set }
    
    func startPublishers(_: AppDelegate)
    func stopPublishers()
}

public extension CombineObservable {
    func stopPublishers() {
        let cancellables = self.cancellables
        self.cancellables.removeAll()
        cancellables.forEach { $0.cancel() }
    }
}

public struct CombineObservableViewModifier<Model: CombineObservable & ObservableObject>: ViewModifier {
    @EnvironmentObject var model: AppDelegate
    var dependency: Model
    
    public func body(content: Content) -> some View {
        content
        .onAppear {
            dependency.startPublishers(model)
        }
        .onDisappear {
            dependency.stopPublishers()
        }
    }
}

public extension View {
    func combine<Model: CombineObservable & ObservableObject>(_ model: Model) -> some View {
        self.modifier(CombineObservableViewModifier(dependency: model))
    }
}

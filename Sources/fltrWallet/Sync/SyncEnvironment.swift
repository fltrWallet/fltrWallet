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

public struct SyncEnvironment<Content: View>: View {
    @StateObject var syncModel: SyncModel = .init()
    
    var content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content()
        .environmentObject(syncModel)
        .combine(syncModel)
        .onReceive(
            syncModel.$completed
            .first(where: { $0 })
        ) { _ in
            syncModel.stopPublishers()
        }
    }
}

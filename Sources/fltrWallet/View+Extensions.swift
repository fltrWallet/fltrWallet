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

public extension View {
    func onNotification(name: Notification.Name,
                        perform action: @escaping () -> Void) -> some View {
        self.onReceive(NotificationCenter.default.publisher(for: name)) { _ in
            action()
        }
    }
    
    func onMemoryWarning(perform action: @escaping () -> Void) -> some View {
        #if os(macOS)
        self
        #else
        self.onNotification(name: UIApplication.didReceiveMemoryWarningNotification,
                            perform: action)
        #endif
    }
}

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

final class SendSheetModel: ObservableObject {
    enum SendMode: UInt8, Identifiable {
        case send
        case scan
        
        var id: UInt8 { self.rawValue }
    }
    
    @Published var sendOrScan: SendMode?
    @Published var address: AddressDecoder?
    @Published var amount: UInt64?
    
    let swooshSound = PlaySound(name: "swoosh", extension: .mp3)
    let haptics = Haptics.init()
    
    func reset() {
        self.address = nil
        self.amount = nil
        self.sendOrScan = nil
    }

    func startScan() {
        assert(self.sendOrScan == nil)

        self.sendOrScan = .scan
    }

    func startSend() {
        assert(self.sendOrScan == nil)
        
        self.sendOrScan = .send
    }
    
    func dismissScan() {
        assert(self.sendOrScan == .scan)
        
        if self.address == nil {
            self.sendOrScan = nil
        } else {
            self.sendOrScan = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(10)) {
                self.sendOrScan = .send
            }
        }
    }
    
    func dismissSend() {
        assert(self.sendOrScan == .send)

        self.reset()
    }
    
    func succeedSend() {
        self.swooshSound?.play()
        self.haptics?.success()
        self.dismissSend()
    }
}

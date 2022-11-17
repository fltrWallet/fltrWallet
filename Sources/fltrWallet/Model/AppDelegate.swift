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
import fltrBtc
import SwiftUI

public final class AppDelegate: NSObject, ObservableObject {
    // Lifecycle
    @Published public var background: Bool // BGTask launch
    @AppStorage("firstRunComplete") public var firstRunComplete: Bool = false
    @Published public var running: Bool
    @Published public var suspended: Bool

    // Funds
    @Published public var active: UInt64
    @Published public var pending: UInt64

    // Height and sync
    @Published public var compactFilterEvent: CompactFilterEvent? = nil
    @Published public var estimatedHeight: Int
    @Published public var tip: Int
    @Published public var synched: Bool
    
    @Published public var feeEstimate: FeeEstimate?
    @Published public var feeEstimateTrigger: Void = ()

    public private(set) var glewRocket: GlewRocket<AppDelegate>

    public let coinSound: PlaySound? = .init(name: "coins", extension: .wav)
    
    public init(background: Bool,
                running: Bool,
                suspended: Bool,
                active: UInt64,
                pending: UInt64,
                estimatedHeight: Int,
                tip: Int,
                synched: Bool,
                glewRocket: GlewRocket<AppDelegate>) {
        self.background = background
        self.running = running
        self.suspended = suspended
        self.active = active
        self.pending = pending
        self.estimatedHeight = estimatedHeight
        self.tip = tip
        self.synched = synched
        self.glewRocket = glewRocket
    }
    
    override public convenience init() {
        #if DEBUG
        let glewRocket: GlewRocket<AppDelegate> = {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] ?? "0" == "1" {
                return GlewRocket { NodeVaultLauncherTesting() }
            } else {
                return GlewRocket(launcher: { NodeVaultLauncher() })
            }
        }()
        #else
        let glewRocket: GlewRocket<AppDelegate> = GlewRocket(launcher: {
            NodeVaultLauncher()
        })
        #endif

        self.init(background: false,
                  running: false,
                  suspended: false,
                  active: 0,
                  pending: 0,
                  estimatedHeight: -1,
                  tip: -1,
                  synched: false,
                  glewRocket: glewRocket)
    }
}

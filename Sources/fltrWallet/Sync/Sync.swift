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
import struct UIKit.CGFloat
import SwiftUI

struct Sync {
    private var state: State = .init()
    
    static let FiltersRatio: CGFloat = 0.8
    static var BlocksRatio: CGFloat { 1 - Self.FiltersRatio }
}

extension Sync {
    final class State {
        var filterFloor: Int = 0
        var filterCeiling: Int?
        var processedFilters: Int = 0
        var finished = false

        @AppStorage("syncExpectedBlocks") var expectedBlocks: Int = 1
        @AppStorage("syncProcessedBlocks") var processedBlocks: Int = 0
    }

    enum Match {
        case matching(Int)
        case nonMatching(Int)
        
        var height: Int {
            switch self {
            case .matching(let height),
                 .nonMatching(let height):
                return height
            }
        }
        
        var isMatching: Bool {
            switch self {
            case .matching:
                return true
            case .nonMatching:
                return false
            }
        }
    }
}

extension Sync.State {
    func reset() {
        self.filterFloor = 0
        self.filterCeiling = 0
        self.processedFilters = 0
        self.expectedBlocks = 1
        self.processedBlocks = 0
        self.finished = false
    }
    
    var expectedFilters: Int {
        if let filterCeiling = self.filterCeiling {
            assert(self.filterFloor <= filterCeiling)
            return filterCeiling - self.filterFloor
        } else {
            return 100_000
        }
    }
    
    private var filters: CGFloat {
        guard self.expectedFilters > 0
        else { return 0 }
        
        return min(CGFloat(self.processedFilters) / CGFloat(self.expectedFilters), 1) * Sync.FiltersRatio
    }
    
    private var blocks: CGFloat {
        guard self.expectedBlocks > 0
        else { return 0 }
        
        if self.expectedBlocks > 6 {
            return CGFloat(self.processedBlocks) / CGFloat(self.expectedBlocks) * Sync.BlocksRatio
        } else {
            return CGFloat(self.processedBlocks) * Sync.BlocksRatio * Sync.BlocksRatio
        }
    }
    
    var completion: CGFloat {
        return self.filters + self.blocks
    }
}

extension Sync {
    func reset() {
        self.state.reset()
    }
    
    mutating func set(height: Int) {
        if let filterCeiling = self.state.filterCeiling {
            self.state.filterCeiling = max(filterCeiling, height)
        } else {
            self.state.filterCeiling = height
        }
    }
    
    mutating func download(filterHeight: Int) {
        if self.state.filterFloor == 0 {
            self.state.filterFloor = filterHeight
        } else {
            self.state.filterFloor = min(self.state.filterFloor, filterHeight)
        }
    }

    mutating func completeFilter(with match: Match) {
        if match.isMatching {
            self.state.expectedBlocks += 1
        }
        
        self.state.processedFilters += 1
    }
    
    mutating func completeDownload(blockHeight: Int) {
        self.state.processedBlocks += 1
        
        guard self.state.expectedBlocks > self.state.processedBlocks
        else {
            self.state.expectedBlocks = self.state.processedBlocks + 1
            return
        }
    }
    
    mutating func synched() {
        self.state.processedFilters = 1
        self.state.filterFloor = 1
        self.state.filterCeiling = 2
        self.state.processedBlocks = 10
        self.state.expectedBlocks = 10
        self.state.finished = true
    }
    
    var completion: CGFloat {
        self.state.completion
    }
    
    var finished: Bool {
        self.state.finished
    }
}

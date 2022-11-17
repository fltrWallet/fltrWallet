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

final class SyncModel: ObservableObject, CombineObservable {
    @Published var completed: Bool = false
    @Published var completion: CGFloat = .zero
    
    var sync = Sync()
    
    var cancellables: Set<AnyCancellable> = .init()
    
    func startPublishers(_ model: AppDelegate) {
        model.$estimatedHeight
        .combineLatest(model.$tip)
        .map { max($0.0, $0.1) }
        .filter { $0 > 0 }
        .removeDuplicates()
        .sink {
            self.sync.set(height: $0)
        }
        .store(in: &cancellables)
        
        let sharedResult = model.$compactFilterEvent
        .combineLatest(model.$synched)
        .tryMap { event, sync -> (CompactFilterEvent?, Bool) in
            if sync {
                self.sync.synched()
                
                return (.none, false)
            }
            
            return (event, sync)
        }
        .filter {
            !$0.1
        }
        .map(\.0)
        .map { event -> (CGFloat, Bool) in
            switch event {
            case .download(let height):
                self.sync.download(filterHeight: height)
            case .matching(let height):
                self.sync.completeFilter(with: .matching(height))
            case .nonMatching(let height):
                self.sync.completeFilter(with: .nonMatching(height))
            case .blockMatching(let height),
                 .blockNonMatching(let height):
                self.sync.completeDownload(blockHeight: height)
            case .none, .blockDownload, .blockFailed, .failure:
                break
            }
            
            return (self.sync.completion, self.sync.finished)
        }
        .share()
        
        sharedResult
        .mapError { error -> Swift.Error in
            logger.error("SyncModel \(#function) - Error: \(error)")
            return error
        }
        .replaceError(with: (2, false))
        .sink {
            if $0.1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
                    withAnimation(.linear(duration: 0.5)) {
                        self.completed = true
                    }
                    
                    self.sync.reset()
                }
            }
            
            self.completion = $0.0
        }
        .store(in: &cancellables)
    }
}

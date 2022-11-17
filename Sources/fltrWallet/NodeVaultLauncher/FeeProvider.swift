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
import Foundation
import HaByLo

public extension NodeVaultLauncher {
    private struct FeeDto: Decodable {
        let fastestFee: Double
        let halfHourFee: Double
        let hourFee: Double
        let minimumFee: Double
    }
    
    func fees<Trigger: Publisher>(trigger: Trigger) -> AnyPublisher<Result<FeeEstimate, VaultApiError>, Never>
    where Trigger.Output == Void, Trigger.Failure == Never {
        let url = URL(string: "https://mempool.space/api/v1/fees/recommended")!
        let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

        func download(retry: Int, delay: DispatchQueue.SchedulerTimeType.Stride) -> AnyPublisher<FeeDto, Error> {
            URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: FeeDto.self, decoder: JSONDecoder())
            .delayedRetry(retry, delay: delay, scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
        }
        
        func prebounce(within: TimeInterval) -> AnyPublisher<Void, Never> {
            timer.prepend(Date())
            .combineLatest(trigger.map { Date() })
            .map { lhs, rhs in
                lhs > rhs ? lhs : rhs
            }
            .scan(Date()) { oldDate, newDate in
                if newDate.timeIntervalSince(oldDate) > within {
                    return newDate
                } else {
                    return oldDate
                }
            }
            .removeDuplicates()
            .map { _ in () }
            .eraseToAnyPublisher()
        }
        
        return
            prebounce(within: 12)
            .map {
                download(retry: 3, delay: 3)
                .map {
                    FeeEstimate(low: $0.hourFee, medium: $0.halfHourFee, high: $0.fastestFee)
                }
                .map(Result<FeeEstimate, VaultApiError>.success)
                .replaceError(with: .failure(.feeRateNil))
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

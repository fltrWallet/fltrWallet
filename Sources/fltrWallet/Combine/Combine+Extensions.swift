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

public enum DelayedRetryOutcome<Output, Failure: Error> {
    case retryDelay
    case handled(AnyPublisher<Output, Failure>)
}

public extension Publisher {
    @inlinable
    func delayedRetry<S: Scheduler>(_ retries: Int,
                                    delay: S.SchedulerTimeType.Stride,
                                    scheduler: S,
                                    errorHandler: ((Failure) -> DelayedRetryOutcome<Output, Failure>)? = nil)
    -> AnyPublisher<Output, Failure> {
        
        return self.catch { error -> AnyPublisher<Output, Failure> in
            if let errorHandler = errorHandler {
                switch errorHandler(error) {
                case .handled(let publisher):
                    return publisher
                case .retryDelay:
                    break
                }
            }
            
            return Just(())
                .delay(for: delay, scheduler: scheduler)
                .flatMap { _ in self }
                .retry(retries > 0 ? retries - 1 : 0)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

public extension Timer {
    static func wallTimePublisher(interval: Double) -> AnyPublisher<Void, Never> {
        Timer.publish(every: 1, on: RunLoop.main, in: .common)
        .autoconnect()
        .scan(Date()) { startDate, currentDate in
            if currentDate.timeIntervalSince(startDate) > interval {
                return currentDate
            } else {
                return startDate
            }
        }
        .removeDuplicates()
        .map { _ in () }
        .dropFirst()
        .eraseToAnyPublisher()
    }
}

public extension Publisher where Failure == Never {
    func consumeError<WrappedSuccess, WrappedError>() -> Publishers.FlatMap<AnyPublisher<WrappedSuccess, Never>, Self>
    where WrappedError: Swift.Error, Output == Result<WrappedSuccess, WrappedError> {
        self.flatMap { result -> AnyPublisher<WrappedSuccess, Never> in
            switch result {
            case .success(let value):
                return Just(value)
                    .eraseToAnyPublisher()
            case .failure:
                return Empty(completeImmediately: false)
                    .eraseToAnyPublisher()
            }
        }
    }

    func unwrapError<WrappedSuccess, WrappedError>() -> Publishers.Map<Self, WrappedError?>
    where WrappedError: Swift.Error, Output == Result<WrappedSuccess, WrappedError> {
        self.map { result in
            switch result {
            case .failure(let error):
                return error
            case .success:
                return nil
            }
        }
    }

    func readError<WrappedSuccess, WrappedError>() -> Publishers.Map<Self, String?>
    where WrappedError: Swift.Error & CustomStringConvertible, Output == Result<WrappedSuccess, WrappedError> {
        self.map {
            switch $0 {
            case .failure(let value):
                return value.description
            case .success:
                return nil
            }
        }
    }
    
    func readError<WrappedSuccess, WrappedError>() -> Publishers.Map<Self, String?>
    where WrappedError: Swift.Error & CustomStringConvertible, Output == Result<WrappedSuccess, WrappedError>? {
        self.map {
            switch $0 {
            case .failure(let value):
                return String(describing: value)
            case .success, .none:
                return nil
            }
        }
    }
    
    func dropEmpty<WrappedSuccess>() -> Publishers.Map<Self, Result<WrappedSuccess, SendModel.AddressError>?>
    where Output == Result<WrappedSuccess, SendModel.AddressError> {
        self.map { result in
            switch result {
            case .failure(.empty):
                return nil
            default:
                return .some(result)
            }
        }
    }

    func dropEmpty<WrappedSuccess>() -> Publishers.Map<Self, Result<WrappedSuccess, SendModel.AmountError>?>
    where Output == Result<WrappedSuccess, SendModel.AmountError> {
        self.map { result in
            switch result {
            case .failure(.empty):
                return nil
            default:
                return .some(result)
            }
        }
    }
}

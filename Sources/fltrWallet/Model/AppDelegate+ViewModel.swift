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

extension AppDelegate: ViewModel {
    public var synchedPublisher: Published<Bool>.Publisher {
        self.$synched
    }
}

public extension AppDelegate {
    func refresh<P: Publisher>(_ publisher: P) -> AnyPublisher<Result<P.Output, P.Failure>, Never> {
        self.transactionTrigger
        .map { publisher }
        .switchToLatest()
        .delayedRetry(3,
                      delay: 0.05,
                      scheduler: DispatchQueue.main) { error in
            switch error {
            case let apiError as VaultApiError:
                switch apiError {
                case .internalError:
                    return .retryDelay
                default:
                    return .handled(Fail(error: error).eraseToAnyPublisher())
                }
            case let txError as GlewRocket<AppDelegate>.TransactionsError:
                switch txError {
                case .serviceUnavailable:
                    return .retryDelay
                default:
                    return .handled(Fail(error: error).eraseToAnyPublisher())
                }
            case let keyError as GlewRocket<AppDelegate>.PrivateKeyError:
                switch keyError {
                case .serviceUnavailable:
                    return .retryDelay
                default:
                    return .handled(Fail(error: error).eraseToAnyPublisher())
                }
            case is ServiceUnavailable:
                return .retryDelay
            default:
                return .handled(Fail(error: error).eraseToAnyPublisher())
            }
        }
        .map(Result<P.Output, P.Failure>.success)
        .catch { error in
            Just(Result<P.Output, P.Failure>.failure(error))
        }
        .eraseToAnyPublisher()
    }
    
    func refreshSingle<P: Publisher>(_ publisher: P) -> AnyPublisher<P.Output, P.Failure> {
        self.refresh(publisher)
        .first()
        .map { result -> AnyPublisher<P.Output, P.Failure> in
            switch result {
            case .success(let output):
                return Just(output)
                    .setFailureType(to: P.Failure.self)
                    .eraseToAnyPublisher()
            case .failure(let error):
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
}

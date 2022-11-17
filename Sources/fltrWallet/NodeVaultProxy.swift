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
import fltrWAPI
import NIO
import SwiftUI

public struct ServiceUnavailable: Swift.Error {}

public protocol NodeVaultProxy {
    func start(model: ViewModel, callback: @escaping (Result<Void, Swift.Error>) -> Void)
    func stop(callback: @escaping () -> Void)
    
    func newWallet(year: Load.ChainYear, callback: @escaping (Result<[String], Swift.Error>) -> Void)
    func recoverWallet(entropy: [UInt8], year: Load.ChainYear, callback: @escaping (Result<[String], Swift.Error>) -> Void)
    func loadLatestAddress(for: HD.Source, callback: @escaping (Result<String, Swift.Error>) -> Void)
    
    func pay(amount: UInt64, to: AddressDecoder, cost: Double, callback: @escaping (Result<Void, Swift.Error>) -> Void)
    
    func estimateCost(amount: UInt64,
                      to: AddressDecoder,
                      costRate: Double,
                      callback: @escaping (Result<UInt64, Swift.Error>) -> Void)
    
    func loadPrivateKey(callback: @escaping (Result<Vault.WalletSeedCodable, Swift.Error>) -> Void)
    
    func history(callback: @escaping (Result<(History, [Int : UInt32]), Swift.Error>) -> Void)
    
    func fees<Trigger: Publisher>(trigger: Trigger) -> AnyPublisher<Result<FeeEstimate, VaultApiError>, Never>
    where Trigger.Output == Void, Trigger.Failure == Never
    
    var selectableYears: SelectableYears { get }
}

public struct FeeEstimate: Equatable {
    public let low: Double
    public let medium: Double
    public let high: Double

    public init(low: Double, medium: Double, high: Double) {
        self.low = low
        self.medium = medium
        self.high = high
    }
}

public struct NodeVaultLauncherTesting: NodeVaultProxy {
    public init() {}
    
    public func start(model: ViewModel, callback: @escaping (Result<Void, Error>) -> Void) {
        callback(.success(()))
    }
    
    public func stop(callback: @escaping () -> Void) {
        callback()
    }

    public func recoverWallet(entropy: [UInt8], year: Load.ChainYear, callback: @escaping (Result<[String], Error>) -> Void) {
        callback(.success([ "zoo", "zoo", "zoo", "zoo",
                            "zoo", "zoo", "zoo", "zoo",
                            "zoo", "zoo", "zoo", "wrong", ]))
    }
    
    public func newWallet(year: Load.ChainYear, callback: @escaping (Result<[String], Error>) -> Void) {
        callback(.success([ "zoo", "zoo", "zoo", "zoo",
                            "zoo", "zoo", "zoo", "zoo",
                            "zoo", "zoo", "zoo", "wrong", ]))
    }
    
    public func loadLatestAddress(for repo: HD.Source, callback: @escaping (Result<String, Swift.Error>) -> Void) {
        switch repo {
        case .legacySegwit:
            callback(.success("2N79iuGdaQ1wFVUg7WYp3zCR6zAz321rzda"))
        case .segwit:
            callback(.success("tb1qhrkymgvsw9sjq2zvhjyjpc746kemvdywv46a57"))
        case .taproot:
            callback(.success("tb1pkqzpezwsxug0l359k6xg9tklavjwmkdla426wnjpzgyy55r45gdsyxv8de"))
        default:
            preconditionFailure()
        }
    }
    
    public func pay(amount: UInt64, to: AddressDecoder, cost: Double, callback: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) {
            callback(.success(()))
        }
    }
    
    public func estimateCost(amount: UInt64, to: AddressDecoder, costRate: Double, callback: @escaping (Result<UInt64, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(200)) {
            callback(.success((500)))
        }
    }
    
    public func loadPrivateKey(callback: @escaping (Result<Vault.WalletSeedCodable, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(600)) {
            callback(.success((
                Vault.walletSeedFactory(password: GlobalFltrWalletSettings.BIP39PrivateKeyPassword,
                                        language: GlobalFltrWalletSettings.BIP39SeedLanguage,
                                        seedEntropy: GlobalFltrWalletSettings.BIP39SeedEntropy)
            )))
        }
    }
    
    public func history(callback: @escaping (Result<(History, [Int : UInt32]), Error>) -> Void) {
        func makeHistory() -> History.InOut {
            let constructor = Bool.random() ? History.InOut.incoming : History.InOut.outgoing
            return constructor(.init(pending: Bool.random(),
                                     txId: .makeHash(from: UInt64.random(in: 0 ... .max).bigEndianBytes),
                                     address: "tb1p",
                                     amount: .random(in: 9000...100000),
                                     height: .random(in: 1...10000)))
        }
        
        let dictionary: [Int : UInt32] = {
            var result: [Int : UInt32] = [:]
            for i in UInt32(1)...10 {
                let date: UInt32 = 1635508070 + i
                result[Int(i)] = date
            }
            return result
        }()

        let history = History((1...10).map { _ in makeHistory() })
        callback(.success((history, dictionary)))
    }
    
    public func fees<Trigger: Publisher>(trigger: Trigger) -> AnyPublisher<Result<FeeEstimate, VaultApiError>, Never>
    where Trigger.Output == Void, Trigger.Failure == Never {
        Just(FeeEstimate(low: 11.11, medium: 22.22, high: 33.33))
            .map(Result<FeeEstimate, VaultApiError>.success)
            .eraseToAnyPublisher()
    }
    
    public var selectableYears: SelectableYears {
        .testnet
    }
}

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

public enum VaultApiError: Swift.Error, Identifiable, CustomStringConvertible {
    case unavailable
    case dust
    case feeRateNil
    case illegalAddress
    case illegalCostRate
    case internalError
    case notEnoughFunds(UInt64)
    case txCostEclipse
    case cancel
    
    public var id: String {
        String(describing: self)
    }
    
    public var txCost: UInt64? {
        switch self {
        case .notEnoughFunds(let value):
            return value
        case .cancel, .dust, .feeRateNil, .illegalAddress, .illegalCostRate,
             .internalError, .txCostEclipse, .unavailable:
            return nil
        }
    }
    
    public init(_ error: Swift.Error) {
        switch error {
        case let error as ServiceUnavailable:
            self = .init(error)
        case let error as Vault.PaymentError:
            self = .init(error)
        case let error as KeyChainClient.Error:
            self = .init(error)
        default:
            self = .internalError
        }
    }
    
    public init(_ error: ServiceUnavailable) {
        self = VaultApiError.unavailable
    }
    
    public init(_ error: Vault.PaymentError) {
        self = {
            switch error {
            case Vault.PaymentError.dustAmount:
                return .dust
            case Vault.PaymentError.illegalAddress:
                return .illegalAddress
            case Vault.PaymentError.illegalCostRate:
                return .illegalCostRate
            case Vault.PaymentError.notEnoughFunds(let txCost):
                return .notEnoughFunds(txCost)
            case Vault.PaymentError.transactionCostGreaterThanFunds:
                return .txCostEclipse
            default:
                return .internalError
            }
        }()
    }

    public init(_ error: KeyChainClient.Error) {
        self = {
            switch error {
            case .userCancelledOrFailedAuthentication:
                return .cancel
            case .decryptionFailed, .notFound:
                return .internalError
            }
        }()
    }

    public var description: String {
        switch self {
        case .unavailable:
            return "Network unavailable, please try again"
        case .dust:
            return "Payment amount is too low and below the minimum allowable limit of the Bitcoin network"
        case .feeRateNil:
            return "Cannot fetch current Bitcoin network fees"
        case .illegalAddress:
            return "Payment request failed to an illegal destination address"
        case .illegalCostRate:
            return "Internal error: Payment requested with an illegal nil transaction cost"
        case .internalError:
            return "Internal error"
        case .notEnoughFunds:
            return "Payment amount and transaction cost exceed available funds"
        case .txCostEclipse:
            return "Payment cannot proceed due to total transaction costs exceeding available coins."
        case .cancel:
            return "Authentication was cancelled"
        }
    }
}


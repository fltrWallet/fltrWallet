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
import fltrBtc

public final class SendModel: ObservableObject, CombineObservable {
    struct ConfirmSend: Identifiable {
        let address: String
        let amount: UInt64
        let unit: CurrencyUnit
        let costRate: SendModel.CostRate
        let costEstimate: UInt64
        
        var id: [UInt8] {
            address.ascii
            + amount.littleEndianBytes
            + costRate.id
        }
    }
    
    @Published var address: String = ""
    @Published var addressError: String?
    
    @Published var amount: (UInt64, CurrencyUnit)?
    @Published var amountError: String?
    @Published var decimalAmountError: String?
    
    @Published var costRateClass: CostRateClass = .medium
    @Published var costEstimate: UInt64?
    
    @Published var disabled = true
    @Published var pendingSendDisable = false
    
    @Published var validated: (address: AddressDecoder, amount: UInt64, unit: CurrencyUnit, costRate: CostRate)?
    
    @Published var confirmSend: ConfirmSend?
    
    @Published var error: VaultApiError?
    
    public var cancellables: Set<AnyCancellable> = .init()

    public func startPublishers(_ model: AppDelegate) {
        let amountPublisher = self.amountPublisher(model).share()
        let sharedEstimate = self.estimateCost(model).share()
        
        sharedEstimate
        .map {
            switch $0 {
            case .success(_?):
                return false
            case .success(nil), .failure: return true
            }
        }
        .assign(to: \.disabled, on: self)
        .store(in: &cancellables)
        
        self.addressPublisher
        .dropEmpty()
        .readError()
        .combineLatest(self.estimateCostAddressError(publisher: sharedEstimate))
        .map { addressError, estimateError -> String? in
            switch (addressError, estimateError) {
            case (.some(let error), _),
                 (.none, .some(let error)):
                return error
            case (.none, .none):
                return nil
            }
        }
        .assign(to: \.addressError, on: self)
        .store(in: &cancellables)

        amountPublisher
        .dropEmpty()
        .readError()
        .combineLatest(self.estimateCostAmountError(publisher: sharedEstimate))
        .map { amountError, estimateError -> String? in
            switch (amountError, estimateError) {
            case (.some(let error), _),
                 (.none, .some(let error)):
                return error
            case (.none, .none):
                return nil
            }
        }
        .combineLatest(self.$decimalAmountError)
        .map { amountError, decimalAmountError in
            switch (amountError, decimalAmountError) {
            case (_, .some(let error)),
                 (.some(let error), .none):
                return error
            case (.none, .none):
                return nil
            }
        }
        .assign(to: \.amountError, on: self)
        .store(in: &cancellables)
        
        self.latestValidPublisher(model, amountPublisher)
        .assign(to: \.validated, on: self)
        .store(in: &cancellables)

        sharedEstimate
        .map {
            do {
                return try $0.get()
            } catch (VaultApiError.notEnoughFunds(let txCost)) {
                return txCost
            } catch {
                return nil
            }
        }
        .assign(to: \.costEstimate, on: self)
        .store(in: &cancellables)
        
        $confirmSend
        .filter { $0 != nil }
        .map { _ in
            Timer.wallTimePublisher(interval: 60)
            .first()
        }
        .switchToLatest()
        .prepend(())
        .combineLatest(
            model.$active
                .prepend(model.active)
                .removeDuplicates()
        )
        .combineLatest(
            model.$pending
                .prepend(model.pending)
                .removeDuplicates()
        )
        .dropFirst()
        .map { _ in
            ConfirmSend?.none
        }
        .assign(to: \.confirmSend, on: self)
        .store(in: &cancellables)
        
        Timer.publish(every: 5, on: RunLoop.main, in: .common)
        .autoconnect()
        .map { _ in () }
        .first()
        .sink {
            if model.feeEstimate == nil {
                self.error = .feeRateNil
            }
        }
        .store(in: &cancellables)
    }

    var addressPublisher: AnyPublisher<Result<AddressDecoder, SendModel.AddressError>, Never> {
        self.$address
        .debounce(for: 0.3, scheduler: DispatchQueue.main)
        .removeDuplicates()
        .map { address in
            guard !address.isEmpty
            else {
                return .failure(.empty)
            }
            
            guard let decode = AddressDecoder(decoding: address,
                                              network: GlobalFltrWalletSettings.Network)
            else {
                return .failure(.invalidRecipient)
            }
            
            return .success(decode)
        }
        .eraseToAnyPublisher()
    }

    func estimateCost(_ model: AppDelegate) -> AnyPublisher<Result<UInt64?, VaultApiError>, Never> {
        self.$validated
        .map { data -> AnyPublisher<Result<UInt64?, VaultApiError>, Never> in
            guard let data = data
            else { return Just(.success(nil)).eraseToAnyPublisher() }
            
            return model.refresh(
                model.glewRocket.estimateCost(amount: data.amount,
                                                     to: data.address,
                                                     costRate: data.costRate.costPerVByte)
                .map(UInt64?.init)
                .mapError(VaultApiError.init)
            )
        }
        .switchToLatest()
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    func estimateCostAddressError<P: Publisher>(publisher: P) -> AnyPublisher<String?, Never>
    where P.Output == Result<UInt64?, VaultApiError>, P.Failure == Never {
        publisher
        .map { result -> String? in
            switch result {
            case .failure(.unavailable):
                return String(describing: VaultApiError.unavailable)
            case .failure(.illegalAddress):
                return String(describing: VaultApiError.illegalAddress)
            case .failure(.internalError):
                return String(describing: VaultApiError.internalError)
            case .success, .failure:
                return nil
            }
        }
        .eraseToAnyPublisher()
    }
    
    func estimateCostAmountError<P: Publisher>(publisher: P) -> AnyPublisher<String?, Never>
    where P.Output == Result<UInt64?, VaultApiError>, P.Failure == Never {
        publisher
        .map { result -> String? in
            switch result {
            case .failure(.dust):
                return String(describing: VaultApiError.dust)
            case .failure(.illegalCostRate):
                return String(describing: VaultApiError.illegalCostRate)
            case .failure(.notEnoughFunds(let txCost)):
                return String(describing: VaultApiError.notEnoughFunds(txCost))
            case .failure(.txCostEclipse):
                return String(describing: VaultApiError.txCostEclipse)
            case .failure(.internalError):
                return String(describing: VaultApiError.internalError)
            case .failure(.unavailable):
                return String(describing: VaultApiError.unavailable)
            case .success, .failure:
                return nil
            }
        }
        .eraseToAnyPublisher()
    }
    
    func amountPublisher(_ model: AppDelegate) -> AnyPublisher<Result<(UInt64, CurrencyUnit), SendModel.AmountError>, Never> {
        self.$amount
            .combineLatest(model.$active)
            .removeDuplicates(by: { lhs, rhs in
                lhs.0?.0 == rhs.0?.0 && lhs.1 == rhs.1
            })
            .map { amount, available -> Result<(UInt64, CurrencyUnit), SendModel.AmountError> in
                guard let amountUnit = amount
                else {
                    return .failure(.empty)
                }
                
                let amount = amountUnit.0
                guard amount > GlobalFltrWalletSettings.DustAmount
                else {
                    return .failure(.dust(GlobalFltrWalletSettings.DustAmount))
                }
                
                guard amount < available
                else {
                    return .failure(.insufficient)
                }
                
                return .success(amountUnit)
            }
            .eraseToAnyPublisher()
    }

    func latestValidPublisher(_ model: AppDelegate,
                              _ amountPublisher: Publishers.Share<AnyPublisher<Result<(UInt64, CurrencyUnit), SendModel.AmountError>, Never>>) -> AnyPublisher<(address: AddressDecoder,
                                                                     amount: UInt64,
                                                                     unit: CurrencyUnit,
                                                                     costRate: CostRate)?, Never> {
        self.addressPublisher
        .combineLatest(amountPublisher)
        .map { (latestAddress: $0, latestAmountUnit: $1 ) }
        .combineLatest(self.$costRateClass)
        .map { (latestAddress: $0.latestAddress, latestAmountUnit: $0.latestAmountUnit, costRateClass: $1) }
        .combineLatest(model.$feeEstimate)
        .map { (latestAddress: $0.latestAddress, latestAmountUnit: $0.latestAmountUnit,
                costRateClass: $0.costRateClass, feeEstimate: $1) }
        .map { combined -> (AddressDecoder, UInt64, CurrencyUnit, CostRate)? in
            guard let feeEstimate = combined.feeEstimate
            else { return nil }
            
            let costRate = CostRate(class: combined.costRateClass, feeEstimate: feeEstimate)
            switch (combined.latestAddress, combined.latestAmountUnit) {
            case (.success(let address), .success(let (amount, unit))):
                return (address: address, amount: amount, unit: unit, costRate: costRate)
            case (.success, .failure),
                 (.failure, .success),
                 (.failure, .failure):
                return nil
            }
        }
        .eraseToAnyPublisher()
    }
}

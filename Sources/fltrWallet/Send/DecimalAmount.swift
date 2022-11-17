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

extension SendForm {
    final class DecimalAmount: ObservableObject {
        var cancellables: Set<AnyCancellable> = .init()
        
        @Published var value: String = ""
        @Published var unit: CurrencyUnit?
    }
}

// MARK: Publishers
extension SendForm.DecimalAmount {
    var decimalErrorPublisher: AnyPublisher<String?, Never> {
        self.decimalResult
        .dropEmpty()
        .readError()
        .map { value -> AnyPublisher<String?, Never> in
            if let value = value {
                return Just(.some(value))
                    .delay(for: .seconds(1), scheduler: DispatchQueue.main)
                    .eraseToAnyPublisher()
            } else {
                return Just(nil)
                    .eraseToAnyPublisher()
            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
    
    var decimalResult: AnyPublisher<Result<Decimal, SendModel.AmountError>, Never> {
        $value
        .removeDuplicates()
        .map { amount in
            guard !amount.isEmpty
            else {
                return .failure(.empty)
            }
            
            guard let decimal = Decimal.convert(amount)
            else {
                return .failure(.amount)
            }
            
            return .success(decimal)
        }
        .eraseToAnyPublisher()
    }
    
    var toSatoshis: AnyPublisher<(UInt64, CurrencyUnit)?, Never> {
        self.decimalResult
        .combineLatest(self.$unit)
        .removeDuplicates { lhs, rhs in
            return lhs.0 == rhs.0 && lhs.1 == rhs.1
        }
        .map { (decimal, unit) in
            if let decimal = try? decimal.get() {
                return unit.map {
                    ($0.sats(decimal), $0)
                }
            } else {
                return nil
            }
        }
        .eraseToAnyPublisher()
    }
    
    var autoRoundingCorrection: AnyPublisher<String, Never> {
        self.decimalResult
        .combineLatest(self.$unit)
        .debounce(for: 0.2, scheduler: DispatchQueue.main)
        .removeDuplicates { lhs, rhs in
            lhs.0 == rhs.0 && lhs.1 == rhs.1
        }
        .compactMap { decimal, unit -> String? in
            guard let decimal = try? decimal.get(),
                  let unit = unit
            else { return nil }
            
            var rounded = unit.round(decimal)
            
            guard rounded != decimal
            else { return nil }
            
            return rounded.toString()
        }
        .eraseToAnyPublisher()
    }

    func unitConversion() -> AnyPublisher<String, Never> {
        self.$unit
        .combineLatest(self.decimalResult)
        .removeDuplicates {
            $0.0 == $1.0
        }
        .compactMap { unitOptional, decimalResult in
            unitOptional.map { unit in
                (unit, try? decimalResult.get())
            }
        }
        .scan((self.unit, Decimal?.none)) { previous, next in
            let nextUnit = next.0
            guard let lastUnit = previous.0,
                  let decimal = next.1,
                  previous.0 != next.0
            else {
                return (nextUnit, nil)
            }
            
            let result = decimal * Decimal(lastUnit.rawValue) / Decimal(nextUnit.rawValue)

            return (nextUnit, result)
        }
        .compactMap { $0.1 }
        .map {
            var copy = $0
            return copy.toString()
        }
        .eraseToAnyPublisher()
    }
}

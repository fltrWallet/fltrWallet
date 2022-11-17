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
import SwiftUI

struct TransactionSpeedAndCost: View {
    @Binding var costRate: SendModel.CostRateClass
    let unit: CurrencyUnit?
    let cost: UInt64
    
    var body: some View {
        VStack {
            Text("Transaction Speed")
                .foregroundColor(Color("newGray"))
                .font(.system(size: 26, weight: .light))
            
            Picker("speed", selection: $costRate) {
                ForEach(SendModel.CostRateClass.allCases) { rate in
                    Text(String(describing: rate))
                        .tag(rate)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 10)

            Group {
                if cost > 0 {
                    Text("Transaction cost: \((unit ?? .sats).toString(cost))")
                        .transition(.scale)
                }
                else {
                    Text("")
                        .transition(.scale)
                }
            }
            .frame(minHeight: 30)
            .font(.system(size: 15, weight: .light))
            .animation(.default)
            .frame(maxWidth: .infinity)
        }
    }
}

struct TransactionSpeedAndCost_Previews: PreviewProvider {
    struct CostRateHolder: View {
        @State var costRate = SendModel.CostRateClass.low
        
        var body: some View {
            TransactionSpeedAndCost(costRate: $costRate,
                                    unit: .mBtc,
                                    cost: 1231923)
        }
    }
    
    static var previews: some View {
        CostRateHolder()
    }
}

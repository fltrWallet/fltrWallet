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

struct CurrentFunds: View {
    let unit: CurrencyUnit?
    let currentFunds: UInt64
    let pendingFunds: UInt64

    var unitElseSats: CurrencyUnit {
        self.unit ?? .sats
    }
    
    @State var showingCurrentFunds = false
    
    var body: some View {
        VStack(spacing: 10) {
            (
                Text("Current funds:")
                    .fontWeight(.light)
                    + Text(" (")
                    + Text(showingCurrentFunds ? "Hide" : "")
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    + Text(showingCurrentFunds ? "" : "Show").underline()
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    + Text(")")
            )
            .onTapGesture {
                showingCurrentFunds.toggle()
            }
            
            (
                Text("\(unitElseSats.toString(currentFunds))")
                    + Text(pendingFunds == 0
                            ? ""
                            : " (pending \(unitElseSats.toString(pendingFunds)))")
            )
            .fontWeight(.light)
            .allowsTightening(true)
            .lineLimit(1)
            .opacity(showingCurrentFunds ? 1 : 0)
            .animation(.linear(duration: 0.3))
            .frame(maxWidth: .infinity, alignment: .bottom)
            
            
        }
    }
}

struct CurrentFunds_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            CurrentFunds(unit: .mBtc, currentFunds: 1234, pendingFunds: 0)
            CurrentFunds(unit: .mBtc, currentFunds: 1234, pendingFunds: 78091)
            CurrentFunds(unit: .mBtc, currentFunds: 123456789, pendingFunds: 780911284814).padding(30)
        }
    }
}

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
import SwiftUI

struct CoinCell: View {
    let coin: HD.Coin
    
    var spentPending: Tx.AnyTransaction? {
        switch self.coin.spentState {
        case .pending(let spent):
            return spent.tx
        default:
            return nil
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                HStack {
                    Image(systemName: "dollarsign.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)

                    Text("\(coin.amount)")
                        .font(.system(.body, design: .monospaced))

                    
                }
                .padding(3)
                .background(Color("newGray"))
                .foregroundColor(Color("fltrBackground"))
                .cornerRadius(6.0)

                Spacer()
            }

            VStack(alignment: .leading) {
                Text("received height \(coin.receivedHeight)")
                Text("received state \(coin.receivedState.debugDescription)")
                Text("spent state \(coin.spentState.debugDescription)")
            }
            
            VStack(alignment: .leading) {
                Text("received state is pending \(String(describing: coin.receivedState.isPending))")
                Text("spent state is pending \(String(describing: coin.spentState.isPending))")
                Text("spent state is available \(String(describing: coin.spentState.isAvailable))")
                Text("is spendable \(String(describing: coin.isSpendable))")
            }
            
            Group {
                if let tx = self.spentPending {
                    ScrollView {
                        Text("Hello \(tx.debugDescription)")
                            .lineLimit(100)
                    }
                }
            }

            Button {
                UIPasteboard.general.string = coin.outpoint.transactionId.bigEndian.hexEncodedString
            }
            label: {
                (
                    Text("Outpoint\t")
                        + Self.text(from: coin.outpoint)
                    
                )
                .font(.system(size: 10, weight: .thin, design: .monospaced))
                .allowsTightening(true)
            }
        }
        .padding(.horizontal, 5)
        .padding(.bottom, 60)
    }
}

extension CoinCell {
    static func text(from outpoint: Tx.Outpoint) -> Text {
        Text("\(outpoint.transactionId.bigEndian.hexEncodedString):\(outpoint.index)")
    }
    
    static func decode(from spent: HD.Coin.SpentState) -> Tx.TxId? {
        switch spent {
        case .pending(let spent):
            let ident = Tx.AnyIdentifiableTransaction(spent.tx)
            return ident.txId
        default:
            break
        }
        
        return nil
    }
}

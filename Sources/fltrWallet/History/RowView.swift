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
import fltrVault
import SwiftUI

extension NewHistoryView {
    struct RowView: View {
        @EnvironmentObject var state: NewHistoryView.HistoryModel
        
        var item: History.InOut
        @Binding var detail: History.InOut?
        var dictionary: [Int : UInt32]
        
        static var shortDate: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter
        }()
        
        var date: Date? {
            dictionary[item.record.height]
            .map {
                Date(timeIntervalSince1970: TimeInterval($0))
            }
        }
        
        var body: some View {
            VStack(spacing: 0) {
                Spacer(minLength: 20)
                
                HStack {
                    Group {
                        if let date = date {
                            Text("\(date, formatter: Self.shortDate)")
                                .fontWeight(.light)
                        } else {
                            Text("height \(item.record.height)")
                                .fontWeight(.light)
                        }
                    }
                    .lineLimit(1)
                    .allowsTightening(true)
                    .layoutPriority(100)

                    Text("Pending")
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .allowsTightening(true)
                        .frame(maxWidth: 100, alignment: .trailing)
                        .opacity(item.record.pending ? 1 : 0)
                        .layoutPriority(0.1)

                    state.format(amount: item.record.amount, incoming: item.incoming)
                        .frame(maxWidth: 150, alignment: .trailing)
                        .lineLimit(1)
                        .allowsTightening(true)
                        .layoutPriority(100)
                }
                
                Spacer(minLength: 20)

                Divider()
            }
            .contentShape(Rectangle())
            .onTapGesture { detail = item }
        }
    }
}

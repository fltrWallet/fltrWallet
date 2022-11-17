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
import SwiftUI

struct SendForm: View {
    @StateObject var decimalAmount = DecimalAmount()
    @ObservedObject var sendModel: SendModel
    
    @EnvironmentObject var orientation: Orientation.Model
    
    var preloadAmount: UInt64?
    
    @State var showingCurrentFunds = false
    
    @State var showHeader = true
    @State var showHeader2 = true
    @State var headerOffset: CGFloat = 0

    var currentFunds: UInt64
    var pendingFunds: UInt64

    var close: () -> Void
    var send: () -> Void
    
    var body: some View {
        LongStack(alignment: .center, spacing: 40) {
            VStack(alignment: .center) {
                Text(showHeader2 ? "Send Funds" : "")
                    .heading
                    .onTapGesture {
                        showHeader = false; DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) { showHeader2 = false }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, orientation.isVertical && showHeader ? 90 : 0)
                    .offset(x: 0, y: showHeader ? 0 : -200)
                    .opacity(showHeader ? 1 : 0)
                    .animation(.easeIn(duration: 0.7))
                    .onReceive(NotificationCenter.default.publisher(
                                for: UIResponder.keyboardWillShowNotification
                    )) { _ in
                        showHeader = false
                    }
                    .onReceive(NotificationCenter.default.publisher(
                        for: UIResponder.keyboardWillShowNotification
                    ).delay(for: 0.4, scheduler: DispatchQueue.main)) { _ in
                        showHeader2 = false
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                            .onAppear {
                                headerOffset = proxy.size.height
                            }
                        }
                    )
                
                Spacer(minLength: 0)
                
                SendField(placeholder: "Recipient",
                          data: $sendModel.address,
                          error: sendModel.addressError,
                          fontSize: 16,
                          fieldType: .url)
                    .padding(.bottom, 10)
                
                SendField(placeholder: "Amount",
                          data: $decimalAmount.value,
                          error: sendModel.amountError,
                          fontSize: 16,
                          fieldType: .text)
                    .padding(.bottom, 10)

                let defaultPickerBinding = Binding<CurrencyUnit>.init {
                    decimalAmount.unit ?? .sats
                }
                set: { newValue in
                    decimalAmount.unit = newValue
                }
                
                Picker("Unit", selection: defaultPickerBinding) {
                    ForEach(CurrencyUnit.allCases) { unit in
                        Text(String(describing: unit))
                            .tag(unit)
                    }
                }
                .padding(.bottom, 20)
                .pickerStyle(SegmentedPickerStyle())

                CurrentFunds(unit: decimalAmount.unit,
                             currentFunds: currentFunds,
                             pendingFunds: pendingFunds)

                Spacer(minLength: 0)
            }
            .offset(x: 0, y: !showHeader && showHeader2 ? -headerOffset : 0)
            .padding(.leading, 30)

        }
        c2: {
            VStack(alignment: .center) {
                Spacer(minLength: 0)
                
                TransactionSpeedAndCost(costRate: $sendModel.costRateClass,
                                        unit: decimalAmount.unit,
                                        cost: sendModel.costEstimate ?? 0)

                Spacer()
                
                HStack {
                    Button("Close") {
                        close()
                    }
                    .buttonStyle(RoundedRectangleButtonStyle())

                    Spacer()
                    
                    Button("Send") {
                        send()
                    }
                    .buttonStyle(RoundedRectangleButtonStyle())
                    .disabled(sendModel.disabled) // this looked ugly/like a lock-up  || sendModel.pendingSendDisable)
                }
                Spacer(minLength: 0)
                Spacer(minLength: 0)
            }
            .padding(.leading, 30)
        }
        .transition(.move(edge: .bottom))
        .padding(.trailing, 30)
        .padding(.bottom, 30)
        .onAppear(perform: onAppear)
        .onDisappear {
            let c = decimalAmount.cancellables
            decimalAmount.cancellables.removeAll()
            c.forEach { $0.cancel() }
        }
        .frame(maxWidth: orientation.isVertical ? 550 : .infinity)
        .frame(minWidth: orientation.safeSize.width, minHeight: orientation.safeSize.height)
    }
}

// MARK: onAppear()
extension SendForm {
    func onAppear() {
        decimalAmount.decimalErrorPublisher
        .assign(to: \.decimalAmountError, on: sendModel)
        .store(in: &decimalAmount.cancellables)
        
        decimalAmount.toSatoshis
        .assign(to: \.amount, on: sendModel)
        .store(in: &decimalAmount.cancellables)

        decimalAmount.autoRoundingCorrection
        .assign(to: \.value, on: decimalAmount)
        .store(in: &decimalAmount.cancellables)
        
        decimalAmount.unitConversion()
        .assign(to: \.value, on: decimalAmount)
        .store(in: &decimalAmount.cancellables)
        
        decimalAmount.unit = .mBtc
        if let preloadAmount = self.preloadAmount {
           let value = decimalAmount.unit!.convert(preloadAmount)
           decimalAmount.value = value
        }
    }
}

struct SendForm_Previews: PreviewProvider {
    struct PreviewForm: View {
        @StateObject var sendModel: SendModel = .init()
        
        var body: some View {
            OrientationView {
                SendForm(sendModel: sendModel,
                         currentFunds: 1234,
                         pendingFunds: 5678) {
                }
                send: {
                }
            }
        }
    }
    
    static var previews: some View {
        PreviewForm()
    }
}

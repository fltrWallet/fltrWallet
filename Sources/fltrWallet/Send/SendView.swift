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
import fltrUI
import SwiftUI

extension AppDelegate {
    typealias LatestValues = (address: AddressDecoder, amount: UInt64, costRate: Double)
}

struct SendView: View {
    @ObservedObject var sendSheetModel: SendSheetModel
    @StateObject var sendModel: SendModel = .init()
    @EnvironmentObject var model: AppDelegate
    var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ConfirmSendView(confirm: $sendModel.confirmSend) { confirm in
                guard !sendModel.pendingSendDisable
                else { return }
                sendModel.pendingSendDisable = true
                
                guard let valid = sendModel.validated
                else {
                    sendModel.error = .internalError
                    sendModel.pendingSendDisable = false
                    return
                }
                
                self.model.glewRocket.pay(amount: valid.amount,
                                          to: valid.address,
                                          cost: confirm.costRate.costPerVByte) { result in
                    defer {
                        DispatchQueue.main.async {
                            sendModel.pendingSendDisable = false
                        }
                    }
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            sendModel.confirmSend = nil
                            sendSheetModel.succeedSend()
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            sendModel.error = VaultApiError(error)
                        }
                    }
                }
            } content: {
                SendForm(sendModel: sendModel,
                         preloadAmount: sendSheetModel.amount,
                         currentFunds: model.active,
                         pendingFunds: model.pending) {
                    self.sendSheetModel.dismissSend()
                } send: {
                    guard let valid = sendModel.validated
                    else { return }
                    
                    sendModel.confirmSend = .init(address: valid.address.string,
                                                  amount: valid.amount,
                                                  unit: valid.unit,
                                                  costRate: valid.costRate,
                                                  costEstimate: sendModel.costEstimate ?? 0)
                }
            }
        }
        .combine(sendModel)
        .onAppear {
            sendModel.confirmSend = nil

            sendModel.address = sendSheetModel.address?.string ?? ""
            model.feeEstimateTrigger = ()
        }
        .frame(minWidth: 0, maxWidth: .infinity,
               minHeight: 0, maxHeight: .infinity)
        .alert(item: $sendModel.error) { error in
            Alert(title: Text("Payment Error"),
                  message: Text("An error has occurred: \n\(String(describing: error))"),
                  dismissButton: .cancel() {
                    sendSheetModel.dismissSend()
                  })
        }
    }
}

struct SendView_Previews: PreviewProvider {
    struct SendPreview: View {
        @StateObject var sendSheetModel = SendSheetModel()
        
        var body: some View {
            OrientationView {
                Color.clear
                .fullScreenCover(item: $sendSheetModel.sendOrScan) { _ in
                    SendView(sendSheetModel: sendSheetModel)
                    .environmentObject(AppDelegate.running120)
                }
                .onAppear {
                    sendSheetModel.startSend()
                }
            }
            .environmentObject(AppDelegate.running120)
        }
    }
    
    static var previews: some View {
        SendPreview()
    }
}

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
import SwiftUI

struct NewQrPane: View {
    @State private var showShare: Bool = false

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var model: AppDelegate
    @EnvironmentObject var orientation: Orientation.Model
    @StateObject var qrState: QRState = .init()
    
    @ScaledMetric var fontSize = 25 as CGFloat
    
    @State var height: CGFloat = .zero
    
    var body: some View {
        VStack {
            MenuBar(showShare: $qrState.requestShare, address: qrState.address?.display)
            LongStack {
                VStack {
                    Spacer(minLength: 0)

                    CodeView(address: qrState.address)
                    
                    Spacer(minLength: 0)
                }
            }
            c2: {
                VStack {
                    Spacer(minLength: 0)

                    Text("Let someone scan your code to start a payment")
                        .font(.system(size: fontSize, weight: .light))
                        .multilineTextAlignment(.center)
                        .lineLimit(5)
                        .padding(.horizontal, 50)

                    Spacer(minLength: 0)

                    AddressTypePicker(selectorIndex: $qrState.selectorIndex)


                    let text = Text("Taproot transactions provide the best anonymity, security and lowest cost, hence they should be tried first but may not be supported by all wallets")
                        .font(.system(size: fontSize - 11, weight: .light))
                        .lineLimit(5)
                        .multilineTextAlignment(.center)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.5)


                    text.opacity(0)
                        .overlay(
                            Group {
                                if qrState.selectorIndex == .taproot {
                                    text
                                } else if qrState.selectorIndex == .segwit {
                                    Text("When Taproot transactions are not supported, use Segwit to save cost and provide addresses with better error detection due to misspelled characters")
                                        .font(.system(size: fontSize - 11, weight: .light))
                                        .lineLimit(5)
                                        .multilineTextAlignment(.center)
                                        .allowsTightening(true)
                                        .minimumScaleFactor(0.5)
                                } else if qrState.selectorIndex == .legacy {
                                    Text("When Segwit is not supported, Legacy transactions are the most compatible and are supported by most wallets")
                                        .font(.system(size: fontSize - 11, weight: .light))
                                        .lineLimit(5)
                                        .multilineTextAlignment(.center)
                                        .allowsTightening(true)
                                        .minimumScaleFactor(0.5)
                                }
                            }
                            
                    )
                    .padding(.horizontal, 50)

                    Spacer(minLength: 0)
                    
                }
                .foregroundColor(Color("newGray"))
            }
            .opacity(qrState.launchOpacity)
            .animation(.easeIn(duration: 0.5))

            Spacer(minLength: 0)
            
            if !orientation.compactHorizontal {
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(RoundedRectangleButtonStyle())
                .padding(.bottom, 0.1 * height)
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        height = proxy.frame(in: .local).height
                    }
            }
        )
        .sheet(isPresented: $qrState.showShare) {
            Group {
                if let address = qrState.address {
                    ShareSheet(activityItems: [ URL(string: "bitcoin:\(address.display)")! ])
                } else {
                    ShareSheet(activityItems: [])
                }
            }
            .ignoresSafeArea(.container)
        }
        .background(
            QRPaneBackground()
                .ignoresSafeArea()
        )
        .onAppear {
            qrState.launchOpacity = 0
            qrState.startPublishers(model)
        }
        .onDisappear {
            qrState.stopPublishers()
        }
    }
}

extension NewQrPane {
    final class QRState: ObservableObject {
        @Published var address: (display: String, encode: String)?
        @Published var selectorIndex: AddressType?
        @Published var launchOpacity: Double = 0
        @Published var requestShare = false
        @Published var showShare = false
        
        var cancellables: Set<AnyCancellable> = .init()
        
        func addressPublisher(_ model: AppDelegate) -> AnyPublisher<(display: String, encode: String)?, Never> {
            model.$pending
            .combineLatest(model.$active)
            .map { pending, active in (pending: pending, active: active) }
            .combineLatest(model.$running)
            .filter { funds, running -> Bool in
                (funds.pending > 0 || funds.active > 0)
                && running
            }
            .map { _, _ -> Void in () }
            .prepend(())
            .combineLatest(self.$selectorIndex)
            .compactMap(\.1)
            .map { selectorIndex -> HD.Source in
                switch selectorIndex {
                case .legacy: return .legacySegwit
                case .segwit: return .segwit
                case .taproot: return .taproot
                }
            }
            .map { selector -> AnyPublisher<(display: String, encode: String)?, Never> in
                return model.glewRocket.loadLatestAddress(for: selector)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        }
        
        func startPublishers(_ model: AppDelegate) {
            self.addressPublisher(model)
            .assign(to: \.address, on: self)
            .store(in: &self.cancellables)
            
            self.addressPublisher(model)
            .first()
            .map { _ in
                Double(1)
            }
            .assign(to: \.launchOpacity, on: self)
            .store(in: &self.cancellables)
            
            self.$requestShare
            .combineLatest(self.$address)
            .filter { $0.0 }
            .compactMap(\.1)
            .map { _ in true }
            .assign(to: \.showShare, on: self)
            .store(in: &self.cancellables)
            
            self.$showShare
            .filter { !$0 }
            .map { _ in false }
            .assign(to: \.requestShare, on: self)
            .store(in: &self.cancellables)
        }
        
        func stopPublishers() {
            defer { self.cancellables.removeAll() }
            
            self.cancellables.forEach {
                $0.cancel()
            }
        }
    }
}

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
import LocalAuthentication
import SwiftUI

struct SettingsNavigationView: View {
    @Binding var showWords: Bool
    @Environment(\.openURL) var openURL
    @Environment(\.fltrTabBarHeight) var tabHeight
    @Environment(\.fltrTabBarEdge) var tabEdge
    @EnvironmentObject var model: AppDelegate
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Security")) {
                    if Self.faceID {
                        Group {
                            Toggle("FaceID Authentication", isOn: self.biometricBinding)
                                .disabled(true)
                        }
                        .onTapGesture {
                            self.triggerFaceID {
                                guard let url = URL(string: UIApplication.openSettingsURLString)
                                else { return }
                                
                                openURL(url)
                            }
                        }
                    }
                    
                    Button("Recovery Phrase") {
                        showWords = true
                    }
                }
                
                Section(header: Text("Open Source")) {
                    NavigationLink(
                        destination: ScrollView { LicenseText() }.navigationTitle("Open Source Licenses"),
                        label: {
                            Text("Licenses")
                        })
                }
                
                Section(header: Text("About")) {
                    NavigationLink(
                        destination: ScrollView { AboutView() }.navigationTitle("About"),
                        label: {
                            Text("Copyright")
                        })
                }
                
                Section {
                    NavigationLink {
                        ScrollView {
                            ResetView()
                        }
                        .navigationTitle("Reset")
                        .background(
                            NewFltrViewBackground().ignoresSafeArea()
                        )
                    } label: {
                        Group {
                            Text("Reset ") + Text("fltrWallet").fontWeight(.light)
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .foregroundColor(Color("newGray"))
        .padding(tabEdge, tabHeight)
    }
}

extension SettingsNavigationView {
    static func checkBiometric() -> Bool {
        var error: NSError?
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    static var faceID: Bool {
        var error: NSError?
        let context = LAContext()
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return {
            switch context.biometryType {
            case .faceID: return true
            case .touchID, .none: return false
            @unknown default:
                return false
            }
        }()
    }
    
    var biometricBinding: Binding<Bool> {
        .init {
            Self.checkBiometric()
        }
        set: { _ in
            preconditionFailure()
        }
    }
    
    func triggerFaceID(url: @escaping () -> Void) -> Void {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Private Key Access") { result, errorOptional in
            url()
        }
    }
}

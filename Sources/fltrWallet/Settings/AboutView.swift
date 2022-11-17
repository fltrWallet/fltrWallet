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

struct AboutView: View {
    @ScaledMetric var fontSize: CGFloat = 15
    
    var thisVersion: UInt {
        UInt(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)!
    }
    
    var body: some View {
        VStack {
            Text("Copyright (c) 2022 fltrWallet AG")
                .font(.system(size: fontSize, weight: .light))
                .padding(.bottom, 10)
            
            Text("Build \(thisVersion)")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
            
            Link("fltrWallet.com", destination: URL(string: "https://fltrWallet.com")!)
                .padding(20)
                .padding(.bottom, 50)
            
            Text("""
                 THE SERVICE AND ALL RELATED COMPONENTS AND INFORMATION ARE PROVIDED ON AN “AS IS” AND “AS AVAILABLE” BASIS WITHOUT ANY WARRANTIES OF ANY KIND, AND FLTRWALLET EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES, WHETHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, TITLE, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. USERS ACKNOWLEDGE THAT FLTRWALLET DOES NOT WARRANT THAT THE SERVICE WILL BE UNINTERRUPTED, TIMELY, SECURE, ERROR-FREE OR VIRUS-FREE, NOR DOES IT MAKE ANY WARRANTY AS TO THE RESULTS THAT MAY BE OBTAINED FROM USE OF THE SERVICES, AND NO INFORMATION, ADVICE OR SERVICES OBTAINED BY YOU FROM FLTRWALLET OR THROUGH THE SERVICE SHALL CREATE ANY WARRANTY NOT EXPRESSLY STATED IN THIS TOS.
                 """)
                .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                .lineSpacing(fontSize / 2)
        }
        .padding()
        .padding(.vertical, 20)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        OrientationView {
            WindowScrollView(direction: .longitude, ignoresSafeArea: false) {
                AboutView()
            }
        }
    }
}


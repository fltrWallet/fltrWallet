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

struct NoWordsView: View {
    @ScaledMetric var fontSize: CGFloat = 20
    
    var close: (Bool) -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            Text("There was an error loading private key recovery seed phrase")
                .lineLimit(10)
                .multilineTextAlignment(.center)
                .padding(50)

            Spacer()
            
            Button("Close", action: { close(false) })
                .buttonStyle(RoundedRectangleButtonStyle())
            
            Spacer()
        }
        .padding(.vertical, 200)
        .font(.system(size: fontSize, weight: .light))
        .foregroundColor(Color("newGray"))
    }
}

struct NoWordsView_Previews: PreviewProvider {
    static var previews: some View {
        NoWordsView() { _ in () }
    }
}

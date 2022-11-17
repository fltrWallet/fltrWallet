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

public struct UnderlineShape: Shape {
    public func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(
                to: CGPoint(x: rect.minX,
                            y: rect.maxY))
            path.addLine(
                to: CGPoint(x: rect.maxX,
                            y: rect.maxY))
        }
    }
}

struct UnderlineShape_Preview: PreviewProvider {
    static var previews: some View {
        Text("Underlined")
            .padding(2)
            .padding(.bottom, 4)
            .background(
                UnderlineShape()
                    .stroke()
            )
    }
}

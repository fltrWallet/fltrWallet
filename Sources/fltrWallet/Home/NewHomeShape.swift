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
import fltrUI
import SwiftUI

public struct NewHomeShape: Shape {
    @EnvironmentObject var model: Orientation.Model
    
    public func path(in rect: CGRect) -> Path {
        Path { path in
            let controlLong = model.latSize * 0.1
            
            defer { path.closeSubpath() }

            if model.isVertical {
                path.move(to: CGPoint(x: rect.minX, y: rect.minY))
                path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control: CGPoint(x: rect.midX, y: controlLong))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            } else {
                if model.isLeft {
                    path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                    path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.minY), control: CGPoint(x: controlLong, y: rect.midY))
                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                } else { // isRight
                    path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
                    path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY), control: CGPoint(x: rect.maxX - controlLong, y: rect.midY))
                    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
                }
            }
        }
    }
}

struct NewHomeShape_Previews: PreviewProvider {
    static var previews: some View {
        OrientationView {
            NewHomeShape()
        }
        .frame(maxHeight: 100)
    }
}

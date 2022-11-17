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

struct ViewFinderShaper: Shape {
    func path(in rect: CGRect) -> Path {
        return Path { path in
            let segmentLength = rect.width * 9/24

            path.move(to: CGPoint(x: rect.minX, y: rect.minY + segmentLength))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + segmentLength, y: rect.minY))
    
            path.move(to: CGPoint(x: rect.maxX - segmentLength, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + segmentLength))
            
            path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - segmentLength))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX - segmentLength, y: rect.maxY))
            
            path.move(to: CGPoint(x: rect.minX + segmentLength, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - segmentLength))
        }
    }
}

struct ViewFinderShaper_Previews: PreviewProvider {
    static var previews: some View {
        ViewFinderShaper()
            .stroke(Color("newGray"), lineWidth: 0.9)
            .frame(maxWidth: 300, maxHeight: 300)
    }
}

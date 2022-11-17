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

public extension Color {
    @inlinable
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#if os(macOS)
public extension Color {
    @usableFromInline
    init(light: NSColor, dark: NSColor) {
        self.init(light)
    }
}
#else
public extension Color {
    @inlinable
    init(light: UIColor, dark: UIColor) {
        self.init(UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        })
    }
}
#endif

public extension Color {
    @inlinable
    static var fltrBackground: Color {
        let darkLuminosity: CGFloat = 0.20
        #if os(macOS)
        let light = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
        let dark = NSColor(red: darkLuminosity, green: darkLuminosity, blue: darkLuminosity, alpha: 1)
        #else
        let light = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
        let dark = UIColor(red: darkLuminosity, green: darkLuminosity, blue: darkLuminosity, alpha: 1)
        #endif

        return .init(light: light, dark: dark)
    }
    
    @inlinable
    static var fltrGray: Color {
        return .init(red: 0x3D / 255,
                     green: 0x36 / 255,
                     blue: 0x35 / 255)
    }
    
    
    
    @inlinable
    static var fltrQrGray1: Color {
        return .init(red: 0xf3 / 255,
                     green: 0x68 / 255,
                     blue: 0xe0 / 255)
    }

    @inlinable
    static var fltrQrGray2: Color {
        return .init(red: 0xd3 / 255,
                     green: 0xd3 / 255,
                     blue: 0xd3 / 255)
    }

    
    @inlinable
    static var fltrQrRed: Color {
        return .init(red: 244 / 255,
                     green: 71 / 255,
                     blue: 67 / 255)
    }

    @inlinable
    static var fltrQrOrange: Color {
        return .init(red: 254 / 255,
                     green: 184 / 255,
                     blue: 60 / 255)
    }

    @inlinable
    static var fltrQrBlue1: Color {
        return .init(red: 67 / 255,
                     green: 71 / 255,
                     blue: 244 / 255)
    }

    @inlinable
    static var fltrQrBlue2: Color {
        return .init(red: 60 / 255,
                     green: 184 / 255,
                     blue: 254 / 255)
    }
    
    @inlinable
    static var piglet1: Color {
        return .init(red: 0xee / 0xff,
                     green: 0x9c / 0xff,
                     blue: 0xa7 / 0xff)
    }
    
    @inlinable
    static var piglet2: Color {
        return .init(red: 0xff / 0xff,
                     green: 0xdd / 0xff,
                     blue: 0xe1 / 0xff)
    }
    
    @inlinable
    static var gradientGray1: Color {
        return .init(red: 0xbd / 0xff,
                     green: 0xc3 / 0xff,
                     blue: 0xc7 / 0xff)
    }

    @inlinable
    static var gradientGray2: Color {
        return .init(red: 0x2c / 0xff,
                     green: 0x3e / 0xff,
                     blue: 0x50 / 0xff)
    }
}

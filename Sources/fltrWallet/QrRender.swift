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
import CoreImage.CIFilterBuiltins
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public struct Qr {
    public struct Image {
        #if os(macOS)
        public let value: NSImage
        
        @inlinable init(_ value: NSImage) { self.value = value }
        #else
        public let value: UIImage
        
        @inlinable init(_ value: UIImage) { self.value = value }
        #endif
    }
    
    @usableFromInline
    let context = CIContext()
    @usableFromInline
    let filter: CIQRCodeGenerator & CIFilter = {
        let codeGenerator = CIFilter.qrCodeGenerator()
        codeGenerator.correctionLevel = "H"
        return codeGenerator
    }()
    
    @inlinable
    public init() {}
    
    @inlinable
    public func code(from string: String) -> Image {
        let data = string.data(using: String.Encoding.isoLatin1)!
        defer {
            self.filter.setDefaults()
        }
        self.filter.setValue(data, forKey: "inputMessage")

        guard let outputImage = self.filter.outputImage,
              let cgImage = self.context.createCGImage(outputImage, from: outputImage.extent)
        else {
            #if os(macOS)
            let image = NSImage(systemSymbolName: "xmark.circle", accessibilityDescription: "System Unavailable") ?? NSImage()
            #else
            let image = UIImage(systemName: "xmark.circle") ?? UIImage()
            #endif
            return Image(image)
        }

        #if os(macOS)
        let image = NSImage(cgImage: cgImage, size: NSSize(width: outputImage.extent.width, height: outputImage.extent.height))
        #else
        let image = UIImage(cgImage: cgImage)
        #endif

        return Image(image)
    }
}

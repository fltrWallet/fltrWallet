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

#if canImport(UIKit)
final class UIBackdropView: UIView {
    override class var layerClass: AnyClass {
        NSClassFromString("CABackdropLayer") ?? CALayer.self
    }
}

struct BackdropView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIBackdropView {
        UIBackdropView()
    }

    public func updateUIView(_ uiView: UIBackdropView, context: Context) {}
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
 
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        let uiView = UIVisualEffectView()
        uiView.backgroundColor = .clear
        return uiView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

public struct BlurView: View {
    var radius: CGFloat
    
    public init(radius: CGFloat) {
        self.radius = radius
    }
    
    public var body: some View {
        BackdropView()
        .blur(radius: radius)
    }
}
#else

struct BackdropView: View {
    var body: some View {
        EmptyView()
    }
}

struct VisualEffectView: View {
    var body: some View {
        EmptyView()
    }
}

public struct BlurView: View {
    public init(radius: CGFloat) {}
    
    public var body: some View {
        EmptyView()
    }
}
#endif

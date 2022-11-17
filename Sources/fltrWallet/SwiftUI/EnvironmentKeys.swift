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

public enum FltrButtonColor: EnvironmentKey {
    public static var defaultValue: Color {
        Color("newGray")
    }
}

public extension EnvironmentValues {
    var buttonColor: Color {
        get {
            return self[FltrButtonColor.self]
        }
        set {
            self[FltrButtonColor.self] = newValue
        }
    }
}

public enum FltrButtonBackground: EnvironmentKey {
    public static var defaultValue: Color {
        Color.orange.opacity(0.1)
    }
}

public extension EnvironmentValues {
    var buttonBackground: Color {
        get {
            return self[FltrButtonBackground.self]
        }
        set {
            self[FltrButtonBackground.self] = newValue
        }
    }
}

public enum FltrTabBarHeight: EnvironmentKey {
    public static var defaultValue: CGFloat {
         0
    }
}

public extension EnvironmentValues {
    var fltrTabBarHeight: CGFloat {
        get {
            return self[FltrTabBarHeight.self]
        }
        set {
            self[FltrTabBarHeight.self] = newValue
        }
    }
}

public enum FltrTabBarEdge: EnvironmentKey {
    public static var defaultValue: Orientation.Edge {
        .longAfter
    }
}

public extension EnvironmentValues {
    var fltrTabBarEdge: Orientation.Edge {
        get {
            self[FltrTabBarEdge.self]
        }
        set {
            self[FltrTabBarEdge.self] = newValue
        }
    }
}

public enum LineWidth: EnvironmentKey {
    public static var defaultValue: CGFloat {
        0.9
    }
}

public extension EnvironmentValues {
    var lineWidth: CGFloat {
        get {
            self[LineWidth.self]
        }
        set {
            self[LineWidth.self] = newValue
        }
    }
}

public enum FirstRun: EnvironmentKey {
    public static var defaultValue: Binding<Bool> = .constant(false)
}

public extension EnvironmentValues {
    var firstRun: Binding<Bool> {
        get {
            self[FirstRun.self]
        }
        set {
            self[FirstRun.self] = newValue
        }
    }
}

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
import Combine
import fltrBtc
import NIO
import SwiftUI

public struct SyncView: View {
    @EnvironmentObject var model: AppDelegate
    @EnvironmentObject var syncModel: SyncModel

    var width: CGFloat?
    var height: CGFloat?
    
    let info: String
    
    private let defaultWidth = CGFloat(300)
    private let defaultHeight = CGFloat(20)
    
    @State private var _width: CGFloat?

    public init(width: CGFloat? = nil,
                height: CGFloat? = nil,
                info: String? = "Blockchain Sync") {
        self.width = width
        self.height = height
        self.info = info!
    }

    private var cwidth: CGFloat {
        width
            ?? _width
            ?? defaultWidth
    }
    
    private var cheight: CGFloat {
        height
            ?? defaultHeight
    }
    
    public var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: cheight)
                .foregroundColor(.gray)
                .opacity(0.5)
                .frame(width: cwidth, height: cheight * 0.1)

            RoundedRectangle(cornerRadius: cheight)
                .foregroundColor(Color("logoGreen"))
                .frame(width: cwidth * syncModel.completion, height: cheight)
            
            HStack(alignment: .center) {
                Spacer()
                
                if let info = info {
                    Text(info)
                        .font(.system(size: 15, weight: .ultraLight, design: .rounded))
                        .lineLimit(1)
                        .allowsTightening(true)
                        .foregroundColor(Color("newGray"))
                        .offset(x: 0, y: 20 + 1 * cheight )
                }
                
                Spacer()
            }
        }
        .opacity(syncModel.completed ? 0 : 1)
        .frame(maxWidth: cwidth, maxHeight: cheight + 30)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        _width = proxy.size.width
                    }
            }
        )
    }
}


struct SyncView_Previews: PreviewProvider {
    struct Loader: View {
        @StateObject var model = AppDelegate.running120
        
        var body: some View {
            SyncEnvironment {
                SyncView()
                .onAppear {
                    var currentDelay = 0
                    func withDelay(_ fn: @escaping () -> Void) {
                        defer { currentDelay += 100 }
                        DispatchQueue.main.asyncAfter(wallDeadline: .now() + .milliseconds(currentDelay), execute: fn)
                    }

                    withDelay {
                        model.estimatedHeight = 20
                    }

                    (1...20).forEach { index in
                        withDelay {
                            model.compactFilterEvent = CompactFilterEvent.download(index)
                        }
                    }
                    
                    (1...10).forEach { index in
                        withDelay {
                            model.compactFilterEvent = CompactFilterEvent.nonMatching(index)
                        }
                    }
                    
                    withDelay {
                        model.estimatedHeight = 100
                    }

                    (11...12).forEach { index in
                        withDelay {
                            model.compactFilterEvent = CompactFilterEvent.nonMatching(index)
                        }
                    }

                    withDelay {
                        model.synched = true
                    }
                }
            }
            .environmentObject(model)
        }
    }
    
    static var previews: some View {
        VStack {
            Loader()
        }
    }
}

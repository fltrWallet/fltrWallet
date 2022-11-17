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

struct OrientationFltrTabBarView: View {
    struct BarButton: View {
        @Binding var selection: TabSelection
        var section: TabSelection
        
        var body: some View {
            Button {
                selection = section
            }
            label: {
                VStack(alignment: .center) {
                    Image(systemName: selection == section ? section.fill : section.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .opacity(selection == section ? 1 : 0.4)
                    Text(section.text)
                        .font(.system(size: 10))
                }
                .foregroundColor(Color("newGray"))
            }
            .frame(width: 50, alignment: .center)
        }
    }
    @EnvironmentObject var orientation: Orientation.Model
    
    @Binding var selection: TabSelection
    
    var tabBarSpacing: CGFloat = 75
    var tabBarPaddingLatPercent: CGFloat = 12.5
    var tabBarPaddingLongPoints: CGFloat = 33
    var tabBarIcons: CGFloat = 25

    
    var body: some View {
        LatStack(alignment: .center, spacing: 0) {
            BarButton(selection: $selection,
                      section: .home)
        }
        c2: {
            Spacer()
        }
        c3: {
            BarButton(selection: $selection,
                      section: .funds)
        }
        c4: {
            Spacer()
        }
        c5: {
            BarButton(selection: $selection,
                      section: .settings)
        }
        .ignoresSafeArea(.keyboard)
        .padding(.longBeforeAfter, tabBarPaddingLongPoints)
        .padding(.latBeforeAfter, orientation.latSize * tabBarPaddingLatPercent / 100)
    }
}

struct OrientationFltrTabBarView_Previews: PreviewProvider {
    @State static var selection: TabSelection = .funds
    
    static var previews: some View {
        SelectionView()
    }
    
    struct SelectionView: View {
        @State var selection: TabSelection = .home
        
        var body: some View {
            OrientationView {
                LongStack {
                    Spacer()
                }
                c2: {
                    OrientationFltrTabBarView(selection: $selection)
                        .background(Color.gray)
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }
        }
    }
}

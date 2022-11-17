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
import BackgroundTasks
import Combine
import HaByLo
import SwiftUI

public struct RocketLauncherView<Content: View>: View {
    var content: () -> Content

    final class AppearedState: ObservableObject {
        var feeCancellable: AnyCancellable?
        
        @Published var appearedOnce = false
    }
    
    @StateObject var appearedState: AppearedState = .init()
    @EnvironmentObject var model: AppDelegate
    #if !os(macOS)
    @State var taskIdentifier = UIBackgroundTaskIdentifier.invalid
    #endif
    @Environment(\.scenePhase) var scenePhase: ScenePhase

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content()
        .onAppear {
            defer { appearedState.appearedOnce = true }
            if !appearedState.appearedOnce && !model.background {
                logger.info("RocketLauncherView - Starting 🚀GlewRocket🚀")
                
                appearedState.feeCancellable = model.$running
                    .first(where: { $0 })
                    .flatMap { _ in
                        model.glewRocket.fees(trigger: model.$feeEstimateTrigger)
                    }
                    .map {
                        try? $0.get()
                    }
                    .receive(on: DispatchQueue.main)
                    .assign(to: \.feeEstimate, on: model)

                model.glewRocket.start(model)
            }
        }
        .onChange(of: scenePhase, perform: handleSceneChange(_:))
    }
}

extension RocketLauncherView {
    #if os(macOS)
    func handleSceneChange(_ scenePhase: ScenePhase) {}
    #else
    func endBackgroundTask() {
        defer { self.taskIdentifier = .invalid }

        guard self.taskIdentifier != .invalid
        else { return }
        
        UIApplication.shared.endBackgroundTask(self.taskIdentifier)
    }
    
    func handleSceneChange(_ scenePhase: ScenePhase) {
        func doStop(whenFinished: (() -> Void)? = nil) {
            if !self.model.background {
                self.model.glewRocket.stop {
                    self.endBackgroundTask()
                    whenFinished?()
                }
            } else {
                self.endBackgroundTask()
                whenFinished?()
            }
        }
        
        switch scenePhase {
        case .active:
            self.endBackgroundTask()
            self.model.glewRocket.start(self.model)
        case .background:
            self.taskIdentifier = UIApplication.shared.beginBackgroundTask {
                doStop {
                    logger.info("RocketLauncherView - Delayed stop SUCCESS")
                }
                self.endBackgroundTask()
            }
            
            AppDelegate.scheduleAppRefresh()
            
            // Initial bahaviour below was to stop immediately on synched
            /*
            if self.model.synched {
                guard self.taskIdentifier != .invalid
                else { break }

                doStop()
            }
            */
        case .inactive:
            break
        default:
            preconditionFailure()
        }
    }
    #endif
}

struct RocketLauncher_Previews: PreviewProvider {
    static var previews: some View {
        TestEnvironment {
            RocketLauncherView {
                Text("Loaded")
            }
        }
    }
}

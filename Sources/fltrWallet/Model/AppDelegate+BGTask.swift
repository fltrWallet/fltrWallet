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
#if canImport(UIKit)
#if canImport(BackgroundTasks)
import BackgroundTasks
import HaByLo
import UIKit

let BackgroundProcessingTaskID = "app.fltr.Node"
let ENABLE_BG_TASKS = false

public extension AppDelegate {
    static func scheduleAppRefresh(caller: StaticString = #function) {
        guard ENABLE_BG_TASKS
        else { return }
        
        logger.info("AppDelegate \(#function) - Scheduling background execution")
        BGTaskScheduler.shared.cancelAllTaskRequests()
        let request = BGProcessingTaskRequest(identifier: BackgroundProcessingTaskID)
        request.requiresNetworkConnectivity = true
        
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            logger.error("AppDelegate from \(caller) - Cannot submit task for background execution error: \(error)")
        }
    }

    func registerTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundProcessingTaskID,
                                        using: nil) { [weak self] task in
            logger.info("AppDelegate \(#function) - Begin executing background processing tasks")
            
            DispatchQueue.main.async {
                self?.background = true
            }
            
            Self.scheduleAppRefresh()

            let task = task as! BGProcessingTask
            
            guard let self = self,
                  !self.running,
                  self.suspended
            else {
                logger.info("Background launch while being in foreground...")
                return
            }
            
            DispatchQueue.main.async {
                self.glewRocket.background(self, task: task)
            }
        }
    }
}

#endif
#endif

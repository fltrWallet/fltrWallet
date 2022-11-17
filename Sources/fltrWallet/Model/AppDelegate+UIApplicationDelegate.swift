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
import BackgroundTasks
import HaByLo
import UIKit


extension AppDelegate: UIApplicationDelegate {
    public func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
//        logger.info("AppDelegate \(#function) - /* Restarting */ due to memory warning")
//        self.glewRocket.stop()
//        self.glewRocket.start(self)
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if ENABLE_BG_TASKS {
            self.registerTask()
            AppDelegate.scheduleAppRefresh()
        }
        
        return true
    }
    
    public func applicationWillTerminate(_ application: UIApplication) {
        self.glewRocket.stop()
    }
}
#endif

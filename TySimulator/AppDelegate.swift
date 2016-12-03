//
//  AppDelegate.swift
//  TySimulator
//
//  Created by luckytianyiyan on 2016/11/13.
//  Copyright © 2016年 luckytianyiyan. All rights reserved.
//

import Cocoa
import HockeySDK

class AppDelegate: NSObject, NSApplicationDelegate, DevMateKitDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        DevMateKit.sendTrackingReport(nil, delegate: nil)
        DevMateKit.setupIssuesController(nil, reportingUnhandledIssues: true)
        DM_SUUpdater.shared().delegate = self
        
        BITHockeyManager.shared().configure(withIdentifier: "4809e9695f5749449758cf7ec79710f5")
        BITHockeyManager.shared().crashManager.isAutoSubmitCrashReport = true
        BITHockeyManager.shared().start()
        
        // Setup trial
        #if DEBUG
            DMKitDebugAddTrialMenu()
            DMKitDebugAddActivationMenu()
        #endif
        
        var error: Int = DMKevlarError.testError.rawValue
        if !_my_secret_activation_check!(&error).boolValue || DMKevlarError.noError != DMKevlarError(rawValue: error) {
            DevMateKit.setupTimeTrial(self, withTimeInterval: kDMTrialWeek)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // MARK: SUUpdaterDelegate_DevMateInteraction
    
    public func updaterDidNotFindUpdate(_ updater: DM_SUUpdater!) {
        log.warning("not found update: \(updater)")
    }
    
    @nonobjc public func updaterShouldCheck(forBetaUpdates updater: DM_SUUpdater!) -> Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
    public func isUpdater(inTestMode updater: DM_SUUpdater!) -> Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
}


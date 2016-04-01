//
//  AppDelegate.swift
//  EGTracker
//
//  Created by Miguel Chaves on 04/01/2016.
//  Copyright (c) 2016 Miguel Chaves. All rights reserved.
//

import UIKit
import EGTracker

// Events struct (Suggestion)
struct EGEvents {
    static let appOpen = "APP_OPEN"
    static let eventButton = "EVENT_BUTTON"
    static let viewHome = "VIEW_HOME"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Init the tracker
        EGTracker.sharedInstance.initEngine()
        
        // Configure with E-Goi information about your App
        EGTracker.sharedInstance.url = "http://myappname.ios"
        EGTracker.sharedInstance.clientID = 1234
        EGTracker.sharedInstance.listID = 2143
        EGTracker.sharedInstance.idsite = 4321
        EGTracker.sharedInstance.subscriber = "mysubscriber@email.com"
        
        // Track App Open
        EGTracker.sharedInstance.trackEvent(EGEvents.appOpen)
        
        return true
    }
}


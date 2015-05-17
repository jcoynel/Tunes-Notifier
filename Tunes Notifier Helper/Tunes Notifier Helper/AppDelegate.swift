//
//  AppDelegate.swift
//  Tunes Notifier Helper
//
//  Created by Jules Coynel on 17/05/2015.
//  Copyright (c) 2015 Jules Coynel. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let mainAppBundleIdentifier = "com.julescoynel.Tunes-Notifier"
    let mainAppFileName = "Tunes Notifier"
    
    lazy var mainAppPath: String = {
        let path = NSBundle.mainBundle().bundlePath
        var pathComponents = path.pathComponents
        pathComponents.removeLast()
        pathComponents.removeLast()
        pathComponents.removeLast()
        pathComponents.append("MacOS")
        pathComponents.append(self.mainAppFileName)
        return NSString.pathWithComponents(pathComponents)
    }()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        var alreadyRunning = false
        
        for app in NSWorkspace.sharedWorkspace().runningApplications {
            if app.bundleIdentifier == mainAppBundleIdentifier {
                alreadyRunning = true
            }
        }
        
        if !alreadyRunning {
            NSWorkspace.sharedWorkspace().launchApplication(self.mainAppPath)
        }
        
        NSApplication.sharedApplication().terminate(nil)
    }
}


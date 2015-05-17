//
//  AppDelegate.swift
//  Tunes Notifier
//
//  Created by Jules Coynel on 16/05/2015.
//  Copyright (c) 2015 Jules Coynel. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    
    let notifier: Notifier = Notifier()
    
    var statusItem: NSStatusItem?
    var startAtLoginItem: NSMenuItem?
    
    @IBOutlet weak var statusMenu: NSMenu?
    
    // MARK: NSApplicationDelegate
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.registerDefaults()
    }
    
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // The menu is currently hidden, therefore show it
        if self.hideFromMenuBar {
            self.hideFromMenuBar = false
            self.setupMenu()
        }
        
        return true
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        NSUserDefaults.standardUserDefaults().synchronize()
        
        self.notifier.cleanNotificationCenter()
    }
    
    // MARK: NSObject(NSNibAwaking)
    
    override func awakeFromNib() {
        // Don't show the menu if user asked for it to be always hidden
        if !self.hideFromMenuBar {
            self.setupMenu()
        }
    }
    
    // MARK: Setting up and updating UI
    
    func setupMenu() {
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1) // should be NSVariableStatusItemLength
        self.statusItem?.menu = self.statusMenu
        
        let statusImage: NSImage? = NSImage(named: "status")
        statusImage?.setTemplate(true)
        
        self.statusItem?.image = statusImage
        self.statusItem?.highlightMode = true
        
        self.startAtLoginItem = NSMenuItem(
            title: NSLocalizedString("START_MENU_ITEM", comment: "Start at login"),
            action: "toogleStartAtLogin",
            keyEquivalent: "s")
        
        let hideFromMenuBarForeverItem = NSMenuItem(
            title: NSLocalizedString("HIDE_FOREVER_MENU_ITEM", comment: "Hide from menu bar forever"),
            action: "hideFromMenuBarForever",
            keyEquivalent: "h")
        
        let aboutItem = NSMenuItem(
            title: NSLocalizedString("ABOUT_MENU_ITEM", comment: "About Tunes Notifier"),
            action: "showAboutPanel",
            keyEquivalent: "")
        
        let quitItem = NSMenuItem(
            title: NSLocalizedString("QUIT_MENU_ITEM", comment: "Quit Tunes Notifier"),
            action: "terminate:",
            keyEquivalent: "q")
        
        self.statusMenu?.addItem(self.startAtLoginItem!)
        self.statusMenu?.addItem(NSMenuItem.separatorItem())
        self.statusMenu?.addItem(hideFromMenuBarForeverItem)
        self.statusMenu?.addItem(NSMenuItem.separatorItem())
        self.statusMenu?.addItem(aboutItem)
        self.statusMenu?.addItem(quitItem)
    }
    
    func updateAllMenuItems() {
        self.startAtLoginItem?.state = self.isAppPresentInLoginItems() ? 1 : 0
    }
    
    // MARK: - NSMenuDelegate
    
    func menuWillOpen(menu: NSMenu) {
        self.updateAllMenuItems()
    }
    
    // MARK: - Selected menu item Actions
    
    let helperBundleIdentifier = "com.julescoynel.Tunes-Notifier-Helper"
    
    func toogleStartAtLogin() {
        // Remove if present, add if not
        SMLoginItemSetEnabled(helperBundleIdentifier as CFString, self.isAppPresentInLoginItems() ? 0 : 1)
    }
    
    // Overide from AppDelegate to force showing about panel on top of all other windows
    func showAboutPanel() {
        NSApplication.sharedApplication().orderFrontStandardAboutPanel(nil)
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    }
    
    func hideFromMenuBarForever() {
        let confirmation: NSAlert = NSAlert()
        confirmation.messageText = NSLocalizedString("HIDE_FOREVER_CONFIRMATION_TITLE", comment: "")
        confirmation.addButtonWithTitle(NSLocalizedString("HIDE_FOREVER_CONFIRMATION_CONTINUE", comment: ""))
        confirmation.addButtonWithTitle(NSLocalizedString("HIDE_FOREVER_CONFIRMATION_CANCEL", comment: ""))
        confirmation.informativeText = NSLocalizedString("HIDE_FOREVER_CONFIRMATION_MESSAGE", comment: "")
        
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
        
        if confirmation.runModal() == NSAlertFirstButtonReturn {
            self.hideFromMenuBar = true
            
            if !self.isAppPresentInLoginItems() { // start at login
                self.toogleStartAtLogin()
            }
            
            // hide menu
            if let statusItem = self.statusItem {
                NSStatusBar.systemStatusBar().removeStatusItem(statusItem)
            }
            self.statusMenu?.removeAllItems()
        }
    }
    
    // MARK: - NSUserDefaults
    
    private func registerDefaults() {
        if let defaultsPath = NSBundle.mainBundle().pathForResource("UserDefaults", ofType: "plist") {
            if let defaultsDictionary = NSDictionary(contentsOfFile: defaultsPath) as? Dictionary<String, AnyObject> {
                NSUserDefaults.standardUserDefaults().registerDefaults(defaultsDictionary)
            }
        }
    }
    
    let userDefaultsHideForeverKey = "hideForever"
    
    var hideFromMenuBar: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(userDefaultsHideForeverKey)
        }
        set (hidden) {
            NSUserDefaults.standardUserDefaults().setBool(hidden, forKey: userDefaultsHideForeverKey)
        }
    }
    
    // MARK: - Startup
    
    func isAppPresentInLoginItems() -> Bool {
        /*
        The following is what a job dictionary looks like
        
        {
        EnableTransactions = 1;
        Label = "com.julescoynel.Tunes-Notifier-Helper";
        LastExitStatus = 0;
        LimitLoadToSessionType = Aqua;
        MachServices = {
        "com.julescoynel.Tunes-Notifier-Helper" = 0;
        };
        OnDemand = 1;
        ProgramArguments = (
        "/usr/libexec/launchproxyls",
        "com.julescoynel.Tunes-Notifier-Helper"
        );
        TimeOut = 30;
        }
        */
        
        if let jobDicts = SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? Array<NSDictionary> {
            if jobDicts.count > 0 {
                var bOnDemand: Bool = false
                
                for job in jobDicts {
                    if helperBundleIdentifier == job["Label"] as? String {
                        bOnDemand = (job["OnDemand"] as? Bool)!
                        break;
                    }
                }
                
                return bOnDemand;
            }
        }
        
        return false
    }
}


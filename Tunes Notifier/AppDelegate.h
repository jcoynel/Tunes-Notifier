//
//  AppDelegate.h
//  TunesNotifier
//
//  Created by Jules Coynel on 21/08/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

@import Cocoa;
@import ServiceManagement;
#import "TNNotifier.h"

/** Tunes Notifier Helper bundle identifier. */
NSString *const helperBundleIdentifier = @"com.julescoynel.Tunes-Notifier-Helper";

/** Application delegate. */
@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>

/** Application window. */
@property (assign) IBOutlet NSWindow *window;

/** Status bar menu. */
@property (strong) IBOutlet NSMenu *statusMenu;

/**
 Contains the application logic to handle notifications.
 
 @see TNNotifier
 */
@property (strong) TNNotifier *notifier;

/** Status bar item. */
@property (strong) NSStatusItem *statusItem;

/// ----------------------------------------------------------------------------
/** @name Menu items */
/// ----------------------------------------------------------------------------

/** Menu item to enable or disable starting the application at login. */
@property (strong) NSMenuItem *startAtLoginItem;
/**
 Menu item to hide the logo of the application from the menu bar until the
 application is manually started.
 */
@property (strong) NSMenuItem *hideFromMenuBarForeverItem;
/** Menu item to to select a colored or black and white menu bar icon. */
@property (strong) NSMenuItem *blackAndWhiteIconItem;
/** Menu item to open the cocoa application default about window. */
@property (strong) NSMenuItem *aboutItem;
/** Menu item to quit the application. */
@property (strong) NSMenuItem *quitItem;

/// ----------------------------------------------------------------------------
/** @name User preferences saved in User Defaults */
/// ----------------------------------------------------------------------------

/** Tells whether the app should always be hidden from the menu bar. */
@property (getter = shouldHideFromMenuBar) BOOL hideFromMenuBar;
/** Tells whether the menu bar icon is monochrome. */
@property (getter = isBlackAndWhiteIcon) BOOL blackAndWhiteIcon;

@end

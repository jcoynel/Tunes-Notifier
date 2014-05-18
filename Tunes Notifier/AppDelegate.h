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
#import "TNReviewRequest.h"

/** Tunes Notifier Helper bundle identifier. */
NSString *const helperBundleIdentifier = @"com.julescoynel.Tunes-Notifier-Helper";

/** Application delegate. */
@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate, TNNotifierDelegate>

/** Application window. */
@property (assign) IBOutlet NSWindow *window;

/** Status bar menu. */
@property (strong) IBOutlet NSMenu *statusMenu;

/**
 Contains the application logic to handle notifications.
 
 @see TNNotifier
 */
@property (strong) TNNotifier *notifier;

/**
 Contains the logic to ask the user to review the application on the Mac App
 Store.
 
 @see TNReviewRequest
 */
@property (strong) TNReviewRequest *reviewRequest;

/** Status bar item. */
@property (strong) NSStatusItem *statusItem;

/// ----------------------------------------------------------------------------
/** @name Menu items */
/// ----------------------------------------------------------------------------

/** Menu item that contain information about the current song. */
@property (strong) NSMenuItem *currentSongInfoItem;

/** Menu item to enable or disable all notifications. */
@property (strong) NSMenuItem *pauseNotificationsItem;

/** Menu item to enable or disable starting the application at login. */
@property (strong) NSMenuItem *startAtLoginItem;
/**
 Menu item to hide the logo of the application from the menu bar until the
 application is closed.
 */
@property (strong) NSMenuItem *hideFromMenuBarItem;
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

/** @name User preferences only valid during lifetime of the app */

/** Tells whether the notifications are paused. */
@property (nonatomic, getter = isPaused) BOOL paused;
/** Tells whether the app is temporarily hidden. */
@property (nonatomic, getter = isTemporaryHidden) BOOL temporaryHidden;

@end

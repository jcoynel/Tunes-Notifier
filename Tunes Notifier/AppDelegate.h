//
//  AppDelegate.h
//  TunesNotifier
//
//  Created by Jules Coynel on 21/08/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ServiceManagement/ServiceManagement.h>
#import "iTunes.h"
#import "TNNotifier.h"
#import "TNReviewRequest.h"

NSString *const helperBundleIdentifier = @"com.julescoynel.Tunes-Notifier-Helper";

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSMenu *statusMenu;

@property (strong) NSStatusItem *statusItem;

@property (strong) NSMenuItem *pauseNotificationsItem;
@property (strong) NSMenuItem *iTunesNotificationsItem;
@property (strong) NSMenuItem *spotityNotificationsItem;
@property (strong) NSMenuItem *startAtLoginItem;
@property (strong) NSMenuItem *hideFromMenuBarItem;
@property (strong) NSMenuItem *hideFromMenuBarForeverItem;
@property (strong) NSMenuItem *blackAndWhiteIconItem;
@property (strong) NSMenuItem *aboutItem;
@property (strong) NSMenuItem *quitItem;

@property (strong) TNNotifier *notifier;

// User preferences saved in User Defaults
@property (getter = areItunesNotificationsEnabled) BOOL itunesNotificationsEnabled;
@property (getter = areSpotifyNotificationsEnabled) BOOL spotifyNotificationsEnabled;
@property (getter = shouldHideFromMenuBar) BOOL hideFromMenuBar;
@property (getter = isBlackAndWhiteIcon) BOOL blackAndWhiteIcon;

// User preferences only valid during lifetime of the app
@property (nonatomic, getter = isPaused) BOOL paused;
@property (nonatomic, getter = isTemporaryHidden) BOOL temporaryHidden;

@property (strong) TNReviewRequest *reviewRequest;

@end

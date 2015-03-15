//
//  TNNotifier.h
//  TunesNotifier
//
//  Created by Jules Coynel on 21/08/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

@import Foundation;
@import ScriptingBridge;
#import "Spotify.h"

/**
 TNNotifier let you listen Spotify notifications and offers
 options to start and stop doing so. It also manages the notifications shown
 in the Notification Center.
 */
@interface TNNotifier : NSObject <NSUserNotificationCenterDelegate>

/// ----------------------------------------------------------------------------
/** @name Music Players */
/// ----------------------------------------------------------------------------

/** Spotify application. */
@property (strong) SpotifyApplication *spotify;

@property (strong) SBApplication *currentPlayer;

/// ----------------------------------------------------------------------------
/** @name Notifications Status */
/// ----------------------------------------------------------------------------

/** Specify whether Spotify notifications are enabled. */
@property (getter = isSpotifyEnabled) BOOL spotifyEnabled;

/// ----------------------------------------------------------------------------
/** @name Initialisation */
/// ----------------------------------------------------------------------------

/**
 Create an instance of TNNotifier with notifications enabled for all supported
 music players, starting imediately.
 
 @return An instance of TNNotifier.
 
 @see initWithSpotify:
 */
- (id)init;

/**
 Create an instance of TNNotifier with options to enable Spotify
 notifications and suspend them.
 
 @param spotifyEnabled Specify whether Spotify notifications are enabled or not.
 
 @return An instance of TNNotifier.
 
 @see init
 */
- (id)initWithSpotify:(BOOL)spotifyEnabled;

/// ----------------------------------------------------------------------------
/** @name Turning on and off all Notifications */
/// ----------------------------------------------------------------------------

/** Resume notifications. */
- (void)resume;
/** Remove all notifications from the Notification Center. */
- (void)cleanNotifications;

/// ----------------------------------------------------------------------------
/** @name Turning on and off Player Specific Notifications */
/// ----------------------------------------------------------------------------

/**
 Start or stop observing Stotify player status.
 
 @param enabled `YES` to start observing Stotify status, `NO` to stop.
 */
- (void)observeSpotifyNotifications:(BOOL)enabled;

@end

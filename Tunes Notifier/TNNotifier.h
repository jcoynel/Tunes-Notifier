//
//  TNNotifier.h
//  TunesNotifier
//
//  Created by Jules Coynel on 21/08/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ScriptingBridge/ScriptingBridge.h>
#import "iTunes.h"
#import "Spotify.h"

@protocol TNNotifierDelegate <NSObject>
- (void)currentSongDidChange;
@end

/**
 TNNotifier let you listen to iTunes and Spotify notifications and offers
 options to start and stop doing so. It also manages the notifications shown
 in the Notification Center.
 */
@interface TNNotifier : NSObject <NSUserNotificationCenterDelegate>

@property (weak) id<TNNotifierDelegate> delegate;

/// ----------------------------------------------------------------------------
/** @name Music Players */
/// ----------------------------------------------------------------------------

/** iTunes application. */
@property (strong) iTunesApplication *iTunes;
/** Spotify application. */
@property (strong) SpotifyApplication *spotify;

@property (strong) SBApplication *currentPlayer;

/// ----------------------------------------------------------------------------
/** @name Notifications Status */
/// ----------------------------------------------------------------------------

/** Specify whether all notifications suspended. */
@property (getter = isPaused) BOOL paused;
/** Specify whether iTunes notifications are enabled. */
@property (getter = isItunesEnabled) BOOL itunesEnabled;
/** Specify whether Spotify notifications are enabled. */
@property (getter = isSpotifyEnabled) BOOL spotifyEnabled;

/// ----------------------------------------------------------------------------
/** @name Initialisation */
/// ----------------------------------------------------------------------------

/**
 Create an instance of TNNotifier with notifications enabled for all supported
 music players, starting imediately.
 
 @return An instance of TNNotifier.
 
 @see initWithItunes:spotify:paused:
 @see initWithItunes:spotify:paused:delegate:
 */
- (id)init;

/**
 Create an instance of TNNotifier with options to enable iTunes and Spotify
 notifications and suspend them.
 
 @param iTunesEnabled Specify whether iTunes notifications are enabled or not.
 @param spotifyEnabled Specify whether Spotify notifications are enabled or not.
 @param paused Specify whether the notifications should be paused or not.
 
 @return An instance of TNNotifier.
 
 @see init
 @see initWithItunes:spotify:paused:delegate:
 */
- (id)initWithItunes:(BOOL)iTunesEnabled
             spotify:(BOOL)spotifyEnabled
              paused:(BOOL)paused;

/**
 Create an instance of TNNotifier with options to enable iTunes and Spotify
 notifications, suspend them and a delegate.
 
 @warning This is the default initialiser.
 
 @param iTunesEnabled Specify whether iTunes notifications are enabled or not.
 @param spotifyEnabled Specify whether Spotify notifications are enabled or not.
 @param paused Specify whether the notifications should be paused or not.
 @param delegate The delegate of the current instance of TNNotifier.
 
 @return An instance of TNNotifier.
 
 @see init
 @see initWithItunes:spotify:paused:
 */
- (id)initWithItunes:(BOOL)iTunesEnabled
             spotify:(BOOL)spotifyEnabled
              paused:(BOOL)paused
            delegate:(id<TNNotifierDelegate>)delegate;

/// ----------------------------------------------------------------------------
/** @name Turning on and off all Notifications */
/// ----------------------------------------------------------------------------

/** Suspend notifications. */
- (void)pause;
/** Resume notifications. */
- (void)resume;
/** Remove all notifications from the Notification Center. */
- (void)cleanNotifications;

/// ----------------------------------------------------------------------------
/** @name Turning on and off Player Specific Notifications */
/// ----------------------------------------------------------------------------

/**
 Start or stop observing iTunes player status.
 
 @param enabled `YES` to start observing iTunes status, `NO` to stop.
 */
- (void)observeItunesNotifications:(BOOL)enabled;

/**
 Start or stop observing Stotify player status.
 
 @param enabled `YES` to start observing Stotify status, `NO` to stop.
 */
- (void)observeSpotifyNotifications:(BOOL)enabled;

@end

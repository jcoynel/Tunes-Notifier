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


@interface TNNotifier : NSObject <NSUserNotificationCenterDelegate>

@property (strong) iTunesApplication *iTunes;
@property (strong) SpotifyApplication *spotify;

@property (getter = isPaused) BOOL paused;
@property (getter = isItunesEnabled) BOOL itunesEnabled;
@property (getter = isSpotifyEnabled) BOOL spotifyEnabled;

- (void)pause;
- (void)resume;
- (void)cleanNotifications;

- (void)observeItunesNotifications:(BOOL)enabled;
- (void)observeSpotifyNotifications:(BOOL)enabled;

// Default initialiser
- (id)initWithItunes:(BOOL)iTunesEnabled spotify:(BOOL)spotifyEnabled paused:(BOOL)paused;

@end

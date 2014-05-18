//
//  TNNotifier.m
//  TunesNotifier
//
//  Created by Jules Coynel on 21/08/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

#import "TNNotifier.h"

@interface TNNotifier ()

/**
 Check Stoptify status.
 
 This is typically triggered by an NSNotification but can also be called
 manually, passing _nil_ to the _notification_ parameter.
 
 @param notification The notification which triggered this method.
 */
- (void)checkSpotify:(NSNotification *)notification;

/**
 Display a notification in the Notification Center for a song played in Spotify.
 
 @param track The song to notify the user about.
 */
- (void)sendSpotifyNotificationForTrack:(SpotifyTrack *)track;

/**
 Display a notification in the Notification Center.
 
 @param notification The notification to display.
 */
- (void)sendNotification:(NSUserNotification *)notification;

/**
 Notifier the delegate of the current instance of TNNotifier that the current
 song has changed.
 */
- (void)notifyDelegateCurrentSongDidChange;
@end

@implementation TNNotifier

- (id)init
{
    return [self initWithSpotify:YES paused:NO];
}

- (id)initWithSpotify:(BOOL)spotifyEnabled paused:(BOOL)paused
{
    return [self initWithSpotify:spotifyEnabled paused:paused delegate:nil];
}

- (id)initWithSpotify:(BOOL)spotifyEnabled paused:(BOOL)paused delegate:(id<TNNotifierDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        _delegate = delegate;
        
        self.spotifyEnabled = spotifyEnabled;
        self.paused = paused;
        
        if (!self.paused) {
            [self resume];
        }
    }
    
    return self;
}

- (void)pause
{
    self.paused = YES;
    
    NSDistributedNotificationCenter *distributedNotificationCenter = [NSDistributedNotificationCenter defaultCenter];
    [distributedNotificationCenter removeObserver:self];
}

- (void)resume
{
    self.paused = NO;
    
    if (self.spotifyEnabled) {
        [self observeSpotifyNotifications:YES];
        [self checkSpotify:nil];
    }
}

- (void)observeSpotifyNotifications:(BOOL)enabled
{
    self.spotifyEnabled = enabled;
    
    // Always remove observer to prevent receving the same notification several times
    NSDistributedNotificationCenter *distributedNotificationCenter = [NSDistributedNotificationCenter defaultCenter];
    [distributedNotificationCenter removeObserver:self name:spotifyNotificationIdentifier object:nil];
    
    if (self.spotifyEnabled && !self.paused) {
        [distributedNotificationCenter addObserver:self selector:@selector(checkSpotify:) name:spotifyNotificationIdentifier object:nil];
    }
}

#pragma mark - Players state

- (void)checkSpotify:(NSNotification *)notification
{
    // Set Spotify in case it didn't exist when the user started Tunes Notifier
    if (!self.spotify) {
        self.spotify = [SBApplication applicationWithBundleIdentifier:spotifyBundleIdentifier];
    }
    
    if ([self.spotify isRunning]) {
        SpotifyEPlS spotifyState = self.spotify.playerState;
        
        if (spotifyState == SpotifyEPlSPlaying) {
            SpotifyTrack *currentTrack = self.spotify.currentTrack;
            
            self.currentPlayer = self.spotify;
            [self sendSpotifyNotificationForTrack:currentTrack];
        }
    }
    
    [self notifyDelegateCurrentSongDidChange];
}

#pragma mark - Notifications

- (void)sendSpotifyNotificationForTrack:(SpotifyTrack *)track
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:@[spotifyBundleIdentifier] forKeys:@[notificationUserInfoPlayerBundleIdentifier]];
    
    notification.title = track.name;
    notification.subtitle = track.artist;
    notification.informativeText = track.album;
    notification.soundName = nil;
    notification.userInfo = userInfo;
    
    [self sendNotification:notification];
}

- (void)sendNotification:(NSUserNotification *)notification
{
    NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    
    notificationCenter.delegate = self;
    [self cleanNotifications];
    [notificationCenter deliverNotification:notification];
}

- (void)cleanNotifications
{
    NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    [notificationCenter removeAllDeliveredNotifications];
}

#pragma mark - NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification
{
    /* 
     Find out which music player the notification is associated with and open
     that music player. It none is found, just clean up the notifications.
     */
    NSDictionary *userInfo = [notification userInfo];
    NSString *playerBundleIdentifier = userInfo[notificationUserInfoPlayerBundleIdentifier];
    
    if ([playerBundleIdentifier isEqualToString:spotifyBundleIdentifier]) {
        [self.spotify activate];
    } else {
        [self cleanNotifications];
    }
}

#pragma mark - Methods for TNNotifierDelegate Protocol

- (void)notifyDelegateCurrentSongDidChange
{
    [self.delegate currentSongDidChange];
}

@end

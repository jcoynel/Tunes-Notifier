//
//  TNNotifier.m
//  TunesNotifier
//
//  Created by Jules Coynel on 21/08/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

#import "TNNotifier.h"

NSString *const iTunesBundleIdentifier = @"com.apple.iTunes";
NSString *const iTunesNotificationIdentifier = @"com.apple.iTunes.playerInfo";
NSString *const spotifyBundleIdentifier = @"com.spotify.client";
NSString *const spotifyNotificationIdentifier = @"com.spotify.client.PlaybackStateChanged";
NSString *const notificationUserInfoPlayerBundleIdentifier = @"playerBundleIdentifier";

@interface TNNotifier (Private)
- (void)checkItunes:(NSNotification *)notification;
- (void)checkSpotify:(NSNotification *)notification;
- (void)sendiTunesNotificationForTrack:(iTunesTrack *)track;
- (void)sendSpotifyNotificationForTrack:(SpotifyTrack *)track;
- (void)sendNotification:(NSUserNotification *)notification;
@end

@implementation TNNotifier

- (id)init
{
    return [self initWithItunes:YES spotify:YES paused:NO];
}

// Default initialiser
- (id)initWithItunes:(BOOL)iTunesEnabled spotify:(BOOL)spotifyEnabled paused:(BOOL)paused
{
    self = [super init];
    
    if (self) {
        [self setItunesEnabled:iTunesEnabled];
        [self setSpotifyEnabled:spotifyEnabled];
        [self setPaused:paused];
        
        if ([self isPaused] == NO) {
            [self resume];
        }
    }
    
    return self;
}

- (void)pause
{
    [self setPaused:YES];
    
    NSDistributedNotificationCenter *distributedNotificationCenter = [NSDistributedNotificationCenter defaultCenter];
    [distributedNotificationCenter removeObserver:self];
}

- (void)resume
{
    [self setPaused:NO];
        
    if ([self isItunesEnabled]) {
        [self observeItunesNotifications:YES];
        [self checkItunes:nil];
    }
    
    if ([self isSpotifyEnabled]) {
        [self observeSpotifyNotifications:YES];
        [self checkSpotify:nil];
    }
}

- (void)observeItunesNotifications:(BOOL)enabled
{
    [self setItunesEnabled:enabled];
    
    // Always remove observer to prevent receving the same notification several times    
    NSDistributedNotificationCenter *distributedNotificationCenter = [NSDistributedNotificationCenter defaultCenter];
    [distributedNotificationCenter removeObserver:self name:iTunesNotificationIdentifier object:nil];

    if ([self isItunesEnabled] && ![self isPaused]) {
        [distributedNotificationCenter addObserver:self selector:@selector(checkItunes:) name:iTunesNotificationIdentifier object:nil];
    }
}

- (void)observeSpotifyNotifications:(BOOL)enabled
{
    [self setSpotifyEnabled:enabled];
    
    // Always remove observer to prevent receving the same notification several times
    NSDistributedNotificationCenter *distributedNotificationCenter = [NSDistributedNotificationCenter defaultCenter];
    [distributedNotificationCenter removeObserver:self name:spotifyNotificationIdentifier object:nil];
    
    if ([self isSpotifyEnabled] && ![self isPaused]) {
        [distributedNotificationCenter addObserver:self selector:@selector(checkSpotify:) name:spotifyNotificationIdentifier object:nil];
    }
}

#pragma mark - Players state

- (void)checkItunes:(NSNotification *)notification
{
    // Set iTunes in case it didn't exist when the user started Tunes Notifier
    if (![self iTunes]) {
        [self setITunes:[SBApplication applicationWithBundleIdentifier:iTunesBundleIdentifier]];
    }
    
    if ([[self iTunes] isRunning]) {
        iTunesEPlS iTunesState = [[self iTunes] playerState];
                
        if (iTunesState == iTunesEPlSPlaying) {
            iTunesTrack *currentTrack = [[self iTunes] currentTrack];
            [self sendiTunesNotificationForTrack:currentTrack];
        }
    }
}

- (void)checkSpotify:(NSNotification *)notification
{
    // Set Spotify in case it didn't exist when the user started Tunes Notifier
    if (![self spotify]) {
        [self setSpotify:[SBApplication applicationWithBundleIdentifier:spotifyBundleIdentifier]];
    }
    
    if ([[self spotify] isRunning]) {
        SpotifyEPlS spotifyState = [[self spotify] playerState];
        
        if (spotifyState == SpotifyEPlSPlaying) {
            SpotifyTrack *currentTrack = [[self spotify] currentTrack];
            [self sendSpotifyNotificationForTrack:currentTrack];
        }
    }
}

#pragma mark - Notifications

- (void)sendiTunesNotificationForTrack:(iTunesTrack *)track
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:@[iTunesBundleIdentifier] forKeys:@[notificationUserInfoPlayerBundleIdentifier]];
    
    [notification setTitle:[track name]];
    [notification setSubtitle:[track artist]];
    [notification setInformativeText:[track album]];
    [notification setSoundName:nil];
    [notification setUserInfo:userInfo];

    [self sendNotification:notification];
}

- (void)sendSpotifyNotificationForTrack:(SpotifyTrack *)track
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:@[spotifyBundleIdentifier] forKeys:@[notificationUserInfoPlayerBundleIdentifier]];
    
    [notification setTitle:[track name]];
    [notification setSubtitle:[track artist]];
    [notification setInformativeText:[track album]];
    [notification setSoundName:nil];
    [notification setUserInfo:userInfo];
    
    [self sendNotification:notification];
}

- (void)sendNotification:(NSUserNotification *)notification
{
    NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    
    [notificationCenter setDelegate:self];
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
    NSDictionary *userInfo = [notification userInfo];
    NSString *playerBundleIdentifier = [userInfo objectForKey:notificationUserInfoPlayerBundleIdentifier];
    
    if ([playerBundleIdentifier isEqualToString:iTunesBundleIdentifier]) {
        [self.iTunes activate];
    } else if ([playerBundleIdentifier isEqualToString:spotifyBundleIdentifier]) {
        [self.spotify activate];
    } else {
        [self cleanNotifications];
    }
}

@end

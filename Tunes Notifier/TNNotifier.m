//
//  TNNotifier.m
//  TunesNotifier
//
//  Created by Jules Coynel on 21/08/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

@import ScriptingBridge;
#import "Spotify.h"
#import "TNNotifier.h"
#import "TNTrack.h"

@interface TNNotifier () <NSUserNotificationCenterDelegate>

@property (strong, readonly) SpotifyApplication *spotify;

@end

@implementation TNNotifier

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(spotifyPlaybackStateDidChange:) name:spotifyNotificationIdentifier object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:spotifyNotificationIdentifier object:nil];
}

#pragma mark - Accessors

- (SpotifyApplication *)spotify
{
    return [SBApplication applicationWithBundleIdentifier:spotifyBundleIdentifier];
}

#pragma mark - Players state

- (void)spotifyPlaybackStateDidChange:(NSNotification *)notification
{
    if ([self.spotify isRunning]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *playerState = userInfo[@"Player State"];
        if ([playerState isEqualToString:@"Playing"]) {
            TNTrack *track = [[TNTrack alloc] initWithName:userInfo[@"Name"]
                                                    artist:userInfo[@"Artist"]
                                                     album:userInfo[@"Album"]];
            [self sendNotificationForTrack:track];
        }
    }
}

#pragma mark - Notifications

- (void)sendNotificationForTrack:(TNTrack *)track
{
    NSUserNotification *userNotification = [[NSUserNotification alloc] init];
    userNotification.title = track.name;
    userNotification.subtitle = track.artist;
    userNotification.informativeText = track.album;
    userNotification.soundName = nil;

    NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    
    notificationCenter.delegate = self;
    [self cleanNotificationCenter];
    [notificationCenter deliverNotification:userNotification];
}

- (void)cleanNotificationCenter
{
    NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    [notificationCenter removeAllDeliveredNotifications];
}

#pragma mark - NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification
{
    [self.spotify activate];
}

@end

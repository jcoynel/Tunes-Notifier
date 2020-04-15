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

@interface TNNotifier () <NSUserNotificationCenterDelegate, TNTackArtworkDownloadDelegate>

@property (strong, readonly) SpotifyApplication *spotify;

@end

@implementation TNNotifier

- (instancetype)initWithDelegate:(id<TNNotifierDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        _delegate = delegate;
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

- (BOOL)spotifyInstalled
{
    return self.spotify ? YES : NO;
}

#pragma mark - Players state

- (void)spotifyPlaybackStateDidChange:(NSNotification *)notification
{
    if ([self.spotify isRunning]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *playerState = userInfo[@"Player State"];
        if ([playerState isEqualToString:@"Playing"]) {
            /* Some old versions of spotify (e.g. 1.0.2.6) don't support
             applescript properly so we may not be able to get currentTrack. */
            if (![self.spotify respondsToSelector:@selector(currentTrack)]) {
                return;
            }
            SpotifyTrack *currentTrack = self.spotify.currentTrack;
            NSString *artworkURL;
            // Some old versions of spotify don't support "artworkUrl"
            if ([currentTrack respondsToSelector:@selector(artworkUrl)]) {
                artworkURL = currentTrack.artworkUrl;
            }
            
            self.currentTrack = [[TNTrack alloc] initWithName:userInfo[@"Name"]
                                                       artist:userInfo[@"Artist"]
                                                        album:userInfo[@"Album"]
                                                   artworkURL:artworkURL];
            
            [self.currentTrack downloadArtworkWithDelegate:self];
        }
    }
    
    [self notifyDelegateCurrentSongDidChange];
}

#pragma mark - TNTackArtworkDownloadDelegate

- (void)didFinishDownloadingArtworkForTrack:(TNTrack *)track
{
    if (self.currentTrack == track) {
        [self sendNotificationForTrack:track];
        [self notifyDelegateCurrentSongDidChange];
    }
}

#pragma mark - Notifications

- (void)sendNotificationForTrack:(TNTrack *)track
{
    // If the track doesn't contain any information, such as when playing Spotify
    // on an external device, don't show a blank notification.
    if (!track.hasAnyInformation) {
        return;
    }
    
    NSUserNotification *userNotification = [[NSUserNotification alloc] init];
    userNotification.title = track.name;
    userNotification.subtitle = track.artist;
    userNotification.informativeText = track.album;
    userNotification.soundName = nil;
    userNotification.contentImage = track.artworkImage;

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

- (void)openSpotify
{
    [self.spotify activate];
}

#pragma mark - NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center
       didActivateNotification:(NSUserNotification *)notification
{
    [self openSpotify];
}

#pragma mark - Methods for TNNotifierDelegate Protocol

- (void)notifyDelegateCurrentSongDidChange
{
    [self.delegate currentSongDidChange];
}

@end

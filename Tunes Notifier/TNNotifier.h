//
//  TNNotifier.h
//  TunesNotifier
//
//  Created by Jules Coynel on 21/08/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

@import Foundation;

@protocol TNNotifierDelegate <NSObject>
- (void)currentSongDidChange;
@end

@class TNTrack;
@interface TNNotifier : NSObject

@property (nonatomic, weak) id<TNNotifierDelegate> delegate;

@property (nonatomic, readonly) BOOL spotifyInstalled;

@property (nonatomic, strong) TNTrack *currentTrack;

- (void)cleanNotificationCenter;
- (void)openSpotify;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDelegate:(id<TNNotifierDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@end

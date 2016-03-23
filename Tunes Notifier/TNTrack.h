//
//  TNTrack.h
//  Tunes Notifier
//
//  Created by Jules Coynel on 14/03/2015.
//  Copyright (c) 2015 Jules Coynel. All rights reserved.
//

@import Foundation;

@interface TNTrack : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *artist;
@property (nonatomic, strong, readonly) NSString *album;
@property (nonatomic, strong, readonly) NSString *artworkURL;

- (instancetype)init __unavailable;
- (instancetype)initWithName:(NSString *)name
                      artist:(NSString *)artist
                       album:(NSString *)album
                  artworkURL:(NSString *)artworkURL;

@end

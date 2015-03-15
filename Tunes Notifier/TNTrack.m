//
//  TNTrack.m
//  Tunes Notifier
//
//  Created by Jules Coynel on 14/03/2015.
//  Copyright (c) 2015 Jules Coynel. All rights reserved.
//

#import "TNTrack.h"

@implementation TNTrack

- (instancetype)initWithName:(NSString *)name artist:(NSString *)artist album:(NSString *)album
{
    self = [super init];
    
    if (self) {
        _name = name;
        _artist = artist;
        _album = album;
    }
    
    return self;
}

@end

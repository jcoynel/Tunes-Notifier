//
//  TNTrack.m
//  Tunes Notifier
//
//  Created by Jules Coynel on 14/03/2015.
//  Copyright (c) 2015 Jules Coynel. All rights reserved.
//

#import "TNTrack.h"

@interface TNTrack ()

@property (nonatomic, strong) NSImage *artworkImage;
@property (nonatomic, weak) id<TNTackArtworkDownloadDelegate> delegate;

@property (nonatomic, strong) NSURLSessionDataTask *artworkTask;

@end

@implementation TNTrack

- (instancetype)initWithName:(NSString *)name
                      artist:(NSString *)artist
                       album:(NSString *)album
                  artworkURL:(NSString *)artworkURL
{
    self = [super init];
    
    if (self) {
        _name = name;
        _artist = artist;
        _album = album;
        if (artworkURL) {
            // Force HTTPS when the artwork URL is HTTP
            NSURLComponents *components = [NSURLComponents componentsWithString:artworkURL];
            if ([components.scheme isEqual: @"http"]) {
                components.scheme = @"https";
            }
            _artworkURL = components.URL;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [self cancelArtworkDownload];
}

#pragma mark -

- (BOOL)hasAnyInformation
{
    return (self.name.length > 0 || self.artist.length > 0 || self.album.length > 0 || self.artworkURL);
}

#pragma mark - Artwork Download

- (void)downloadArtworkWithDelegate:(id<TNTackArtworkDownloadDelegate>)delegate
{
    self.delegate = delegate;
    
    if (!self.artworkURL) {
        [self.delegate didFinishDownloadingArtworkForTrack:self];
        return;
    }
    
    /*
     We may get several types of URLs from artworkURL:
     - http://images.spotify.com/image/302b4ec4105699130036e13a9f9f36c725a3ebba
     - http://i.scdn.co/image/d437791a5159ac23270b8850c307c7da98e246cb
     - spotify:localfileimage:%2FUsers%2FJules%2FMusic%2FiTunes%2FiTunes%20Media%2FMusic%2FWALK%20THE%20MOON%2FTalking%20Is%20Hard%2F01%20Different%20Colors.m4a
     
     The latter is not supported by NSURLSession, which will return a kCFURLErrorUnsupportedURL error.
     */
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.timeoutIntervalForResource = 1.0;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    __weak typeof(self) weakSelf = self;
    self.artworkTask = [session dataTaskWithURL:self.artworkURL
                              completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                  if (data) {
                                      weakSelf.artworkImage = [[NSImage alloc] initWithData:data];
                                  }
                                  
                                  BOOL cancelled = error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled;
                                  if (!cancelled) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [weakSelf.delegate didFinishDownloadingArtworkForTrack:weakSelf];
                                      });
                                  }
                              }];
    
    [self.artworkTask resume];
}

- (void)cancelArtworkDownload
{
    self.delegate = nil;
    [self.artworkTask cancel];
    self.artworkTask = nil;
}

@end

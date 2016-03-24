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
        _artworkURL = artworkURL ? [NSURL URLWithString:artworkURL] : nil;
    }
    
    return self;
}

- (void)dealloc
{
    [self cancelArtworkDownload];
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
     We may get two types of URLs from artworkURL:
     - http://images.spotify.com/image/302b4ec4105699130036e13a9f9f36c725a3ebba
     - spotify:localfileimage:%2FUsers%2FJules%2FMusic%2FiTunes%2FiTunes%20Media%2FMusic%2FWALK%20THE%20MOON%2FTalking%20Is%20Hard%2F01%20Different%20Colors.m4a
     
     The second is not supported by NSURLSession, which will return a kCFURLErrorUnsupportedURL error.
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
                                      [weakSelf.delegate didFinishDownloadingArtworkForTrack:weakSelf];
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

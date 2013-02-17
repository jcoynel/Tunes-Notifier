//
//  AppDelegate.h
//  TunesNotifierHelper
//
//  Created by Jules Coynel on 22/08/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NSString *const mainAppBundleIdentifier = @"com.julescoynel.Tunes-Notifier";
NSString *const mainAppFileName = @"Tunes Notifier";

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@end

//
//  AppDelegate.m
//  TunesNotifierHelper
//
//  Created by Jules Coynel on 22/08/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    BOOL alreadyRunning = NO;
    
    NSArray *running = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in running) {
        if ([app.bundleIdentifier isEqualToString:mainAppBundleIdentifier]) {
            alreadyRunning = YES;
        }
    }
    
    if (!alreadyRunning) {
        NSString *path = [[NSBundle mainBundle] bundlePath]; // /Applications/Tunes Notifier.app/Contents/Library/LoginItems/Tunes Notifier Helper.app
        NSArray *p = [path pathComponents];
        NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:p];
        
        [pathComponents removeLastObject]; // /Applications/Tunes Notifier.app/Contents/Library/LoginItems/
        [pathComponents removeLastObject]; // /Applications/Tunes Notifier.app/Contents/Library/
        [pathComponents removeLastObject]; // /Applications/Tunes Notifier.app/Contents/
        [pathComponents removeLastObject]; // /Applications/Tunes Notifier.app/
        
        NSURL *newUrl = [NSURL fileURLWithPathComponents:pathComponents];
        [[NSWorkspace sharedWorkspace] openApplicationAtURL:newUrl
                                              configuration:[NSWorkspaceOpenConfiguration configuration]
                                          completionHandler:^(NSRunningApplication * _Nullable app, NSError * _Nullable error) {
            [NSApp terminate:nil];
        }];
    } else {
        [NSApp terminate:nil];
    }
}

@end

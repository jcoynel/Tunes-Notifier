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
        if ([[app bundleIdentifier] isEqualToString:mainAppBundleIdentifier]) {
            alreadyRunning = YES;
        }
    }
    
    if (!alreadyRunning) {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSArray *p = [path pathComponents];
        NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:p];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents removeLastObject];
        [pathComponents addObject:@"MacOS"];
        [pathComponents addObject:mainAppFileName];
        NSString *newPath = [NSString pathWithComponents:pathComponents];
        [[NSWorkspace sharedWorkspace] launchApplication:newPath];
    }
    
    [NSApp terminate:nil];
}

@end

//
//  AppDelegate.h
//  TunesNotifier
//
//  Created by Jules Coynel on 21/08/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

@import Cocoa;
@import ServiceManagement;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (strong) IBOutlet NSMenu *statusMenu;

@end

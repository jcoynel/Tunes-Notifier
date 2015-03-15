//
//  AppDelegate.m
//  TunesNotifier
//
//  Created by Jules Coynel on 21/08/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

#import "AppDelegate.h"
#import "TNNotifier.h"

NSString *const helperBundleIdentifier = @"com.julescoynel.Tunes-Notifier-Helper";

@interface AppDelegate ()

@property (strong) NSStatusItem *statusItem;
@property (strong) NSMenuItem *startAtLoginItem;

- (BOOL)isAppPresentInLoginItems;

@property (strong) TNNotifier *notifier;

@property (getter = shouldHideFromMenuBar) BOOL hideFromMenuBar;

@end

@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"]]];
    
    self.notifier = [[TNNotifier alloc] init];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    // The menu is currently hidden, therefore show it
    if (self.shouldHideFromMenuBar) {
        self.hideFromMenuBar = NO;
        [self setupMenu];
    }
    
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.notifier cleanNotificationCenter];
}

- (void)awakeFromNib
{
    if (!self.shouldHideFromMenuBar) { // don't show the menu if user asked for it to be always hidden
        [self setupMenu];
    }
}

#pragma mark - Setting up and updating UI

- (void)setupMenu
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    [self.statusItem setMenu:self.statusMenu];
    
    NSImage *statusImage = [NSImage imageNamed:@"status"];
    [statusImage setTemplate:YES];
    
    [self.statusItem setImage:statusImage];
    [self.statusItem setHighlightMode:YES];
    
    self.startAtLoginItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"START_MENU_ITEM", @"Start at login")
                                                       action:@selector(toogleStartAtLogin)
                                                keyEquivalent:@"s"];
    
    NSMenuItem *hideFromMenuBarForeverItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"HIDE_FOREVER_MENU_ITEM", @"Hide from menu bar forever")
                                                                        action:@selector(hideFromMenuBarForever)
                                                                 keyEquivalent:@"H"];
    
    NSMenuItem *aboutItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"ABOUT_MENU_ITEM", @"About Tunes Notifier")
                                                       action:@selector(showAboutPanel)
                                                keyEquivalent:@""];
    
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"QUIT_MENU_ITEM", @"Quit Tunes Notifier")
                                                      action:@selector(terminate:)
                                               keyEquivalent:@"q"];
    
    [self.statusMenu addItem:self.startAtLoginItem];
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    [self.statusMenu addItem:hideFromMenuBarForeverItem];
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    [self.statusMenu addItem:aboutItem];
    [self.statusMenu addItem:quitItem];
}

- (void)updateAllMenuItems
{
    [self.startAtLoginItem setState:self.isAppPresentInLoginItems];
}

#pragma mark - NSMenuDelegate

- (void)menuWillOpen:(NSMenu *)menu
{
    [self updateAllMenuItems];
}

# pragma mark - Selected menu item Actions

- (void)toogleStartAtLogin
{
    // Remove if present, add if not
    SMLoginItemSetEnabled((__bridge CFStringRef)helperBundleIdentifier, ![self isAppPresentInLoginItems]);
}

// Overide from AppDelegate to force showing about panel on top of all other windows
- (void)showAboutPanel
{
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:nil];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (void)hideFromMenuBarForever
{
    NSAlert *confirmation = [NSAlert alertWithMessageText:NSLocalizedString(@"HIDE_FOREVER_CONFIRMATION_TITLE", nil)
                                            defaultButton:NSLocalizedString(@"HIDE_FOREVER_CONFIRMATION_CONTINUE", nil)
                                          alternateButton:NSLocalizedString(@"HIDE_FOREVER_CONFIRMATION_CANCEL", nil)
                                              otherButton:nil
                                informativeTextWithFormat:NSLocalizedString(@"HIDE_FOREVER_CONFIRMATION_MESSAGE", nil)];
    
    [confirmation beginSheetModalForWindow:self.window
                             modalDelegate:self
                            didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                               contextInfo:NULL];
    
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

#pragma mark - Handle hide forever confirmation

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn) { // user agreed to hide forever
        self.hideFromMenuBar = YES;
        
        if (![self isAppPresentInLoginItems]) { // start at login
            [self toogleStartAtLogin];
        }
        
        // hide menu
        NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
        [statusBar removeStatusItem:self.statusItem];
        [self.statusMenu removeAllItems];
    }
}

#pragma mark - NSUserDefaults

- (BOOL)shouldHideFromMenuBar
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:userDefaultsHideForeverKey];
}

- (void)setHideFromMenuBar:(BOOL)hidden
{
    [[NSUserDefaults standardUserDefaults] setBool:hidden forKey:userDefaultsHideForeverKey];
}

#pragma mark - Startup

- (BOOL)isAppPresentInLoginItems
{
    /*
     The following is what a job dictionary looks like
     
     {
     EnableTransactions = 1;
     Label = "com.julescoynel.Tunes-Notifier-Helper";
     LastExitStatus = 0;
     LimitLoadToSessionType = Aqua;
     MachServices = {
     "com.julescoynel.Tunes-Notifier-Helper" = 0;
     };
     OnDemand = 1;
     ProgramArguments = (
     "/usr/libexec/launchproxyls",
     "com.julescoynel.Tunes-Notifier-Helper"
     );
     TimeOut = 30;
     }
     */
    
    NSArray *jobDicts = (NSArray *)CFBridgingRelease(SMCopyAllJobDictionaries(kSMDomainUserLaunchd));
    
    if ((jobDicts != nil) && [jobDicts count] > 0) {
        BOOL bOnDemand = NO;
        
        for (NSDictionary * job in jobDicts) {
            if ([helperBundleIdentifier isEqualToString:job[@"Label"]]) {
                bOnDemand = [job[@"OnDemand"] boolValue];
                break;
            }
        }
        
        return bOnDemand;
    }
    
    return NO;
}

@end

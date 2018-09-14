//
//  AppDelegate.m
//  TunesNotifier
//
//  Created by Jules Coynel on 21/08/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

#import "AppDelegate.h"
#import "NSString+MaxWidth.h"
#import "TNTrack.h"

NSString *const helperBundleIdentifier = @"com.julescoynel.Tunes-Notifier-Helper";

@interface AppDelegate ()

@property (strong) NSStatusItem *statusItem;
@property (strong) NSMenuItem *currentSongInfoItem;
@property (strong) NSMenuItem *startAtLoginItem;

- (BOOL)isAppPresentInLoginItems;

@property (strong) TNNotifier *notifier;

@property (getter = shouldHideFromMenuBar) BOOL hideFromMenuBar;

- (void)updateCurrentSongMenuItem;

- (NSAttributedString *)attributedTitleForSongWithName:(NSString *)name
                                                artist:(NSString *)artist
                                                 album:(NSString *)album;

@end

@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"]]];
    
    self.notifier = [[TNNotifier alloc] initWithDelegate:self];
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
    
    self.currentSongInfoItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"NO_SONG_PLAYING", @"No song playing.")
                                                          action:@selector(openSpotify)
                                                   keyEquivalent:@""];
    
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
    
    [self.statusMenu addItem:self.currentSongInfoItem];
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    [self.statusMenu addItem:self.startAtLoginItem];
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    [self.statusMenu addItem:hideFromMenuBarForeverItem];
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    [self.statusMenu addItem:aboutItem];
    [self.statusMenu addItem:quitItem];
}

- (void)updateCurrentSongMenuItem
{
    BOOL songPlaying = NO;
    
    NSString *name = nil;
    NSString *artist = nil;
    NSString *album = nil;
    NSImage *artworkImage = nil;
    
    if (self.notifier.currentTrack) {
        songPlaying = YES;
        
        TNTrack *track = self.notifier.currentTrack;
        name = track.name;
        artist = track.artist;
        album = track.album;
        artworkImage = track.artworkImage;
    }
    
    if (!songPlaying) {
        self.currentSongInfoItem.attributedTitle = nil;
        self.currentSongInfoItem.image = nil;
        self.currentSongInfoItem.title = NSLocalizedString(@"NO_SONG_PLAYING", @"No song playing...");
        self.currentSongInfoItem.action = nil;
    } else {
        if (!artworkImage) {
            artworkImage = [NSImage imageNamed:@"AppIcon"];
        }
        [artworkImage setSize:NSMakeSize(60, 60)];
        
        self.currentSongInfoItem.image = artworkImage;
        self.currentSongInfoItem.attributedTitle = [self attributedTitleForSongWithName:name artist:artist album:album];
        self.currentSongInfoItem.action = @selector(openSpotify);
    }
}

- (void)updateAllMenuItems
{
    [self updateCurrentSongMenuItem];
    [self.startAtLoginItem setState:self.isAppPresentInLoginItems];
}

- (NSAttributedString *)attributedTitleForSongWithName:(NSString *)name artist:(NSString *)artist album:(NSString *)album
{
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *titleFont = [fontManager fontWithFamily:@"Lucida Grande" traits:NSBoldFontMask weight:0 size:14.0f];
    NSFont *artistFont = [fontManager fontWithFamily:@"Lucida Grande" traits:NSBoldFontMask weight:0 size:12.0f];
    NSFont *albumFont = [fontManager fontWithFamily:@"Lucida Grande" traits:0 weight:0 size:12.0f];
    
    NSString *titleString = name.length > 0 ? [name stringWithFont:titleFont maxWidth:240] : NSLocalizedString(@"UNKNOWN_TRACK", @"Unknown track");
    NSString *artistString = artist.length > 0 ? [artist stringWithFont:artistFont maxWidth:240] : NSLocalizedString(@"UNKNOWN_ARTIST", @"Unknown artist");
    NSString *albumString = album.length > 0 ? [album stringWithFont:albumFont maxWidth:240] : NSLocalizedString(@"UNKNOWN_ALBUM", @"Unknown album");
    
    NSString *menuTitle = [NSString stringWithFormat:@" %@\n %@\n %@", titleString, artistString, albumString];
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:menuTitle];
    
    NSDictionary *titleAttributes = @{NSFontAttributeName: titleFont};
    NSDictionary *artistAttributes = @{NSFontAttributeName: artistFont};
    NSDictionary *albumAttributes = @{NSFontAttributeName: albumFont};
    
    [attributedTitle addAttributes:titleAttributes range:[menuTitle rangeOfString:titleString]];
    [attributedTitle addAttributes:artistAttributes range:[menuTitle rangeOfString:artistString]];
    [attributedTitle addAttributes:albumAttributes range:[menuTitle rangeOfString:albumString]];
    
    return attributedTitle;
}

#pragma mark - NSMenuDelegate

- (void)menuWillOpen:(NSMenu *)menu
{
    [self updateAllMenuItems];
}

#pragma mark - TNNotifierDelegate

- (void)currentSongDidChange
{
    // Refresh current song info if the menu is visible
    if (!self.statusMenu.isTornOff) {
        [self updateCurrentSongMenuItem];
        [self.statusMenu update];
    }
}

# pragma mark - Selected menu item Actions

- (void)openSpotify
{
    [self.notifier openSpotify];
}

- (void)toogleStartAtLogin
{
    BOOL autoStart = ![self isAppPresentInLoginItems];
    [self setAppPresentInLoginItems:autoStart];
}

// Overide from AppDelegate to force showing about panel on top of all other windows
- (void)showAboutPanel
{
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:nil];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (void)hideFromMenuBarForever
{
    NSAlert *confirmation = [[NSAlert alloc] init];
    confirmation.messageText = NSLocalizedString(@"HIDE_FOREVER_CONFIRMATION_TITLE", nil);
    confirmation.informativeText = NSLocalizedString(@"HIDE_FOREVER_CONFIRMATION_MESSAGE", nil);
    [confirmation addButtonWithTitle:NSLocalizedString(@"HIDE_FOREVER_CONFIRMATION_CONTINUE", nil)];
    [confirmation addButtonWithTitle:NSLocalizedString(@"HIDE_FOREVER_CONFIRMATION_CANCEL", nil)];
    NSModalResponse response = [confirmation runModal];
    if (response == NSAlertFirstButtonReturn) {
        self.hideFromMenuBar = YES;
        [self setAppPresentInLoginItems:YES]; // start at login
        
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

- (void)setAppPresentInLoginItems:(BOOL)present
{
    SMLoginItemSetEnabled((__bridge CFStringRef)helperBundleIdentifier, present);
}

@end

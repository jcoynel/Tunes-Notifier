//
//  AppDelegate.m
//  TunesNotifier
//
//  Created by Jules Coynel on 21/08/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

#import "AppDelegate.h"
#import "NSString+MaxWidth.h"

/**
 Number of seconds before showing a review request.
 
 This is used to delay showing review request when the app starts, which is
 likely to be when the user starts it's computer. It therefore leaves a few
 seconds for the other apps starting automatically at login to do so and prevent
 from hidding the review request.
 */
static NSInteger const delayInSecondsBeforeShowingReviewRequest = 10;

@interface AppDelegate ()

/// ----------------------------------------------------------------------------
/** @name Opening Music Players */
/// ----------------------------------------------------------------------------

- (void)openCurrentPlayer;

/// ----------------------------------------------------------------------------
/** @name Setting up and updating UI */
/// ----------------------------------------------------------------------------

/**
 Initialise each menu item, add them to the menu and set the related properties.
 */
- (void)setupMenu;

/**
 Update the current song menu item.
 */
- (void)updateCurrentSongMenuItem;

/**
 Set the appearance of all menu items.
 
 This is typically called before the menu appears to update the text and tick or
 untick each of the menu items based on user preferences.
 */
- (void)updateAllMenuItems;

/**
 Generate an attributed string with the name, artist and album of a song.
 
 @param name Name of the song.
 @param artist Artist of the song.
 @param album Album of the song.
 
 @return Attributed title string for the song.
 */
- (NSAttributedString *)attributedTitleForSongWithName:(NSString *)name
                                                artist:(NSString *)artist
                                                 album:(NSString *)album;

/// ----------------------------------------------------------------------------
/** @name Handle interactions with menu items */
/// ----------------------------------------------------------------------------

/** Pause all notifications if currently enabled or resume them if paused. */
- (void)tooglePauseNotifications;
/** Set Tunes Notifier to start at login if it isn't and vice versa. */
- (void)toogleStartAtLogin;
/** Hide the menu bar icon until the user restarts its computer. */
- (void)hideFromMenuBar;
/** Hide the menu bar icon forever after the user is asked for confirmation. */
- (void)hideFromMenuBarForever;
/** Disable iTunes notifications if there are enabled and vice versa. */
- (void)toogleItunesNotificationsEnabled;
/** Disable Spotify notifications if there are enabled and vice versa. */
- (void)toogleSpotifyNotificationsEnabled;
/** Set the menu icon to monochrome if currently coloured and vice versa. */
- (void)toogleIconColor;

/// ----------------------------------------------------------------------------
/** @name User Defaults */
/// ----------------------------------------------------------------------------

/**
 Check whether Tunes Notifier is present in the list of apps starting at login.
 
 @return `YES` if Tunes Notifier is in the list of apps starting at login. `NO`
 otherwise.
 */
- (BOOL)isAppPresentInLoginItems;
@end

@implementation AppDelegate

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Load default defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"]]];
    
    self.temporaryHidden = NO;
    self.paused = NO;
    self.notifier = [[TNNotifier alloc] initWithItunes:self.itunesNotificationsEnabled spotify:self.areSpotifyNotificationsEnabled paused:NO delegate:self];
    
    // Set up review request
    self.reviewRequest = [[TNReviewRequest alloc] init];
    
    if ([self.reviewRequest shouldAskForReview]) {
        [self.reviewRequest performSelector:@selector(askForReview)
                                 withObject:nil
                                 afterDelay:delayInSecondsBeforeShowingReviewRequest];
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    // The menu is currently hidden, therefore show it
    if (self.shouldHideFromMenuBar || self.isTemporaryHidden) {
        self.hideFromMenuBar = NO;
        self.temporaryHidden = NO;
        [self setupMenu];
    }
    
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    // Force saving user defaults
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // remove all notifications from notification center
    [self.notifier cleanNotifications];
}

- (void)awakeFromNib
{
    if (!self.shouldHideFromMenuBar) { // don't show the menu if user asked for it to be always hidden
        [self setupMenu];
    }
}

#pragma mark - Opening Music Players

- (void)openCurrentPlayer
{
    [self.notifier.currentPlayer activate];
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

#pragma mark - Setting up and updating UI

- (void)setupMenu
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    [self.statusItem setMenu:self.statusMenu];
    if (self.isBlackAndWhiteIcon) {
        [self.statusItem setImage:[NSImage imageNamed:@"status_bw"]];
    } else {
        [self.statusItem setImage:[NSImage imageNamed:@"status"]];
    }
    [self.statusItem setHighlightMode:YES];
    
    self.currentSongInfoItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"NO_SONG_PLAYING", @"No song playing.")
                                                          action:@selector(openCurrentPlayer)
                                                   keyEquivalent:@""];
    
    self.pauseNotificationsItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"PAUSE_MENU_ITEM", @"Pause notifications")
                                                             action:@selector(tooglePauseNotifications)
                                                      keyEquivalent:@"p"];
    
    self.iTunesNotificationsItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"ITUNES_MENU_ITEM", @"iTunes")
                                                              action:@selector(toogleItunesNotificationsEnabled)
                                                       keyEquivalent:@""];
    
    self.spotityNotificationsItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"SPOTIFY_MENU_ITEM", @"Spotify")
                                                               action:@selector(toogleSpotifyNotificationsEnabled)
                                                        keyEquivalent:@""];
    
    self.startAtLoginItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"START_MENU_ITEM", @"Start at login")
                                                       action:@selector(toogleStartAtLogin)
                                                keyEquivalent:@"s"];
    
    self.hideFromMenuBarItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"HIDE_MENU_ITEM", @"Hide from menu bar")
                                                          action:@selector(hideFromMenuBar)
                                                   keyEquivalent:@"h"];
    
    self.hideFromMenuBarForeverItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"HIDE_FOREVER_MENU_ITEM", @"Hide from menu bar forever")
                                                                 action:@selector(hideFromMenuBarForever)
                                                          keyEquivalent:@"H"];
    
    self.blackAndWhiteIconItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"BLACK_AND_WHITE_ICON_MENU_ITEM", @"Black and white icon in menu")
                                                            action:@selector(toogleIconColor)
                                                     keyEquivalent:@"b"];
    
    self.aboutItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"ABOUT_MENU_ITEM", @"About Tunes Notifier")
                                                action:@selector(showAboutPanel)
                                         keyEquivalent:@""];
    
    self.quitItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"QUIT_MENU_ITEM", @"Quit Tunes Notifier")
                                               action:@selector(terminate:)
                                        keyEquivalent:@"q"];
    
    [self.statusMenu addItem:self.currentSongInfoItem];
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    [self.statusMenu addItem:self.pauseNotificationsItem];
    [self.statusMenu addItem:self.iTunesNotificationsItem];
    [self.statusMenu addItem:self.spotityNotificationsItem];
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    [self.statusMenu addItem:self.startAtLoginItem];
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    [self.statusMenu addItem:self.blackAndWhiteIconItem];
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    [self.statusMenu addItem:self.hideFromMenuBarItem];
    [self.statusMenu addItem:self.hideFromMenuBarForeverItem];
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    [self.statusMenu addItem:self.aboutItem];
    [self.statusMenu addItem:self.quitItem];
}

- (void)updateCurrentSongMenuItem
{
    BOOL songPlaying = NO;
    
    NSString *name = nil;
    NSString *artist = nil;
    NSString *album = nil;
    NSImage *artworkImage = nil;
    
    Class currentPlayerClass = self.notifier.currentPlayer.class;
    if (currentPlayerClass == NSClassFromString(@"ITunesApplication") && self.notifier.iTunes.playerState == iTunesEPlSPlaying) {
        songPlaying = YES;
        
        iTunesTrack *track = self.notifier.iTunes.currentTrack;
        name = track.name;
        artist = [track.artist length] > 0 ? track.artist : self.notifier.iTunes.currentStreamTitle;
        album = track.album;
        iTunesArtwork *artwork = (iTunesArtwork *)[[[track artworks] get] lastObject];
        artworkImage = [[NSImage alloc] initWithData:artwork.rawData];
    } else if (currentPlayerClass == NSClassFromString(@"SpotifyApplication") && self.notifier.spotify.playerState == SpotifyEPlSPlaying) {
        songPlaying = YES;
        
        SpotifyTrack *track = self.notifier.spotify.currentTrack;
        name = track.name;
        artist = track.artist;
        album = track.album;
        artworkImage = track.artwork;
    }
    
    if (!songPlaying) {
        self.currentSongInfoItem.attributedTitle = nil;
        self.currentSongInfoItem.image = nil;
        self.currentSongInfoItem.title = NSLocalizedString(@"NO_SONG_PLAYING", @"No song playing...");
        self.currentSongInfoItem.action = nil;
    } else {
        if (!artworkImage) {
            artworkImage = [[NSBundle mainBundle] imageForResource:@"icon.icns"];
        }
        [artworkImage setSize:NSMakeSize(60, 60)];
        
        self.currentSongInfoItem.image = artworkImage;
        self.currentSongInfoItem.attributedTitle = [self attributedTitleForSongWithName:name artist:artist album:album];
        self.currentSongInfoItem.action = @selector(openCurrentPlayer);
    }
}

- (void)updateAllMenuItems
{
    [self updateCurrentSongMenuItem];
    
    [self.startAtLoginItem setState:self.isAppPresentInLoginItems];
    
    [self.pauseNotificationsItem setState:self.isPaused];
    
    [self.iTunesNotificationsItem setState:self.areItunesNotificationsEnabled];
    
    [self.spotityNotificationsItem setState:self.areSpotifyNotificationsEnabled];
    
    [self.blackAndWhiteIconItem setState:self.isBlackAndWhiteIcon];
    
    // If iTunes and Spotify notifications are both disabled, we don't want to be able to hide the app
    // So we disable hide menus
    if (!self.areItunesNotificationsEnabled && !self.areSpotifyNotificationsEnabled) {
        // To disable a menu we need to set its action to nil
        [self.hideFromMenuBarItem setAction:nil];
        [self.hideFromMenuBarForeverItem setAction:nil];
    } else {
        [self.hideFromMenuBarItem setAction:@selector(hideFromMenuBar)];
        [self.hideFromMenuBarForeverItem setAction:@selector(hideFromMenuBarForever)];
    }
}

- (NSAttributedString *)attributedTitleForSongWithName:(NSString *)name artist:(NSString *)artist album:(NSString *)album
{
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *titleFont = [fontManager fontWithFamily:@"Lucida Grande" traits:NSBoldFontMask weight:0 size:14.0f];
    NSFont *artistFont = [fontManager fontWithFamily:@"Lucida Grande" traits:NSBoldFontMask weight:0 size:12.0f];
    NSFont *albumFont = [fontManager fontWithFamily:@"Lucida Grande" traits:0 weight:0 size:12.0f];
    
    NSString *titleString = name.length > 0 ? [name stringWithFont:titleFont maxWidth:240] : @"Unknown Track";
    NSString *artistString = artist.length > 0 ? [artist stringWithFont:titleFont maxWidth:240] : @"Unknown Artist";
    NSString *albumString = album.length > 0 ? [album stringWithFont:titleFont maxWidth:240] : @"Unknown Album";
    
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

# pragma mark - Selected menu item Actions

- (void)tooglePauseNotifications
{
    if (self.isPaused) {
        [self.notifier resume];
        self.paused = NO;
    } else {
        [self.notifier pause];
        self.paused = YES;
    }
}

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

- (void)hideFromMenuBar
{
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    [statusBar removeStatusItem:self.statusItem];
    [self.statusMenu removeAllItems];
    
    self.temporaryHidden = YES;
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

- (void)toogleItunesNotificationsEnabled
{
    BOOL newState = !self.areItunesNotificationsEnabled;
    
    self.itunesNotificationsEnabled = newState;
    [self.notifier observeItunesNotifications:newState];
}

- (void)toogleSpotifyNotificationsEnabled
{
    BOOL newState = !self.areSpotifyNotificationsEnabled;
    
    self.spotifyNotificationsEnabled = newState;
    [self.notifier observeSpotifyNotifications:newState];
}

- (void)toogleIconColor
{
    NSString *imageName = self.isBlackAndWhiteIcon ? @"status" : @"status_bw";
    [self.statusItem setImage:[NSImage imageNamed:imageName]];
    
    self.blackAndWhiteIcon = !self.blackAndWhiteIcon;
}

#pragma mark - Handle hide forever confirmation

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn) { // user agreed to hide forever
        self.hideFromMenuBar = YES;
        
        if (![self isAppPresentInLoginItems]) { // start at login
            [self toogleStartAtLogin];
        }
        
        if (self.isPaused) { // resume notifications
            [self tooglePauseNotifications];
        }
        
        // hide menu
        [self hideFromMenuBar];
    }
}

#pragma mark - NSUserDefaults

#pragma mark Itunes

- (BOOL)areItunesNotificationsEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:userDefaultsItunesNotificationsKey];
}

- (void)setItunesNotificationsEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:userDefaultsItunesNotificationsKey];
}

#pragma mark Spotify

- (BOOL)areSpotifyNotificationsEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:userDefaultsSpotifyNotificationsKey];
}

- (void)setSpotifyNotificationsEnabled:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:userDefaultsSpotifyNotificationsKey];
}

#pragma mark Hide from menu bar

- (BOOL)shouldHideFromMenuBar
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:userDefaultsHideForeverKey];
}

- (void)setHideFromMenuBar:(BOOL)hidden
{
    [[NSUserDefaults standardUserDefaults] setBool:hidden forKey:userDefaultsHideForeverKey];
}

#pragma mark Black and white icon

- (BOOL)isBlackAndWhiteIcon
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:userDefaultsBlackAndWhiteIconKey];
}

- (void)setBlackAndWhiteIcon:(BOOL)blackAndWhite
{
    [[NSUserDefaults standardUserDefaults] setBool:blackAndWhite forKey:userDefaultsBlackAndWhiteIconKey];
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

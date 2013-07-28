/** NSUserDefault key to save whether iTunes notifications are enabled. */
static NSString *const userDefaultsItunesNotificationsKey = @"itunesNotificationsEnabled";
/** NSUserDefault key to save whether Spotify notifications are enabled. */
static NSString *const userDefaultsSpotifyNotificationsKey = @"spotifyNotificationsEnabled";
/** NSUserDefault key to save whether Tunes Notifier should always be hidden. */
static NSString *const userDefaultsHideForeverKey = @"hideForever";
/** NSUserDefault key to save whether the menu icon should be monochrome or coloured. */
static NSString *const userDefaultsBlackAndWhiteIconKey = @"blackAndWhiteMenuIcon";

/** iTunes app bundle identifier. */
static NSString *const iTunesBundleIdentifier = @"com.apple.iTunes";
/** iTunes player info notification identifier. */
static NSString *const iTunesNotificationIdentifier = @"com.apple.iTunes.playerInfo";
/** Spotify app bundle identifier. */
static NSString *const spotifyBundleIdentifier = @"com.spotify.client";
/** Spotify player info notification identifier. */
static NSString *const spotifyNotificationIdentifier = @"com.spotify.client.PlaybackStateChanged";
/**
 Key used to identify the player in the userInfo dictionary of an
 NSNotification.
 
 The value set to that key should be the bundle identifier of the player app.
 */
static NSString *const notificationUserInfoPlayerBundleIdentifier = @"playerBundleIdentifier";


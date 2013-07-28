//
//  TNReviewRequest.m
//  Tunes Notifier
//
//  Created by Jules Coynel on 02/10/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

#import "TNReviewRequest.h"

/** NSUserDefault key to save the version of the app when last reviewed. */
static NSString *const lastVersionReviewed = @"lastVersionReviewed";
/** NSUserDefault key to save the user preference regarding review requests. */
static NSString *const neverAskForReview = @"neverAskForReview";
/** 
 NSUserDefault key to save the number of times Tunes Notifier has been launched
 since the last review request. 
 */
static NSString *const launchCountSinceLastReviewRequest = @"launchCountSinceLastReviewRequest";
/**
 NSUserDefault key to save the version number of Tunes Notifier version when
 the app was launched the last time. 
 */
static NSString *const versionWhenLastLaunched = @"versionWhenLastLaunched";

/** The number of times Tunes Notifier should be launched before asking for review. */
static NSInteger const launchCountSinceLastReviewRequestBeforeAskingForReview = 5;

/** Link to Tunes Notifier in the Mac App Store. */
static NSString *const macAppStoreLink = @"macappstore://itunes.apple.com/app/tunes-notifier/id555731861?ls=1&mt=12";

@interface TNReviewRequest ()
/** 
 Handle user response for a review request.
 
 @param alert The NSAlert with the review request.
 @param returnCode The button pressed.
 @param contextInfo Information passed when creating the NSAlert.
 */
- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
@end

@implementation TNReviewRequest

- (id)init
{
    self = [super init];
    
    if (self != nil) {
        NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        // If current version != to last version launched
        // Delete preferences and set current version to last launched
        if (![[userDefaults objectForKey:versionWhenLastLaunched] isEqualToString:currentVersion]) {
            [userDefaults setObject:currentVersion forKey:versionWhenLastLaunched];
            [userDefaults setInteger:0 forKey:launchCountSinceLastReviewRequest];
            [userDefaults setBool:NO forKey:neverAskForReview];
        } else if (![[userDefaults valueForKey:lastVersionReviewed] isEqualToString:currentVersion] && [userDefaults boolForKey:neverAskForReview] == NO) {
            NSInteger launchCount = [userDefaults integerForKey:launchCountSinceLastReviewRequest];
            launchCount++;
            [userDefaults setInteger:launchCount forKey:launchCountSinceLastReviewRequest];
        }
        
        [userDefaults synchronize];
    }
    
    return self;
}

- (BOOL)shouldAskForReview
{    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // NEVER ASK
    if ([userDefaults boolForKey:neverAskForReview]) {
        return NO;
    }
    
    // CHECK VERSION
    NSString* currentAppVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
	NSString* reviewedAppVersion = [userDefaults stringForKey:lastVersionReviewed];

    // don't ask for review if already reviewed the current version
    if ([currentAppVersion isEqualToString:reviewedAppVersion]) {
        return NO;
    }
    
    // CHECK LAUNCH COUNT
    NSInteger launchCount = [userDefaults integerForKey:launchCountSinceLastReviewRequest];
    
    if (launchCount < launchCountSinceLastReviewRequestBeforeAskingForReview) {
        return NO;
    }
        
    return YES;
}

- (void)askForReview
{
    NSAlert *reviewAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"REVIEW_REQUEST_ALERT_TITLE", nil)
                                           defaultButton:NSLocalizedString(@"REVIEW_REQUEST_RATE_BUTTON", nil)
                                         alternateButton:NSLocalizedString(@"REVIEW_REQUEST_DONT_ASK_BUTTON", nil)
                                             otherButton:NSLocalizedString(@"REVIEW_REQUEST_REMIND_LATER_BUTTON", nil)
                               informativeTextWithFormat:NSLocalizedString(@"REVIEW_REQUEST_MESSAGE", nil)];

    [reviewAlert beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow]
                            modalDelegate:self
                           didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                              contextInfo:nil];
    
    // Force alert to become the active window
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    switch (returnCode) {
        case NSAlertDefaultReturn: // rate
        {            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] forKey:lastVersionReviewed];
            [userDefaults removeObjectForKey:launchCountSinceLastReviewRequest];
            [userDefaults synchronize];
            
            // Open the Mac App Store
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:macAppStoreLink]];
            break;
        }
        case NSAlertAlternateReturn: // don't ask again
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:neverAskForReview];
            [userDefaults removeObjectForKey:lastVersionReviewed];
            [userDefaults removeObjectForKey:launchCountSinceLastReviewRequest];
            [userDefaults synchronize];
            break;
        }
        case NSAlertOtherReturn: // ask later
        {            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setInteger:0 forKey:launchCountSinceLastReviewRequest];
            [userDefaults synchronize];
            break;
        }
        default:
            break;
    }
}

@end

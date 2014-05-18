//
//  TNReviewRequest.h
//  Tunes Notifier
//
//  Created by Jules Coynel on 02/10/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

@import Foundation;

/**
 A class that monitors the usage of the application to allow the Application
 Delegate to know when the application should ask for user review.
 
 Saves the following information to NSUserDefaults
 
 - The last version of the application that has been reviewed
 - Whether the user has chosen never to be asked for review
 - The number of times the application has been launched
 - The version of the application when launched for the last time
 
 @warning This class is intended to be used in the implementation of
 `applicationDidFinishLaunching:` from `NSApplicationDelegate` protocol. It is
 not mandatory to call shouldAskForReview.
 
 @bug Should become a singleton to prevent multiple instances of this class,
 which would provide faulse statistics.
 */
@interface TNReviewRequest : NSObject

/** Default initialiser. */
- (id)init;

/**
 Returns whether the application should ask the user for review based on
 monitored application usage and class configuration.
 
 @return `YES` if the current usage of the application has reached the minimum
 conditions set to ask for review, `NO` otherwise.
 */
- (BOOL)shouldAskForReview;
/**
 Open an alert view asking the user to review the application.
 
 The alert view is opened regardless of the user preferences.
 
 It offers the following options
 
 - Ask later
 - Nerver ask for review again
 - Review now
 */
- (void)askForReview;
@end

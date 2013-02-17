//
//  TNReviewRequest.h
//  Tunes Notifier
//
//  Created by Jules Coynel on 02/10/2012.
//  Copyright (c) 2012 Jules Coynel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNReviewRequest : NSObject
- (BOOL)shouldAskForReview;
- (void)askForReview;
@end

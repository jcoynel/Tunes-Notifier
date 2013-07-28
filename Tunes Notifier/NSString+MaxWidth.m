//
//  NSString+MaxWidth.m
//  Tunes Notifier
//
//  Created by Jules Coynel on 28/07/2013.
//  Copyright (c) 2013 Jules Coynel. All rights reserved.
//

#import "NSString+MaxWidth.h"

@implementation NSString (MaxWidth)

- (NSString *)stringWithFont:(NSFont *)font maxWidth:(NSUInteger)maxWidth
{
    NSString *result = self;
    
    NSDictionary *stringAttributes = @{NSFontAttributeName: font};
    
    if ([result sizeWithAttributes:stringAttributes].width > maxWidth) {
        NSRange range = NSMakeRange([result length] - 3, 3);
        result = [result stringByReplacingCharactersInRange:range withString:@"..."];
        
        while ([result sizeWithAttributes:stringAttributes].width > maxWidth) {
            range = NSMakeRange([result length] - 4, 1);
            result = [result stringByReplacingCharactersInRange:range withString:@""];
        }
    }

    return result;
}

@end

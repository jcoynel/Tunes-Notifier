//
//  NSString+MaxWidth.h
//  Tunes Notifier
//
//  Created by Jules Coynel on 28/07/2013.
//  Copyright (c) 2013 Jules Coynel. All rights reserved.
//

@import Foundation;

@interface NSString (MaxWidth)

/**
 Truncate a string if its width for the given font is wider than the maximum
 width specified and add _..._ at the end.
 
 e.g. _A string_ could become _A str..._
 
 @param font Font of the string.
 @param maxWidth Maximum width allowed for the string.
 
 @return The truncated string with _..._ at the end or a copy of the original
 string.
 */
- (NSString *)stringWithFont:(NSFont *)font maxWidth:(NSUInteger)maxWidth;

@end

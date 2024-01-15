//
//  NSString+Trim.m
//  AlertsDemo
//
//  Created by Mo Bitar on 1/15/13.
//  Copyright (c) 2013 progenius, inc. All rights reserved.
//

#import "NSString+Trim.h"

@implementation NSString (Trim)

+ (NSString *)trimWhiteSpace:(NSString *)str
{
    return [str stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end

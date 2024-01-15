//
//  PostCount.m
//  CNApp
//
//  Created by Manpreet Singh on 7/7/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "PostCount.h"

@implementation PostCount

+ (PostCount *)countFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"comment": @"comments",
                              @"good": @"likes",
                              @"remember": @"remembers",
                              @"repost": @"reposts",
                              @"view": @"views"
                              };
    PostCount *count = [PostCount objectFromJSONObject:dict mapping:mapping];
    return count;
}

@end

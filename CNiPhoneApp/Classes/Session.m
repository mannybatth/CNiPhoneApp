//
//  Session.m
//  CNApp
//
//  Created by Manpreet Singh on 6/24/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "Session.h"

@implementation Session

static Session *shared = nil;
+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[Session alloc] init];
    });
    return shared;
}

+ (void)setUserToken:(NSString*)token
{
    [Session shared].currentToken = token;
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"currentToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

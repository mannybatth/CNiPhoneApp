//
//  UserCount.m
//  CNApp
//
//  Created by Manpreet Singh on 7/10/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "UserCount.h"

@implementation UserCount

+ (UserCount *)countFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"colleague": @"numOfColleagues",
                              @"conexus": @"numOfConexus",
                              @"content": @"numOfPosts",
                              @"course": @"numOfCourses",
                              @"follower": @"numOfFollowers",
                              @"following": @"numOfFollowing",
                              @"login": @"numOfLogins",
                              @"remind": @"numOfReminds",
                              @"new_colleague_request": @"newColleagueRequests",
                              @"new_email": @"newEmails",
                              @"new_notification": @"newNotifications"
                              };
    UserCount *count = [UserCount objectFromJSONObject:dict mapping:mapping];
    return count;
}

@end

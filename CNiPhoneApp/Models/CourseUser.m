//
//  CourseUser.m
//  CNApp
//
//  Created by Manpreet Singh on 7/15/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "CourseUser.h"

@implementation CourseUser

+ (CourseUser *)courseUserFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"user_position": @"userPosition",
                              @"user_type": @"userType"
                              };
    
    CourseUser *courseUser = [CourseUser objectFromJSONObject:dict mapping:mapping];
    courseUser.user = [User userFromJSON:[dict objectForKey:@"model"]];
    courseUser.userScore = [UserScore scoreFromJSON:[dict objectForKey:@"score"]];
    return courseUser;
}

+ (NSArray *)courseUsersFromJSONArray:(NSArray *)arr
{
    NSMutableArray *courseUsersMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        if ([[obj objectForKey:@"model"] count] > 0) {
            CourseUser *courseUser = [CourseUser courseUserFromJSON:obj];
            [courseUsersMapped addObject:courseUser];
        }
    }];
    
    return courseUsersMapped;
}

@end

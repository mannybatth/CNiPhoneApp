//
//  UserProfilePosition.m
//  CNApp
//
//  Created by Manpreet Singh on 7/11/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "UserProfilePosition.h"

@implementation UserProfilePosition

+ (UserProfilePosition *)positionFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"position": @"positionName",
                              @"school_name": @"positionSchoolName",
                              @"type": @"positionType",
                              @"web_address": @"positionWebAddress"
                              };
    UserProfilePosition *position = [UserProfilePosition objectFromJSONObject:dict mapping:mapping];
    position.positionName = [position.positionName capitalizedString];
    return position;
}

+ (NSArray *)positionsFromJSONArray:(NSArray *)arr
{
    NSMutableArray *positionsMapped = [NSMutableArray new];
    [arr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        UserProfilePosition *position = [UserProfilePosition positionFromJSON:dict];
        [positionsMapped addObject:position];
    }];
    return positionsMapped;
}

@end

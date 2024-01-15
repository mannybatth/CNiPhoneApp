//
//  UserProfileSchool.m
//  CNApp
//
//  Created by Manpreet Singh on 7/11/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "UserProfileSchool.h"

@implementation UserProfileSchool

+ (UserProfileSchool *)schoolFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"type": @"schoolType",
                              @"name": @"schoolName",
                              @"display_type": @"schoolDisplayType",
                              @"web_address": @"schoolWebAddress"
                              };
    UserProfileSchool *school = [UserProfileSchool objectFromJSONObject:dict mapping:mapping];
    return school;
}

+ (NSArray *)schoolsFromJSONArray:(id)arr
{
    if ([arr isKindOfClass:[NSDictionary class]]) {
        // convert dictionary to array
        arr = [arr allValues];
    }
    
    NSMutableArray *schoolsMapped = [NSMutableArray new];
    [arr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        UserProfileSchool *user = [UserProfileSchool schoolFromJSON:dict];
        [schoolsMapped addObject:user];
    }];
    return schoolsMapped;
}

@end

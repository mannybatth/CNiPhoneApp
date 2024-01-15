//
//  School.m
//  CNApp
//
//  Created by Manpreet Singh on 7/14/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "School.h"

@implementation School

+ (School *)schoolFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"id": @"schoolId",
                              @"name": @"schoolName",
                              @"url": @"schoolURL",
                              };
    School *school = [School objectFromJSONObject:dict mapping:mapping];
    return school;
}

+ (NSArray *)schoolsFromJSONArray:(NSArray *)arr
{
    NSMutableArray *schoolsMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        School *school = [School schoolFromJSON:obj];
        [schoolsMapped addObject:school];
    }];
    
    return schoolsMapped;
}

@end

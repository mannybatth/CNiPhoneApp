//
//  CourseCount.m
//  CNApp
//
//  Created by Manpreet Singh on 7/18/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "CourseCount.h"

@implementation CourseCount

+ (CourseCount *)courseCountFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"all": @"all",
                              @"instructor": @"instructor",
                              @"student": @"student"
                              };
    CourseCount *count = [CourseCount objectFromJSONObject:dict mapping:mapping];
    return count;
}

@end

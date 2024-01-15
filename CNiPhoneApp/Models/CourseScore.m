//
//  CourseScore.m
//  CNApp
//
//  Created by Manpreet Singh on 7/29/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "CourseScore.h"

@implementation CourseScore

+ (CourseScore *)courseScoreFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"average": @"averageScore",
                              @"average_student": @"averageStudentScore",
                              @"total": @"totalSeeds"
                              };
    CourseScore *score = [CourseScore objectFromJSONObject:dict mapping:mapping];
    return score;
}

@end

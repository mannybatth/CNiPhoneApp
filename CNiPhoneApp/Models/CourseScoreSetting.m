//
//  CourseScoreSetting.m
//  CNApp
//
//  Created by Manpreet Singh on 8/5/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "CourseScoreSetting.h"

@implementation CourseScoreSetting

+ (CourseScoreSetting *)courseScoreSettingFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"percentage": @"percentage",
                              @"required_number": @"requiredNumber",
                              @"use": @"use",
                              @"due_date": @"dueDateUnixStamp"
                              };
    CourseScoreSetting *courseScoreSetting = [CourseScoreSetting objectFromJSONObject:dict mapping:mapping];
    courseScoreSetting.dueDate = [NSDate dateWithTimeIntervalSince1970:courseScoreSetting.dueDateUnixStamp];
    return courseScoreSetting;
}

@end

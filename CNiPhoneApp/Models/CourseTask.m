//
//  CourseTask.m
//  CNApp
//
//  Created by Manpreet Singh on 7/12/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "CourseTask.h"

@implementation CourseTask

+ (CourseTask *)taskFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"id": @"taskId",
                              @"title": @"title",
                              @"description": @"description",
                              @"title_color": @"titleColor",
                              @"text": @"text",
                              @"status": @"status",
                              @"display_start_time": @"displayStartTime",
                              @"display_end_time": @"displayEndTime",
                              @"start_time": @"startTimeUnixStamp",
                              @"end_time": @"endTimeUnixStamp",
                              @"is_start": @"isStart",
                              @"is_end": @"isEnd",
                              };
    CourseTask *task = [CourseTask objectFromJSONObject:dict mapping:mapping];
    task.startTime = [NSDate dateWithTimeIntervalSince1970:task.startTimeUnixStamp];
    task.endTime = [NSDate dateWithTimeIntervalSince1970:task.endTimeUnixStamp];
    if (!task.title) task.title = @"";
    if (!task.text) task.text = @"";
    return task;
}

+ (NSArray *)tasksFromJSONArray:(NSArray *)arr
{
    NSMutableArray *tasksMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        CourseTask *task = [CourseTask taskFromJSON:obj];
        [tasksMapped addObject:task];
    }];
    
    return tasksMapped;
}

@end

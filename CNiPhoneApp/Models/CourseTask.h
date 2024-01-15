//
//  CourseTask.h
//  CNApp
//
//  Created by Manpreet Singh on 7/12/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface CourseTask : NSObject

@property (nonatomic, strong) NSString *taskId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *displayStartTime;
@property (nonatomic, strong) NSString *displayEndTime;
@property (nonatomic) double startTimeUnixStamp;
@property (nonatomic) double endTimeUnixStamp;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic) int titleColor;
@property (nonatomic) BOOL isStart;
@property (nonatomic) BOOL isEnd;

+ (CourseTask *)taskFromJSON:(NSDictionary *)dict;
+ (NSArray *)tasksFromJSONArray:(NSArray *)arr;

@end

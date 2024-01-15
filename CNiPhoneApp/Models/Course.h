//
//  Course.h
//  CNApp
//
//  Created by Manpreet Singh on 7/1/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"
#import "CourseTask.h"
#import "User.h"
#import "UserScore.h"
#import "School.h"
#import "CourseUser.h"
#import "CourseCount.h"
#import "CourseScore.h"
#import "CourseScoreSetting.h"

@interface Course : NSObject

@property (nonatomic, strong) NSString *courseId;
@property (nonatomic, strong) NSString *courseNumber;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) NSString *displayTime;
@property (nonatomic, strong) NSString *logoURL;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *userPosition;
@property (nonatomic, strong) UserScore *userScore;
@property (nonatomic, strong) CourseScore *courseScore;
@property (nonatomic, strong) CourseScoreSetting *courseScoreSetting;
@property (nonatomic, strong) School *school;

@property (nonatomic) BOOL isStart;
@property (nonatomic) BOOL isEnd;
@property (nonatomic) double startCourseDateUnixStamp;
@property (nonatomic) double endCourseDateUnixStamp;

@property (nonatomic, strong) NSArray *tasks;
@property (nonatomic, strong) NSArray *instructors;
@property (nonatomic, strong) NSArray *courseUsers;

@property (nonatomic, strong) NSArray *leastCourseScoreUsers;
@property (nonatomic, strong) NSArray *mostCourseScoreUsers;
@property (nonatomic, strong) NSArray *leastCourseScoreInstructors;
@property (nonatomic, strong) NSArray *mostCourseScoreInstructors;
@property (nonatomic, strong) NSArray *leastCourseScoreStudents;
@property (nonatomic, strong) NSArray *mostCourseScoreStudents;

@property (nonatomic, strong) CourseCount *count;

+ (Course *)courseFromJSON:(NSDictionary *)dict;
+ (NSArray *)coursesFromJSONArray:(NSArray *)arr;

@end

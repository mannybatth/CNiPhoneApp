//
//  Course.m
//  CNApp
//
//  Created by Manpreet Singh on 7/1/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "Course.h"
#import "Tools.h"

@implementation Course

+ (Course *)courseFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"id": @"courseId",
                              @"course_id": @"courseNumber",
                              @"name": @"name",
                              @"about": @"about",
                              @"display_time": @"displayTime",
                              @"logo_url": @"logoURL",
                              @"type": @"type",
                              @"user_position": @"userPosition",
                              @"is_start": @"isStart",
                              @"is_end": @"isEnd",
                              @"start_course_date": @"startCourseDateUnixStamp",
                              @"end_course_date": @"endCourseDateUnixStamp"
                              };
    Course *course = [Course objectFromJSONObject:dict mapping:mapping];
    course.about = [Tools replaceHtmlCharacters:course.about];
    course.tasks = [CourseTask tasksFromJSONArray:[dict objectForKey:@"tasks"]];
    course.instructors = [User usersFromJSONArray:[dict objectForKey:@"instructors"]];
    course.userScore = [UserScore scoreFromJSON:[dict objectForKey:@"user_score"]];
    course.school = [School schoolFromJSON:[dict objectForKey:@"school"]];
    course.leastCourseScoreUsers = [CourseUser courseUsersFromJSONArray:[dict objectForKey:@"least_course_score_users"]];
    course.mostCourseScoreUsers = [CourseUser courseUsersFromJSONArray:[dict objectForKey:@"most_course_score_users"]];
    course.leastCourseScoreInstructors = [CourseUser courseUsersFromJSONArray:[dict objectForKey:@"least_course_score_instructors"]];
    course.mostCourseScoreInstructors = [CourseUser courseUsersFromJSONArray:[dict objectForKey:@"most_course_score_instructors"]];
    course.leastCourseScoreStudents = [CourseUser courseUsersFromJSONArray:[dict objectForKey:@"least_course_score_students"]];
    course.mostCourseScoreStudents = [CourseUser courseUsersFromJSONArray:[dict objectForKey:@"most_course_score_students"]];
    course.count = [CourseCount courseCountFromJSON:[dict objectForKey:@"count"]];
    course.courseScore = [CourseScore courseScoreFromJSON:[dict objectForKey:@"score"]];
    if ([dict objectForKey:@"score_setting"])
        course.courseScoreSetting = [CourseScoreSetting courseScoreSettingFromJSON:[dict objectForKey:@"score_setting"]];
    return course;
}

+ (NSArray *)coursesFromJSONArray:(NSArray *)arr
{
    NSMutableArray *coursesMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        Course *course = [Course courseFromJSON:obj];
        [coursesMapped addObject:course];
    }];
    
    return coursesMapped;
}

@end

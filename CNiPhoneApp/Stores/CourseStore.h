//
//  CourseStore.h
//  CNApp
//
//  Created by Manpreet Singh on 7/2/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "BaseStore.h"
#import "Course.h"

@interface CourseStore : BaseStore

+ (void)getAllUserCourses:(void (^)(NSArray *courses, NSString *error))block;
+ (void)getAllUserCourses:(void (^)(NSArray *courses, NSString *error))block allowCache:(BOOL)allowCache;

+ (void)getCourseDetails:(NSString*)courseId block:(void (^)(Course *course, NSString *error))block;
+ (void)getCoursePosts:(NSString*)courseId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *, NSString *))block;
+ (void)getCourseRoster:(NSString*)courseId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *, NSString *))block;

+ (void)getCourseTaskDetails:(NSString*)taskId block:(void (^)(CourseTask *task, NSString *error))block;

+ (void)addUserToCourseByInvite:(NSString*)inviteEmailId courseId:(NSString*)courseId block:(void (^)(BOOL success, NSString *error))block;

@end

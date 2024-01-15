//
//  CourseStore.m
//  CNApp
//
//  Created by Manpreet Singh on 7/2/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "CourseStore.h"
#import "Post.h"

@implementation CourseStore

+ (void)getAllUserCourses:(void (^)(NSArray *, NSString *))block
{
    [CourseStore getAllUserCourses:block allowCache:YES];
}

+ (void)getAllUserCourses:(void (^)(NSArray *, NSString *))block allowCache:(BOOL)allowCache
{
    NSString *cacheKey = @"userCourses";
    
    NSArray *cachedArray = [[EGOCache globalCache] arrayForKey:cacheKey];
    
    if ((cachedArray || cachedArray.count != 0) && allowCache){
        NSArray *courses = [Course coursesFromJSONArray:cachedArray];
        block(courses, nil);
    }
    
    NSString *query = [NSString stringWithFormat:@"/user_course?limit=999"];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            if ([[response objectForKey:@"data"] isKindOfClass:[NSArray class]])
                [[EGOCache globalCache] setArray:[response objectForKey:@"data"] forKey:cacheKey withTimeoutInterval:DEFAULT_CACHE_INTERVAL];
            
            NSArray *courses = [Course coursesFromJSONArray:[response objectForKey:@"data"]];
            block(courses, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)getCourseDetails:(NSString *)courseId block:(void (^)(Course *, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/course/%@?with_course_detail=1&with_course_instructors=1&with_course_school=1&with_course_country=1&with_course_user_content_count=1&with_course_content_count=1&with_course_user_score=1&with_course_score=1&with_course_count=1&with_course_tasks=1&with_course_most_course_score_users=1&with_course_least_course_score_users=1&with_course_most_course_score_students=1&with_course_least_course_score_students=1&with_course_most_course_score_instructors=1&with_course_least_course_score_instructors=1&with_course_user_model=1", courseId];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            Course *course = [Course courseFromJSON:[response objectForKey:@"data"]];
            block(course, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)getCoursePosts:(NSString *)courseId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/course_content/?with_content_count=1&with_content_user=1&with_content_original_content=0&with_content_attachments=1&with_content_pictures=1&with_content_links=1&with_content_videos=1&with_content_comments=0&with_content_comment_user=0&with_content_courses=0&with_content_conexuses=0&with_user_country=1&with_content_courses=1&with_content_conexuses=1&with_user_profile=0&course_id=%@&course_content_list_order=most_new&with_content_comment_sub_comments=0&limit=%i&offset=%i", courseId, limit, offset];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            NSArray *coursePosts = [Post postsFromJSONArray:[response objectForKey:@"data"]];
            block(coursePosts, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)getCourseRoster:(NSString *)courseId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/course_user/?course_id=%@&with_user_country=1&with_user_profile=0&with_user_score=0&with_course_user_model=1&with_course_user_count=1&with_course_user_score=1&limit=%i&offset=%i", courseId, limit, offset];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            NSArray *users = [CourseUser courseUsersFromJSONArray:[response objectForKey:@"data"]];
            block(users, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)getCourseTaskDetails:(NSString *)taskId block:(void (^)(CourseTask *, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/task_details/%@/?with_content_comment_pictures=1&with_content_comment_attachments=1&with_content_current_user_is_observer=1", taskId];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            CourseTask *task = [CourseTask taskFromJSON:[response objectForKey:@"data"]];
            block(task, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)addUserToCourseByInvite:(NSString *)inviteEmailId courseId:(NSString *)courseId block:(void (^)(BOOL, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/course_user/%@", courseId];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            inviteEmailId, @"invite_email_id", nil];
    
    [BaseStore api:query header:nil parameters:params method:@"PUT" completionBlock:^(id response, NSString *err) {
        if (!err) {
            block(YES, err);
        } else {
            block(NO, err);
        }
    }];
}

@end

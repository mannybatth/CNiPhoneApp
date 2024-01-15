//
//  Notification.h
//  CNApp
//
//  Created by Manpreet Singh on 7/3/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

/*
 Notification types:            Extra Data:
 
 accept_colleague
 add_follow
 accept_conexus_invite,         conexus
 accept_course_invite,          course
 accept_join_course,            course
 add_content_comment,           post
 join_course,                   course
 join_conexus,                  conexus
 like_content,                  post
 mentioned,                     post
 others_add_content_comment,    post
 
 answer_survey,                 survey
 expired_remind,                event & conexus
 
 */

#import "User.h"
#import "Course.h"
#import "Conexus.h"
#import "Post.h"

@interface Notification : NSObject

@property (nonatomic, strong) NSString *notificationId;
@property (nonatomic, strong) NSString *displayTime;
@property (nonatomic, strong) NSString *mark;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSString *notificationDescription;

// Extra Data
@property (nonatomic, strong) NSMutableArray *extraData;
@property (nonatomic, strong) User *referencedUser;
@property (nonatomic, strong) Conexus *referencedConexus;
@property (nonatomic, strong) Course *referencedCourse;
@property (nonatomic, strong) Post *referencedPost;
@property (nonatomic, strong) Comment *referencedComment;

+ (Notification *)notificationFromJSON:(NSDictionary *)dict;
+ (NSArray *)notificationsFromJSONArray:(NSArray *)arr;

@end

//
//  EmailMessage.h
//  CNApp
//
//  Created by Manpreet Singh on 7/3/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "User.h"

@interface EmailMessage : NSObject

@property (nonatomic, strong) NSString *emailId;
@property (nonatomic, strong) User *sender;
@property (nonatomic, strong) NSString *displayTime;
@property (nonatomic, strong) NSString *emailRawText;
@property (nonatomic, strong) NSString *emailText;
@property (nonatomic, strong) NSString *parentEmailId;
@property (nonatomic, strong) NSArray *receivers;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *type;
@property (nonatomic) BOOL isReplyEmail;
@property (nonatomic) BOOL isSender;
@property (nonatomic) BOOL isUnread;

// Course Invite
@property (nonatomic, strong) NSString *inviteCourseId;
@property (nonatomic, strong) NSString *inviteCourseName;
@property (nonatomic, strong) NSString *inviteCourseNumber;
@property (nonatomic) BOOL isInviteAccepted;
@property (nonatomic) BOOL isInviteIgnored;

+ (EmailMessage *)emailFromJSON:(NSDictionary *)dict;
+ (NSArray *)emailsFromJSONArray:(NSArray *)arr;

@property (nonatomic) CGFloat messageContentHeight;

@end

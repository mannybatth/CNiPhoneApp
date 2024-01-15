//
//  EmailStore.h
//  CNiPhoneApp
//
//  Created by Manny on 4/3/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "BaseStore.h"
#import "EmailMessage.h"

@interface EmailStore : BaseStore

+ (void)getUserEmailsWithLimit:(int)limit offset:(int)offset block:(void (^)(NSArray *emails, NSString *error))block;

+ (void)setEmailRead:(EmailMessage*)message block:(void (^)(BOOL success, NSString *error))block;
+ (void)getEmailWithRepliesByParentId:(NSString*)emailId limit:(int)limit offset:(int)offset block:(void (^)(EmailMessage *parentMessage, NSArray *replies, NSString *error))block;

+ (void)createEmailToUsers:(NSArray*)toUsers ccUsers:(NSArray*)ccUsers text:(NSString*)text block:(void (^)(EmailMessage *message, NSString *error))block;
+ (void)createReplyToParentMessage:(EmailMessage*)parentMessage text:(NSString*)text block:(void (^)(EmailMessage *message, NSString *error))block;

+ (void)deleteEmail:(NSString*)emailId block:(void (^)(BOOL success, NSString *error))block;

@end

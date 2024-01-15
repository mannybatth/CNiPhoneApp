//
//  EmailStore.m
//  CNiPhoneApp
//
//  Created by Manny on 4/3/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "EmailStore.h"

@implementation EmailStore

+ (void)getUserEmailsWithLimit:(int)limit offset:(int)offset block:(void (^)(NSArray *emails, NSString *error))block
{
    NSString *query = [NSString stringWithFormat:@"/email/?with_email_extra_data=1&with_email_sender=1&with_email_sub_emails=0&email_list_order=most_new&email_list_category=all&limit=%i&offset=%i", limit, offset];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            NSArray *emails = [EmailMessage emailsFromJSONArray:[response objectForKey:@"data"]];
            block(emails, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)getEmailWithRepliesByParentId:(NSString*)emailId limit:(int)limit offset:(int)offset block:(void (^)(EmailMessage *parentMessage, NSArray *replies, NSString *error))block
{
    NSString *query = [NSString stringWithFormat:@"/email/%@?with_email_sender=1&with_email_sub_emails=1&with_email_attachments=1&with_email_videos=1&email_list_order=most_new&limit=%i&offset=%i", emailId, limit, offset];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            EmailMessage *parentMessage = [EmailMessage emailFromJSON:[response objectForKey:@"data"]];
            NSArray *replies = [EmailMessage emailsFromJSONArray:[[response objectForKey:@"data"] objectForKey:@"sub_emails"]];
            block(parentMessage, replies, err);
        } else {
            block(nil, nil, err);
        }
    }];
}

+ (void)setEmailRead:(EmailMessage*)message block:(void (^)(BOOL, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/email/%@", message.emailId];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"read", @"status", nil];
    
    [BaseStore api:query header:nil parameters:params method:@"PUT" completionBlock:^(id response, NSString *err) {
        if (!err) {
            block(YES, err);
        } else {
            block(NO, err);
        }
    }];
}

+ (void)createEmailToUsers:(NSArray*)toUsers ccUsers:(NSArray*)ccUsers text:(NSString*)text block:(void (^)(EmailMessage *message, NSString *error))block
{
    NSString *query = @"/email/";
    
    NSMutableArray *receiversInfo = [NSMutableArray arrayWithCapacity:toUsers.count+ccUsers.count];
    [toUsers enumerateObjectsUsingBlock:^(User *user, NSUInteger idx, BOOL *stop) {
        NSDictionary *userInfo = @{
                                   @"id": user.userId,
                                   @"type": @"user"
                                   };
        [receiversInfo addObject:userInfo];
    }];
    [ccUsers enumerateObjectsUsingBlock:^(User *user, NSUInteger idx, BOOL *stop) {
        NSDictionary *userInfo = @{
                                   @"id": user.userId,
                                   @"receive_type": @"cc",
                                   @"type": @"user"
                                   };
        [receiversInfo addObject:userInfo];
    }];
    
    NSDictionary *senderInfo = @{
                                 @"id": [Session shared].currentUser.userId,
                                 @"type": @"user"
                                 };
    
    NSDictionary *params = @{
                             @"content": text,
                             @"receivers": receiversInfo,
                             @"sender": senderInfo,
                             @"type": @"normal",
                             };
    
    [BaseStore api:query parameters:params completionBlock:^(id response, NSString *err) {
        if (!err) {
            EmailMessage *message = [EmailMessage emailFromJSON:[response objectForKey:@"data"]];
            block(message, nil);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)createReplyToParentMessage:(EmailMessage*)parentMessage text:(NSString*)text block:(void (^)(EmailMessage *message, NSString *error))block
{
    NSString *query = @"/email/?return_detail=1&with_email_sender=1";
    
    NSMutableArray *receiversInfo = [NSMutableArray arrayWithCapacity:parentMessage.receivers.count];
    [parentMessage.receivers enumerateObjectsUsingBlock:^(User *user, NSUInteger idx, BOOL *stop) {
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  user.userId, @"id",
                                  @"user", @"type",
                                  nil];
        [receiversInfo addObject:userInfo];
        
    }];
    
    NSDictionary *senderInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                [Session shared].currentUser.userId, @"id",
                                @"user", @"type",
                                nil];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            parentMessage.emailId, @"parent_id",
                            text, @"content",
                            receiversInfo, @"receivers",
                            senderInfo, @"sender",
                            @"normal", @"type",
                            nil];
    
    [BaseStore api:query parameters:params completionBlock:^(id response, NSString *err) {
        if (!err) {
            EmailMessage *message = [EmailMessage emailFromJSON:[response objectForKey:@"data"]];
            block(message, nil);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)deleteEmail:(NSString *)emailId block:(void (^)(BOOL, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/email/%@", emailId];
    
    [BaseStore api:query header:nil parameters:nil method:@"DELETE" completionBlock:^(id response, NSString *err) {
        if (!err) {
            block(YES, err);
        } else {
            block(NO, err);
        }
    }];
}

@end

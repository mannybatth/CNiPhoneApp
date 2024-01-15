//
//  EmailMessage.m
//  CNApp
//
//  Created by Manpreet Singh on 7/3/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "EmailMessage.h"
#import "Tools.h"

@implementation EmailMessage

+ (EmailMessage *)emailFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"id": @"emailId",
                              @"display_time": @"displayTime",
                              @"content": @"emailRawText",
                              @"parent_email_id": @"parentEmailId",
                              @"subject": @"subject",
                              @"type": @"type",
                              @"is_reply_email": @"isReplyEmail",
                              @"is_sender": @"isSender",
                              @"is_unread": @"isUnread"
                              };
    EmailMessage *message = [EmailMessage objectFromJSONObject:dict mapping:mapping];
    message.sender = [User userFromJSON:[dict objectForKey:@"sender"]];
    message.receivers = [User usersFromJSONArray:[dict objectForKey:@"receivers"]];
    message.emailRawText = [NSString trimWhiteSpace:message.emailRawText];
    message.emailRawText = [Tools replaceHtmlCharacters:message.emailRawText];
    message.emailRawText = [Tools removeBreaks:message.emailRawText];
    message.emailText = [Tools stripTags:message.emailRawText];
    
    if ([[dict objectForKey:@"extra_data"] count] > 0) {
        message.inviteCourseId = [[[dict objectForKey:@"extra_data"] objectAtIndex:0] objectForKey:@"value"];
        message.inviteCourseName = [[[dict objectForKey:@"extra_data"] objectAtIndex:0] objectForKey:@"course_name"];
        message.inviteCourseNumber = [[[dict objectForKey:@"extra_data"] objectAtIndex:0] objectForKey:@"course_number"];
    }
    
    return message;
}

+ (NSArray *)emailsFromJSONArray:(NSArray *)arr
{
    NSMutableArray *commentsMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        EmailMessage *message = [EmailMessage emailFromJSON:obj];
        [commentsMapped addObject:message];
    }];
    
    return commentsMapped;
}

@end

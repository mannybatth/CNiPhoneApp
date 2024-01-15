//
//  NotificationStore.m
//  CNiPhoneApp
//
//  Created by Manny on 4/3/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "NotificationStore.h"

@implementation NotificationStore

+ (void)getUserNotificationsWithLimit:(int)limit offset:(int)offset block:(void (^)(NSArray *notifications, NSString *error))block
{
    NSString *query = [NSString stringWithFormat:@"/user_notification/?with_user_notification_extra_data=1&without_user_notification_users=0&limit=%i&offset=%i",limit, offset];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            NSArray *notifications = [Notification notificationsFromJSONArray:[response objectForKey:@"data"]];
            block(notifications, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)setNotificationReadById:(NSString *)notificationId block:(void (^)(BOOL, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/user_notification/%@", notificationId];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"read", @"mark", nil];
    
    [BaseStore api:query header:nil parameters:params method:@"PUT" completionBlock:^(id response, NSString *err) {
        if (!err) {
            block(YES, err);
        } else {
            block(NO, err);
        }
    }];
}

@end

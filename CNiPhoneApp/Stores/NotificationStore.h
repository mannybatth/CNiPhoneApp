//
//  NotificationStore.h
//  CNiPhoneApp
//
//  Created by Manny on 4/3/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "BaseStore.h"
#import "Notification.h"

@interface NotificationStore : BaseStore

+ (void)getUserNotificationsWithLimit:(int)limit offset:(int)offset block:(void (^)(NSArray *notifications, NSString *error))block;

+ (void)setNotificationReadById:(NSString*)notificationId block:(void (^)(BOOL success, NSString *error))block;

@end

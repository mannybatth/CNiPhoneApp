//
//  Notification.m
//  CNApp
//
//  Created by Manpreet Singh on 7/3/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "Notification.h"

@implementation Notification

+ (id)lookForObjectInArray:(NSArray*)arr class:(Class)class
{
    NSUInteger index = [arr indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        return [obj isKindOfClass:class];
    }];
    if (index != NSNotFound) return [arr objectAtIndex:index];
    return nil;
}

+ (Notification *)notificationFromJSON:(NSDictionary *)dict
{
    NSArray *acceptedNotifications = [NSArray arrayWithObjects:
                                      @"accept_colleague",
                                      @"accept_conexus_invite",
                                      @"accept_course_invite",
                                      @"accept_join_conexus",
                                      @"accept_join_course",
                                      @"add_attachment_comment", // todo
                                      @"add_content_comment",
                                      @"add_follow",
                                      @"after_register", // todo
                                      @"answer_survey",
                                      @"expired_remind",
                                      @"grade_quiz", // todo
                                      @"inform_instructor_handle_join_course", // todo
                                      @"join_conexus",
                                      @"join_course",
                                      @"like_attachment", // todo
                                      @"like_content",
                                      @"mentioned",
                                      @"others_add_content_comment",
                                      @"others_like_content",
                                      @"publish_quiz", // todo
                                      @"submit_quiz", // todo
                                      @"system_message",
                                      nil];
    
    NSDictionary *mapping = @{
                              @"id": @"notificationId",
                              @"display_time": @"displayTime",
                              @"mark": @"mark",
                              @"type": @"type"
                              };
    
    NSString *type = [dict objectForKey:@"type"];
    if (![acceptedNotifications containsObject:type]) {
        return nil;
    }
    
    Notification *notification = [Notification objectFromJSONObject:dict mapping:mapping];
    notification.users = [User usersFromJSONArray:[dict objectForKey:@"users"]];
    
    if (!(notification.users.count > 0)) {
        return nil;
    }
    
    notification.extraData = [[NSMutableArray alloc] init];
    
    __block NSString *modelDisplayType;
    NSArray *extraDataArr = [dict objectForKey:@"extra_data"];
    [extraDataArr enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
        if ([[data objectForKey:@"data_type"] isEqualToString:@"model"]) {
            
            NSString *modelName = [data objectForKey:@"data_model_name"];
            
            if ([modelName isEqualToString:@"post"]) {
                [notification.extraData addObject:[Post postFromJSON:[data objectForKey:@"value"]]];
                modelDisplayType = @"post";
                
            } else if ([modelName isEqualToString:@"sharelink"]) {
                [notification.extraData addObject:[Post postFromJSON:[data objectForKey:@"value"]]];
                modelDisplayType = @"sharelink";
                
            } else if ([modelName isEqualToString:@"survey"]) {
                [notification.extraData addObject:[Post postFromJSON:[data objectForKey:@"value"]]];
                modelDisplayType = @"poll";
                
            } else if ([modelName isEqualToString:@"content_comment"]) {
                [notification.extraData addObject:[Comment commentFromJSON:[data objectForKey:@"value"]]];
                
            } else if ([modelName isEqualToString:@"conexus"]) {
                [notification.extraData addObject:[Conexus conexusFromJSON:[data objectForKey:@"value"]]];
                modelDisplayType = @"conexus";
                
            } else if ([modelName isEqualToString:@"course"]) {
                [notification.extraData addObject:[Course courseFromJSON:[data objectForKey:@"value"]]];
                modelDisplayType = @"course";
                
            } else if ([modelName isEqualToString:@"event"]) {
                [notification.extraData addObject:[Post postFromJSON:[data objectForKey:@"value"]]];
                modelDisplayType = @"event";
            }
            
        } else if ([[data objectForKey:@"data_type"] isEqualToString:@"text"]) {
            [notification.extraData addObject:[NSString stringWithString:[data objectForKey:@"value"]]];
        }
    }];
    
    notification.referencedUser = (User*)[notification.users objectAtIndex:0];
    
    if ([type isEqualToString:@"accept_colleague"]) {
        
        notification.notificationDescription = [NSString stringWithFormat:@"%@ accepted your colleague request.", notification.referencedUser.displayName];
        
    } else if ([type isEqualToString:@"accept_conexus_invite"]) {
        
        notification.referencedConexus = [Notification lookForObjectInArray:notification.extraData class:[Conexus class]];
        notification.notificationDescription = [NSString stringWithFormat:@"%@ accepts your invitation to join the Conexus %@.", notification.referencedUser.displayName, notification.referencedConexus.name];
        
    } else if ([type isEqualToString:@"accept_course_invite"]) {
        
        notification.referencedCourse = [Notification lookForObjectInArray:notification.extraData class:[Course class]];
        notification.notificationDescription = [NSString stringWithFormat:@"%@ accepts your invitation to join the Course %@.", notification.referencedUser.displayName, notification.referencedCourse.name];
        
    } else if ([type isEqualToString:@"accept_join_conexus"]) {
        
        notification.referencedConexus = [Notification lookForObjectInArray:notification.extraData class:[Conexus class]];
        notification.notificationDescription = [NSString stringWithFormat:@"%@ accepts your request to join the Conexus %@.", notification.referencedUser.displayName, notification.referencedConexus.name];
        
    } else if ([type isEqualToString:@"accept_join_course"]) {
        
        notification.referencedCourse = [Notification lookForObjectInArray:notification.extraData class:[Course class]];
        notification.notificationDescription = [NSString stringWithFormat:@"%@ accepts your request to join the Course %@.", notification.referencedUser.displayName, notification.referencedCourse.name];
        
    } else if ([type isEqualToString:@"add_content_comment"]) {
        
        notification.referencedPost = [Notification lookForObjectInArray:notification.extraData class:[Post class]];
        notification.referencedPost.user = notification.referencedUser;
        
        if (notification.referencedPost.postId) {
            notification.notificationDescription = [NSString stringWithFormat:@"%@ reflected on your %@.", notification.referencedUser.displayName, modelDisplayType];
        } else {
            notification.notificationDescription = [NSString stringWithFormat:@"%@ reflected on your %@, but this %@ has been deleted.", notification.referencedUser.displayName, modelDisplayType, modelDisplayType];
        }
        
    } else if ([type isEqualToString:@"add_follow"]) {
        
        notification.notificationDescription = [NSString stringWithFormat:@"%@ is now following you.", notification.referencedUser.displayName];
        
    } else if ([type isEqualToString:@"join_conexus"]) {
        
        notification.referencedConexus = [Notification lookForObjectInArray:notification.extraData class:[Conexus class]];
        notification.notificationDescription = [NSString stringWithFormat:@"%@ joined your Conexus %@.", notification.referencedUser.displayName, notification.referencedConexus.name];
        
    } else if ([type isEqualToString:@"join_course"]) {
        
        notification.referencedCourse = [Notification lookForObjectInArray:notification.extraData class:[Course class]];
        notification.notificationDescription = [NSString stringWithFormat:@"%@ joined your Course %@.", notification.referencedUser.displayName, notification.referencedCourse.name];
        
    } else if ([type isEqualToString:@"like_content"]) {
        
        notification.referencedPost = [Notification lookForObjectInArray:notification.extraData class:[Post class]];
        notification.referencedPost.user = notification.referencedUser;
        
        if (notification.referencedPost.postId) {
            notification.notificationDescription = [NSString stringWithFormat:@"%@ liked your %@.", notification.referencedUser.displayName, modelDisplayType];
        } else {
            notification.notificationDescription = [NSString stringWithFormat:@"%@ liked your %@, but this %@ has been deleted.", notification.referencedUser.displayName, modelDisplayType, modelDisplayType];
        }
        
    } else if ([type isEqualToString:@"mentioned"]) {
        
        notification.referencedPost = [Notification lookForObjectInArray:notification.extraData class:[Post class]];
        notification.referencedPost.user = notification.referencedUser;
        
        if (notification.referencedPost.postId) {
            notification.notificationDescription = [NSString stringWithFormat:@"%@ mentioned you in a %@.", notification.referencedUser.displayName, modelDisplayType];
        } else {
            notification.notificationDescription = [NSString stringWithFormat:@"%@ mentioned you in a %@, but this %@ has been deleted.", notification.referencedUser.displayName, modelDisplayType, modelDisplayType];
        }
        
    } else if ([type isEqualToString:@"others_add_content_comment"]) {
        
        notification.referencedPost = [Notification lookForObjectInArray:notification.extraData class:[Post class]];
        notification.referencedPost.user = notification.referencedUser;
        
        if (notification.referencedPost.postId) {
            notification.notificationDescription = [NSString stringWithFormat:@"%@ reflected on a %@ you also reflected on.", notification.referencedUser.displayName, modelDisplayType];
        } else {
            notification.notificationDescription = [NSString stringWithFormat:@"%@ reflected on a %@ you also reflected on, but this %@ has been deleted.", notification.referencedUser.displayName, modelDisplayType, modelDisplayType];
        }
        
    } else if ([type isEqualToString:@"expired_remind"]) {
        
        notification.referencedConexus = [Notification lookForObjectInArray:notification.extraData class:[Conexus class]];
        notification.referencedCourse = [Notification lookForObjectInArray:notification.extraData class:[Course class]];
        notification.referencedPost = [Notification lookForObjectInArray:notification.extraData class:[Post class]];
        
        NSString *displayName = @"";
        if (notification.referencedCourse.courseId) {
            displayName = notification.referencedCourse.name;
        } else if (notification.referencedConexus.conexusId) {
            displayName = notification.referencedConexus.name;
        }
        
        if (notification.referencedPost.postId) {
            notification.notificationDescription = [NSString stringWithFormat:@"The event %@ created in %@ is approaching.", notification.referencedUser.displayName, displayName];
        } else {
            notification.notificationDescription = [NSString stringWithFormat:@"The event %@ created in %@ is approaching, but this event has been deleted.", notification.referencedUser.displayName, displayName];
        }
        
    } else if ([type isEqualToString:@"system_message"]) {
        
        NSString *text = [Notification lookForObjectInArray:notification.extraData class:[NSString class]];
        if (text != nil && ![text isEqualToString:@""]) {
            notification.notificationDescription = [NSString stringWithFormat:@"%@ %@", notification.referencedUser.displayName, text];
        } else {
            notification.notificationDescription = [NSString stringWithFormat:@"%@ sent you a system message, but this message has been deleted.", notification.referencedUser.displayName];
        }
        
    } else if ([type isEqualToString:@"answer_survey"]) {
        
        notification.referencedPost = [Notification lookForObjectInArray:notification.extraData class:[Post class]];
        notification.referencedPost.user = notification.referencedUser;
        if (notification.referencedPost.postId) {
            notification.notificationDescription = [NSString stringWithFormat:@"%@ answered your %@.", notification.referencedUser.displayName, modelDisplayType];
        } else {
            notification.notificationDescription = [NSString stringWithFormat:@"%@ answered your %@, but this %@ has been deleted.", notification.referencedUser.displayName, modelDisplayType, modelDisplayType];
        }
        
    } else if ([type isEqualToString:@"others_like_content"]) {
        
        notification.referencedPost = [Notification lookForObjectInArray:notification.extraData class:[Post class]];
        notification.referencedPost.user = notification.referencedUser;
        if (notification.referencedPost.postId) {
            notification.notificationDescription = [NSString stringWithFormat:@"%@ liked a %@ you reflected on.", notification.referencedUser.displayName, modelDisplayType];
        } else {
            notification.notificationDescription = [NSString stringWithFormat:@"%@ liked a %@ you reflected on, but this %@ has been deleted.", notification.referencedUser.displayName, modelDisplayType, modelDisplayType];
        }
    
    } else {
        
        notification.notificationDescription = @"This notification is not supported.";
        
    }
    
    return notification;
}

+ (NSArray *)notificationsFromJSONArray:(NSArray *)arr
{
    NSMutableArray *notificationsMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        Notification *notification = [Notification notificationFromJSON:obj];
        if (notification) [notificationsMapped addObject:notification];
    }];
    
    return notificationsMapped;
}

@end

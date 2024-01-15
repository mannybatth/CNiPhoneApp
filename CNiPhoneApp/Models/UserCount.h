//
//  UserCount.h
//  CNApp
//
//  Created by Manpreet Singh on 7/10/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface UserCount : NSObject

@property (nonatomic) int numOfColleagues;
@property (nonatomic) int numOfConexus;
@property (nonatomic) int numOfPosts;
@property (nonatomic) int numOfCourses;
@property (nonatomic) int numOfFollowers;
@property (nonatomic) int numOfFollowing;
@property (nonatomic) int numOfLogins;
@property (nonatomic) int numOfReminds;
@property (nonatomic) int newColleagueRequests;
@property (nonatomic) int newEmails;
@property (nonatomic) int newNotifications;

+ (UserCount *)countFromJSON:(NSDictionary *)dict;

@end

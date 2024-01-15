//
//  User.h
//  CNApp
//
//  Created by Manpreet Singh on 6/24/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"
#import "UserRelations.h"
#import "UserCount.h"
#import "UserScore.h"
#import "UserProfile.h"

@interface User : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *CNNumber;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *avatarId;
@property (nonatomic, strong) NSString *flagURL;
@property (nonatomic, strong) NSArray *courses;
@property (nonatomic, strong) NSArray *conexuses;
@property (nonatomic, strong) UserCount *userCount;
@property (nonatomic, strong) UserRelations *relations;
@property (nonatomic, strong) UserScore *score;
@property (nonatomic, strong) UserProfile *profile;
@property (nonatomic, strong) NSString *receiveType;

+ (User*)userFromJSON:(NSDictionary *)dict;
+ (NSArray*)usersFromJSONArray:(NSArray *)arr;

@end

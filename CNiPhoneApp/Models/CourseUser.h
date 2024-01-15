//
//  CourseUser.h
//  CNApp
//
//  Created by Manpreet Singh on 7/15/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"
#import "User.h"

@interface CourseUser : NSObject

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *userPosition;
@property (nonatomic, strong) NSString *userType;
@property (nonatomic, strong) UserScore *userScore;

+ (CourseUser *)courseUserFromJSON:(NSDictionary *)dict;
+ (NSArray *)courseUsersFromJSONArray:(NSArray *)arr;

@end

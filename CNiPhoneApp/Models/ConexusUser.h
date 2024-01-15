//
//  ConexusUser.h
//  CNApp
//
//  Created by Manpreet Singh on 8/29/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"
#import "User.h"

@interface ConexusUser : NSObject

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *userPosition;
@property (nonatomic, strong) NSString *userType;
@property (nonatomic, strong) UserScore *userScore;

+ (ConexusUser *)conexusUserFromJSON:(NSDictionary *)dict;
+ (NSArray *)conexusUsersFromJSONArray:(NSArray *)arr;

@end

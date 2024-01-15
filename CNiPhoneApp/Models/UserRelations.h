//
//  UserRelations.h
//  CNApp
//
//  Created by Manpreet Singh on 7/10/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface UserRelations : NSObject

@property (nonatomic) BOOL isMyFollowerUser;
@property (nonatomic) BOOL isMyFollowingUser;
@property (nonatomic) BOOL isMyColleagueUser;
@property (nonatomic) BOOL isMyPassiveColleagueUser;
@property (nonatomic) BOOL isMyPendingColleagueUser;
@property (nonatomic) BOOL isMyself;

+ (UserRelations *)relationsFromJSON:(NSDictionary *)dict;

@end

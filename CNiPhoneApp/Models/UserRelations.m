//
//  UserRelations.m
//  CNApp
//
//  Created by Manpreet Singh on 7/10/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "UserRelations.h"

@implementation UserRelations

+ (UserRelations *)relationsFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"is_my_follower_user": @"isMyFollowerUser",
                              @"is_my_following_user": @"isMyFollowingUser",
                              @"is_my_colleague_user": @"isMyColleagueUser",
                              @"is_my_passive_colleague_user": @"isMyPassiveColleagueUser",
                              @"is_my_pending_colleague_user": @"isMyPendingColleagueUser",
                              @"is_myself": @"isMyself"
                              };
    UserRelations *relations = [UserRelations objectFromJSONObject:dict mapping:mapping];
    return relations;
}

@end

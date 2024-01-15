//
//  User.m
//  CNApp
//
//  Created by Manpreet Singh on 6/24/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "User.h"
#import "Course.h"
#import "Conexus.h"

@implementation User

+ (User*)userFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"id": @"userId",
                              @"cn_number": @"CNNumber",
                              @"first_name": @"firstName",
                              @"last_name": @"lastName",
                              @"fullname": @"fullName",
                              @"display_name": @"displayName",
                              @"receive_type": @"receiveType"
                              };
    if ([dict objectForKey:@"model"]) dict = [dict objectForKey:@"model"];
    
    User *user = [User objectFromJSONObject:dict mapping:mapping];
    user.avatar = [[dict objectForKey:@"avatar"] objectForKey:@"view_url"];
    user.avatarId = [[dict objectForKey:@"avatar"] objectForKey:@"id"];
    user.flagURL = [[dict objectForKey:@"country"] objectForKey:@"flag_url"];
    user.firstName = [user.firstName capitalizedString];
    user.lastName = [user.lastName capitalizedString];
    user.courses = [Course coursesFromJSONArray:[dict objectForKey:@"courses"]];
    user.conexuses = [Conexus conexusesFromJSONArray:[dict objectForKey:@"conexuses"]];
    user.userCount = [UserCount countFromJSON:[dict objectForKey:@"count"]];
    user.relations = [UserRelations relationsFromJSON:[dict objectForKey:@"relations"]];
    user.score = [UserScore scoreFromJSON:[dict objectForKey:@"score"]];
    user.profile = [UserProfile profileFromJSON:[dict objectForKey:@"profile"]];
    return user;
}

+ (NSArray*)usersFromJSONArray:(NSArray *)arr
{
    NSMutableArray *usersMapped = [NSMutableArray new];
    [arr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        if ([dict objectForKey:@"model"]) dict = [dict objectForKey:@"model"];
        
        User *user = [User userFromJSON:dict];
        [usersMapped addObject:user];
    }];
    return usersMapped;
}

@end

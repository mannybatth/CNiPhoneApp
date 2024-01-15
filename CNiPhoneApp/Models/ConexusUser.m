//
//  ConexusUser.m
//  CNApp
//
//  Created by Manpreet Singh on 8/29/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "ConexusUser.h"

@implementation ConexusUser

+ (ConexusUser *)conexusUserFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"user_position": @"userPosition"
                              };
    
    ConexusUser *conexusUser = [ConexusUser objectFromJSONObject:dict mapping:mapping];
    conexusUser.user = [User userFromJSON:[dict objectForKey:@"model"]];
    conexusUser.userScore = [UserScore scoreFromJSON:[dict objectForKey:@"score"]];
    return conexusUser;
}

+ (NSArray *)conexusUsersFromJSONArray:(NSArray *)arr
{
    NSMutableArray *conexusUsersMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        ConexusUser *conexusUser = [ConexusUser conexusUserFromJSON:obj];
        [conexusUsersMapped addObject:conexusUser];
    }];
    
    return conexusUsersMapped;
}

@end

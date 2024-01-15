//
//  UserStore.m
//  CNApp
//
//  Created by Manpreet Singh on 6/26/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "UserStore.h"
#import "Course.h"
#import "Conexus.h"

@implementation UserStore

+ (void)getUserById:(NSString*)userId full:(BOOL)full block:(void (^)(User *, NSString *))block
{
    NSString *query;
    if (full) {
        query = [NSString stringWithFormat:@"/user/%@?with_user_relations=1&with_user_score=1&with_user_count=1&with_user_profile=1&with_user_country=1", userId];
    } else {
        query = [NSString stringWithFormat:@"/user/%@?with_user_country=1", userId];
    }
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            User *user = [User userFromJSON:[response objectForKey:@"data"]];
            block(user, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)getUserByCNNumber:(NSString*)cnNumber full:(BOOL)full block:(void (^)(User *, NSString *))block
{
    NSString *query;
    if (full) {
        query = [NSString stringWithFormat:@"/cn_number/%@?with_user_relations=1&with_user_score=1&with_user_count=1&with_user_profile=1&with_user_country=1", cnNumber];
    } else {
        query = [NSString stringWithFormat:@"/user/%@?with_user_country=1", cnNumber];
    }
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            User *user = [User userFromJSON:[response objectForKey:@"data"]];
            block(user, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)getMe:(void (^)(User *, NSString *))block
{
    /*NSString *cacheKey = @"getMe";
    
    NSDictionary *cachedArray = (NSDictionary*)[[EGOCache globalCache] objectForKey:cacheKey];
    
    if (cachedArray || cachedArray.count != 0){
        User *user = [User userFromJSON:cachedArray];
        block(user, nil);
    }*/
    
    NSString *query = [NSString stringWithFormat:@"/me?&with_user_count=1"];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            /*if ([[response objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
                [[EGOCache globalCache] setObject:[response objectForKey:@"data"] forKey:cacheKey withTimeoutInterval:DEFAULT_CACHE_INTERVAL];*/
            
            User *user = [User userFromJSON:[response objectForKey:@"data"]];
            block(user, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)getUserCourseConexusTab:(void (^)(NSArray *, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/user_course_conexus_tab?limit=999"];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            
            NSMutableArray *contentMapped = [NSMutableArray new];
            [[response objectForKey:@"data"] enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
                
                if ([[dict objectForKey:@"type"] isEqualToString:@"course"]) {
                    
                    Course *course = [Course courseFromJSON:[dict objectForKey:@"model"]];
                    [contentMapped addObject:course];
                    
                } else if ([[dict objectForKey:@"type"] isEqualToString:@"conexus"]) {
                    
                    Conexus *conexus = [Conexus conexusFromJSON:[dict objectForKey:@"model"]];
                    [contentMapped addObject:conexus];
                }
            }];
            block(contentMapped, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)getUserFollowing:(NSString *)userId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/user_following/?with_user_country=1&user_id=%@&limit=%i&offset=%i", userId, limit, offset];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            NSArray *users = [User usersFromJSONArray:[response objectForKey:@"data"]];
            block(users, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)followUser:(NSString*)userId block:(void (^)(BOOL, NSString *))block
{
    NSString *query = @"/user_following";
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userId, @"follow_user_id",
                            nil];
    
    [BaseStore api:query parameters:params completionBlock:^(id response, NSString *err) {
        if (!err) {
            block(YES, nil);
        } else {
            block(NO, err);
        }
    }];
}

+ (void)unFollowUser:(NSString*)userId block:(void (^)(BOOL, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/user_following/%@", userId];
    
    [BaseStore api:query header:nil parameters:nil method:@"DELETE" completionBlock:^(id response, NSString *err) {
        if (!err) {
            block(YES, nil);
        } else {
            block(NO, err);
        }
    }];
}

+ (void)getUserFollowers:(NSString *)userId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/user_follower/?with_user_country=1&user_id=%@&limit=%i&offset=%i", userId, limit, offset];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            NSArray *users = [User usersFromJSONArray:[response objectForKey:@"data"]];
            block(users, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)getUserColleagues:(NSString *)userId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/user_colleague/?with_user_country=1&user_id=%@&limit=%i&offset=%i", userId, limit, offset];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            NSArray *users = [User usersFromJSONArray:[response objectForKey:@"data"]];
            block(users, err);
        } else {
            block(nil, err);
        }
    }];
}


@end

//
//  ConexusStore.m
//  CNApp
//
//  Created by Manpreet Singh on 7/2/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "ConexusStore.h"
#import "Post.h"

@implementation ConexusStore

+ (void)getAllUserConexus:(void (^)(NSArray *conexus, NSString *error))block
{
    [ConexusStore getAllUserConexus:block allowCache:YES];
}

+ (void)getAllUserConexus:(void (^)(NSArray *conexus, NSString *error))block allowCache:(BOOL)allowCache
{
    NSString *cacheKey = @"userConexus";
    
    NSArray *cachedArray = [[EGOCache globalCache] arrayForKey:cacheKey];
    
    if ((cachedArray || cachedArray.count != 0) && allowCache){
        NSArray *conexus = [Conexus conexusesFromJSONArray:cachedArray];
        block(conexus, nil);
    }
    
    NSString *query = [NSString stringWithFormat:@"/user_conexus?with_conexus_country=1&limit=999"];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            if ([[response objectForKey:@"data"] isKindOfClass:[NSArray class]])
                [[EGOCache globalCache] setArray:[response objectForKey:@"data"] forKey:cacheKey withTimeoutInterval:DEFAULT_CACHE_INTERVAL];
            
            NSArray *conexus = [Conexus conexusesFromJSONArray:[response objectForKey:@"data"]];
            block(conexus, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)getConexusDetails:(NSString *)conexusId block:(void (^)(Conexus *, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/conexus/%@?with_conexus_country=1&with_conexus_moderators=1&with_conexus_user_score=1&with_conexus_content_count=1&with_conexus_user_content_count=1&with_conexus_count=1", conexusId];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            Conexus *conexus = [Conexus conexusFromJSON:[response objectForKey:@"data"]];
            block(conexus, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)getConexusPosts:(NSString *)conexusId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/conexus_content/?with_content_count=1&with_content_user=1&with_content_original_content=0&with_content_attachments=1&with_content_pictures=1&with_content_links=1&with_content_videos=1&with_content_comments=0&with_content_comment_user=0&with_content_courses=0&with_content_conexuses=0&with_user_country=1&with_content_courses=1&with_content_conexuses=1&with_user_profile=0&conexus_id=%@&course_content_list_order=most_new&with_content_comment_sub_comments=0&limit=%i&offset=%i", conexusId, limit, offset];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            NSArray *conexusPosts = [Post postsFromJSONArray:[response objectForKey:@"data"]];
            block(conexusPosts, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)getConexusMembers:(NSString *)conexusId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/conexus_user/?conexus_id=%@&with_user_country=1&with_user_score=0&with_user_profile=0&with_conexus_user_model=1&with_conexus_user_count=1&with_conexus_user_score=1&limit=%i&offset=%i", conexusId, limit, offset];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            NSArray *users = [ConexusUser conexusUsersFromJSONArray:[response objectForKey:@"data"]];
            block(users, err);
        } else {
            block(nil, err);
        }
    }];
}

@end

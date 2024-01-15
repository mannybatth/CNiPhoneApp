//
//  PostStore.m
//  CNApp
//
//  Created by Manpreet Singh on 6/30/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "PostStore.h"

@implementation PostStore

+ (void)getPostById:(NSString *)postId block:(void (^)(Post *, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/content/%@?with_content_count=1&with_content_user=1&with_content_original_content=0&with_content_attachments=1&with_content_pictures=1&with_content_links=1&with_content_videos=1&with_user_country=1&with_content_courses=1&with_content_conexuses=1", postId];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            Post *post = [Post postFromJSON:[response objectForKey:@"data"]];
            block(post, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (NSOperation*)createPost:(NSString*)text withImages:(NSArray*)uploadedImgsId withVideos:(NSArray*)videos groupsIds:(NSArray*)groupsIds relations:(NSDictionary*)relations block:(void (^)(NSArray *postContent, NSString *error))block
{
    NSString *query = @"/post/?return_detail=1&with_content_count=1&with_content_user=1&with_content_original_content=0&with_content_attachments=1&with_content_pictures=1&with_content_links=1&with_content_videos=1&with_user_country=1";
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            text, @"text",
                            uploadedImgsId, @"pictures",
                            relations, @"relations",
                            videos, @"videos",
                            groupsIds, @"auth_assignment_group_ids",
                            nil];
    
    NSOperation *operation = [BaseStore api:query parameters:params completionBlock:^(id response, NSString *err) {
        if (!err) {
            NSArray *arr = [NSArray arrayWithObjects:[response objectForKey:@"data"], nil];
            NSArray *postContent = [Post postsFromJSONArray:arr];
            block(postContent, nil);
        } else {
            block(nil, err);
        }
    }];
    return operation;
}

+ (void)createCommentWithPostId:(NSString*)postId text:(NSString*)text block:(void (^)(Comment *comment, NSString *error))block
{
    NSString *query = @"/content_comment/?return_detail=1&with_content_comment_user=1";
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            postId, @"content_id",
                            text, @"text",
                            nil];
    
    [BaseStore api:query parameters:params completionBlock:^(id response, NSString *err) {
        if (!err) {
            Comment *comment = [Comment commentFromJSON:[response objectForKey:@"data"]];
            block(comment, nil);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)getHomePostsWithFilter:(NSString*)filter limit:(int)limit offset:(int)offset block:(void (^)(NSArray *posts, NSString *error))block
{
    NSString *apiMethod;
    NSString *listOrder;
    
    if ([filter isEqualToString:@"New Posts"]) {
        apiMethod = @"content";
        listOrder = @"content_list_order=most_new";
    } else if ([filter isEqualToString:@"New Reflections"]) {
        apiMethod = @"content";
        listOrder = @"content_list_order=most_new_comment";
    } else if ([filter isEqualToString:@"Popular Posts"]) {
        apiMethod = @"content";
        listOrder = @"content_list_order=most_popular";
    } else if ([filter isEqualToString:@"My Posts"]) {
        apiMethod = @"user_content";
        listOrder = @"user_content_list_order=most_new";
    } else if ([filter isEqualToString:@"Following"]) {
        apiMethod = @"content_from_following";
        listOrder = @"content_from_follower_list_order=most_new";
    } else if ([filter isEqualToString:@"Colleagues"]) {
        apiMethod = @"content_from_colleague";
        listOrder = @"content_from_colleague_list_order=most_new";
    } else if ([filter isEqualToString:@"Public Posts"]) {
        apiMethod = @"content_from_public";
        listOrder = @"content_from_public_list_order=most_new";
    } else if ([filter isEqualToString:@"Reposts"]) {
        apiMethod = @"content_from_repost";
        listOrder = @"content_from_repost_list_order=most_new";
    } else if ([filter isEqualToString:@"CN Admin Posts"]) {
        apiMethod = @"content_from_admin";
        listOrder = @"content_from_admin_list_order=most_new";
    } else {
        apiMethod = @"content";
        listOrder = @"user_content_list_order=most_new";
    }
    
    NSString *query = [NSString stringWithFormat:@"/%@/?with_content_count=1&with_content_user=1&with_content_original_content=0&with_content_attachments=1&with_content_pictures=1&with_content_links=1&with_content_videos=1&with_user_country=1&with_content_courses=1&with_content_conexuses=1&%@&limit=%i&offset=%i", apiMethod, listOrder, limit, offset];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            NSArray *posts = [Post postsFromJSONArray:[response objectForKey:@"data"]];
            block(posts, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)getPostsFromUser:(NSString *)userId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/user_content/?with_content_count=1&with_content_user=1&with_content_original_content=0&with_content_attachments=1&with_content_pictures=1&with_content_links=1&with_content_videos=1&with_user_country=1&with_content_courses=1&with_content_conexuses=1&user_content_list_order=most_new&user_id=%@&limit=%i&offset=%i", userId, limit, offset];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            NSArray *posts = [Post postsFromJSONArray:[response objectForKey:@"data"]];
            block(posts, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)getPostComments:(NSString*)postId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *postContent, NSString *error))block
{
    NSString *query = [NSString stringWithFormat:@"/content_comment/?with_content_count=1&with_content_user=1&with_content_original_content=0&with_content_attachments=1&with_content_pictures=1&with_content_links=1&with_content_videos=1&with_content_comments=1&with_content_comment_user=1&with_user_country=1&user_content_list_order=most_new&with_content_comment_sub_comments=1&without_content_comment_autolink=0&content_id=%@&content_comment_list_order=most_new&limit=%i&offset=%i", postId, limit, offset];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            NSArray *comments = [Comment commentsFromJSONArray:[response objectForKey:@"data"]];
            block(comments, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)likePostWithId:(NSString *)postId block:(void (^)(BOOL, NSString *))block
{
    NSString *query = @"/content_good";
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            postId, @"content_id",
                            nil];
    
    [BaseStore api:query parameters:params completionBlock:^(id response, NSString *err) {
        if (!err) {
            block(YES, nil);
        } else {
            block(NO, err);
        }
    }];
}

+ (void)unlikePostWithId:(NSString *)postId block:(void (^)(BOOL, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/content_good/%@", postId];
    
    [BaseStore api:query header:nil parameters:nil method:@"DELETE" completionBlock:^(id response, NSString *err) {
        if (!err) {
            block(YES, nil);
        } else {
            block(NO, err);
        }
    }];
}

+ (void)getPostLikes:(NSString *)postId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/content_good/?content_id=%@&with_user_profile=0&with_user_relations=0&with_user_country=1&with_user_count=0&with_user_score=1&limit=%i&offset=%i", postId, limit, offset];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            NSArray *users = [User usersFromJSONArray:[response objectForKey:@"data"]];
            block(users, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)deletePost:(NSString *)postId block:(void (^)(BOOL, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/post/%@", postId];
    
    [BaseStore api:query header:nil parameters:nil method:@"DELETE" completionBlock:^(id response, NSString *err) {
        if (!err) {
            block(YES, nil);
        } else {
            block(NO, err);
        }
    }];
}

@end

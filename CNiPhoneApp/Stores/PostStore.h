//
//  PostStore.h
//  CNApp
//
//  Created by Manpreet Singh on 6/30/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "BaseStore.h"
#import "Post.h"

@interface PostStore : BaseStore

+ (void)getPostById:(NSString*)postId block:(void (^)(Post *post, NSString *error))block;
+ (void)getHomePostsWithFilter:(NSString*)filter limit:(int)limit offset:(int)offset block:(void (^)(NSArray *posts, NSString *error))block;
+ (void)getPostsFromUser:(NSString*)userId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *posts, NSString *error))block;
+ (void)getPostComments:(NSString*)postId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *postContent, NSString *error))block;
+ (void)createCommentWithPostId:(NSString*)postId text:(NSString*)text block:(void (^)(Comment *comment, NSString *error))block;
+ (void)likePostWithId:(NSString*)postId block:(void (^)(BOOL success, NSString *error))block;
+ (void)unlikePostWithId:(NSString*)postId block:(void (^)(BOOL success, NSString *error))block;
+ (void)getPostLikes:(NSString*)postId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *users, NSString *error))block;
+ (void)deletePost:(NSString*)postId block:(void (^)(BOOL success, NSString *error))block;

+ (NSOperation*)createPost:(NSString*)text withImages:(NSArray*)uploadedImgsId withVideos:(NSArray*)videos groupsIds:(NSArray*)groupsIds relations:(NSDictionary*)relations block:(void (^)(NSArray *postContent, NSString *error))block;

@end

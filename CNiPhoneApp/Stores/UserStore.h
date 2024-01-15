//
//  UserStore.h
//  CNApp
//
//  Created by Manpreet Singh on 6/26/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "BaseStore.h"
#import "User.h"

@interface UserStore : BaseStore

+ (void)getUserById:(NSString*)userId full:(BOOL)full block:(void (^)(User *, NSString *))block;
+ (void)getUserByCNNumber:(NSString*)cnNumber full:(BOOL)full block:(void (^)(User *, NSString *))block;
+ (void)getMe:(void (^)(User *user, NSString *error))block;

+ (void)getUserCourseConexusTab:(void (^)(NSArray *contentsArr, NSString *error))block;

+ (void)getUserFollowers:(NSString*)userId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *contentsArr, NSString *error))block;
+ (void)getUserFollowing:(NSString*)userId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *contentsArr, NSString *error))block;
+ (void)getUserColleagues:(NSString*)userId limit:(int)limit offset:(int)offset block:(void (^)(NSArray *contentsArr, NSString *error))block;

+ (void)followUser:(NSString*)userId block:(void (^)(BOOL, NSString *))block;
+ (void)unFollowUser:(NSString*)userId block:(void (^)(BOOL, NSString *))block;

@end

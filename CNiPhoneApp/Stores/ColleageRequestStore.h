//
//  ColleageRequestStore.h
//  CNiPhoneApp
//
//  Created by Manny on 4/3/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "BaseStore.h"
#import "ColleagueRequest.h"

@interface ColleageRequestStore : BaseStore

+ (void)getUserColleagueRequestsWithLimit:(int)limit offset:(int)offset block:(void (^)(NSArray *requests, NSString *error))block;

+ (void)sendColleageRequest:(NSString*)userId block:(void (^)(BOOL, NSString *))block;
+ (void)cancelColleageRequest:(NSString*)userId block:(void (^)(BOOL, NSString *))block;
+ (void)setUserColleageRequestStatus:(NSString*)userId status:(int)status block:(void (^)(BOOL success, NSString *error))block;

@end

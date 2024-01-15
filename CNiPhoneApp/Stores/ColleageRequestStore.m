//
//  ColleageRequestStore.m
//  CNiPhoneApp
//
//  Created by Manny on 4/3/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "ColleageRequestStore.h"

@implementation ColleageRequestStore

+ (void)getUserColleagueRequestsWithLimit:(int)limit offset:(int)offset block:(void (^)(NSArray *requests, NSString *error))block
{
    NSString *query = [NSString stringWithFormat:@"/user_colleague_request/?limit=%i&offset=%i", limit, offset];
    
    [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            NSArray *requests = [ColleagueRequest requestsFromJSONArray:[response objectForKey:@"data"]];
            block(requests, err);
        } else {
            block(nil, err);
        }
    }];
}

+ (void)sendColleageRequest:(NSString *)userId block:(void (^)(BOOL, NSString *))block
{
    NSString *query = @"/user_colleague";
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userId, @"colleague_user_id",
                            nil];
    
    [BaseStore api:query parameters:params completionBlock:^(id response, NSString *err) {
        if (!err) {
            block(YES, nil);
        } else {
            block(NO, err);
        }
    }];
}

+ (void)cancelColleageRequest:(NSString *)userId block:(void (^)(BOOL, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/user_colleague/%@", userId];
    
    [BaseStore api:query header:nil parameters:nil method:@"DELETE" completionBlock:^(id response, NSString *err) {
        if (!err) {
            block(YES, nil);
        } else {
            block(NO, err);
        }
    }];
}

+ (void)setUserColleageRequestStatus:(NSString*)userId status:(int)status block:(void (^)(BOOL success, NSString *error))block
{
    NSString *query = [NSString stringWithFormat:@"/user_colleague/%@?status=%i", userId, status];
    
    [BaseStore api:query header:nil parameters:nil method:@"PUT" completionBlock:^(id response, NSString *err) {
        if (!err) {
            block(YES, err);
        } else {
            block(NO, err);
        }
    }];
}

@end

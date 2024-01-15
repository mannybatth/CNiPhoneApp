//
//  SearchStore.m
//  CNApp
//
//  Created by Manpreet Singh on 8/17/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "SearchStore.h"

@implementation SearchStore

+ (NSOperation*)searchForUser:(NSString *)keyword limit:(int)limit offset:(int)offset block:(void (^)(NSArray *, NSString *))block
{
    NSString *query = [NSString stringWithFormat:@"/search_user/?keyword=%@&limit=%i&offset=%i", keyword, limit, offset];
    
    return [BaseStore api:query completionBlock:^(id response, NSString *err) {
        if (!err) {
            NSArray *users = [User usersFromJSONArray:[response objectForKey:@"data"]];
            block(users, err);
        } else {
            block(nil, err);
        }
    }];
}

@end

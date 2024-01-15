//
//  ColleagueRequest.m
//  CNApp
//
//  Created by Manpreet Singh on 7/2/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "ColleagueRequest.h"

@implementation ColleagueRequest

+ (ColleagueRequest *)requestFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"display_time": @"displayTime",
                              @"type": @"type"
                              };
    ColleagueRequest *request = [ColleagueRequest objectFromJSONObject:dict mapping:mapping];
    request.user = [User userFromJSON:dict];
    return request;
}

+ (NSArray *)requestsFromJSONArray:(NSArray *)arr
{
    NSMutableArray *requestsMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        ColleagueRequest *request = [ColleagueRequest requestFromJSON:obj];
        [requestsMapped addObject:request];
    }];
    
    return requestsMapped;
}

@end

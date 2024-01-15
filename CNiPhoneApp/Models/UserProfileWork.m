//
//  UserProfileWork.m
//  CNApp
//
//  Created by Manpreet Singh on 7/11/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "UserProfileWork.h"

@implementation UserProfileWork

+ (UserProfileWork *)workFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"company": @"workCompany",
                              @"position": @"workPosition"
                              };
    UserProfileWork *work = [UserProfileWork objectFromJSONObject:dict mapping:mapping];
    return work;
}

+ (NSArray *)worksFromJSONArray:(NSArray *)arr
{
    NSMutableArray *worksMapped = [NSMutableArray new];
    [arr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        UserProfileWork *work = [UserProfileWork workFromJSON:dict];
        [worksMapped addObject:work];
    }];
    return worksMapped;
}

@end

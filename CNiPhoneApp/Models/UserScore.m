//
//  UserScore.m
//  CNApp
//
//  Created by Manpreet Singh on 7/10/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "UserScore.h"

@implementation UserScore

+ (UserScore *)scoreFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"total": @"total",
                              @"total_seeds": @"totalSeeds",
                              @"sub_total": @"subTotal",
                              @"sub_total_seeds": @"subTotalSeeds"
                              };
    UserScore *score = [UserScore objectFromJSONObject:dict mapping:mapping];
    return score;
}

@end

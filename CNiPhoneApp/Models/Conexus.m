//
//  Conexus.m
//  CNApp
//
//  Created by Manpreet Singh on 7/1/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "Conexus.h"
#import "Tools.h"

@implementation Conexus

+ (Conexus *)conexusFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"id": @"conexusId",
                              @"conexus_id": @"conexusNumber",
                              @"name": @"name",
                              @"about": @"about",
                              @"display_time": @"displayTime",
                              @"logo_url": @"logoURL",
                              @"user_position": @"userPosition"
                              };
    Conexus *conexus = [Conexus objectFromJSONObject:dict mapping:mapping];
    conexus.about = [Tools replaceHtmlCharacters:conexus.about];
    return conexus;
}

+ (NSArray *)conexusesFromJSONArray:(NSArray *)arr
{
    NSMutableArray *conexusesMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        Conexus *conexus = [Conexus conexusFromJSON:obj];
        [conexusesMapped addObject:conexus];
    }];
    
    return conexusesMapped;
}

@end

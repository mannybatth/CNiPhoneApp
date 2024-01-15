//
//  Link.m
//  CNApp
//
//  Created by Manpreet Singh on 7/29/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "Link.h"

@implementation Link

+ (Link *)linkFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"display_url": @"displayUrl",
                              @"view_url": @"viewUrl"
                              };
    Link *link = [Link objectFromJSONObject:dict mapping:mapping];
    return link;
}

+ (NSArray *)linksFromJSONArray:(NSArray *)arr
{
    NSMutableArray *linksMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        Link *link = [Link linkFromJSON:obj];
        [linksMapped addObject:link];
    }];
    
    return linksMapped;
}

@end

//
//  Picture.m
//  CNApp
//
//  Created by Manpreet Singh on 6/28/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "Picture.h"

@implementation Picture

+ (Picture *)pictureFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"id": @"pictureId",
                              @"name": @"pictureName",
                              @"view_url": @"pictureURL",
                              @"extension": @"pictureExt",
                              @"size": @"pictureSize",
                              @"display_time": @"pictureDisplayTime"
                              };
    Picture *picure = [Picture objectFromJSONObject:dict mapping:mapping];
    return picure;
}

+ (NSArray *)picturesFromJSONArray:(NSArray *)arr
{
    NSMutableArray *commentsMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        Picture *picure = [Picture pictureFromJSON:obj];
        [commentsMapped addObject:picure];
    }];
    
    return commentsMapped;
}

@end

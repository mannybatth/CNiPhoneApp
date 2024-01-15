//
//  Link.h
//  CNApp
//
//  Created by Manpreet Singh on 7/29/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface Link : NSObject

@property (nonatomic, strong) NSString *displayUrl;
@property (nonatomic, strong) NSString *viewUrl;

+ (Link *)linkFromJSON:(NSDictionary *)dict;
+ (NSArray *)linksFromJSONArray:(NSArray *)arr;

@end

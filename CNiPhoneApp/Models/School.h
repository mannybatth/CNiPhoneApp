//
//  School.h
//  CNApp
//
//  Created by Manpreet Singh on 7/14/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface School : NSObject

@property (nonatomic, strong) NSString *schoolId;
@property (nonatomic, strong) NSString *schoolName;
@property (nonatomic, strong) NSString *schoolURL;

+ (School *)schoolFromJSON:(NSDictionary *)dict;
+ (NSArray *)schoolsFromJSONArray:(NSArray *)arr;

@end

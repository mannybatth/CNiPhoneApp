//
//  UserProfileSchool.h
//  CNApp
//
//  Created by Manpreet Singh on 7/11/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface UserProfileSchool : NSObject

@property (nonatomic, strong) NSString *schoolType;
@property (nonatomic, strong) NSString *schoolName;
@property (nonatomic, strong) NSString *schoolDisplayType;
@property (nonatomic, strong) NSString *schoolWebAddress;

+ (UserProfileSchool *)schoolFromJSON:(NSDictionary *)dict;
+ (NSArray*)schoolsFromJSONArray:(id)arr;

@end

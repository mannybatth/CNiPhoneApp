//
//  UserProfilePosition.h
//  CNApp
//
//  Created by Manpreet Singh on 7/11/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface UserProfilePosition : NSObject

@property (nonatomic, strong) NSString *positionName;
@property (nonatomic, strong) NSString *positionSchoolName;
@property (nonatomic, strong) NSString *positionType;
@property (nonatomic, strong) NSString *positionWebAddress;

+ (UserProfilePosition *)positionFromJSON:(NSDictionary *)dict;
+ (NSArray*)positionsFromJSONArray:(NSArray *)arr;

@end

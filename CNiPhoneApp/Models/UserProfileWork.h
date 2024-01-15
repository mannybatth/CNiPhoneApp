//
//  UserProfileWork.h
//  CNApp
//
//  Created by Manpreet Singh on 7/11/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface UserProfileWork : NSObject

@property (nonatomic, strong) NSString *workCompany;
@property (nonatomic, strong) NSString *workPosition;

+ (UserProfileWork *)workFromJSON:(NSDictionary *)dict;
+ (NSArray*)worksFromJSONArray:(NSArray *)arr;

@end

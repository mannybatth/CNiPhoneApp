//
//  CourseCount.h
//  CNApp
//
//  Created by Manpreet Singh on 7/18/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface CourseCount : NSObject

@property (nonatomic) int all;
@property (nonatomic) int instructor;
@property (nonatomic) int student;

+ (CourseCount *)courseCountFromJSON:(NSDictionary *)dict;

@end

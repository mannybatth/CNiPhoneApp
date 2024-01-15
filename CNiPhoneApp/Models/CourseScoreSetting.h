//
//  CourseScoreSetting.h
//  CNApp
//
//  Created by Manpreet Singh on 8/5/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface CourseScoreSetting : NSObject

@property (nonatomic) float percentage;
@property (nonatomic) int requiredNumber;
@property (nonatomic) int use;
@property (nonatomic) double dueDateUnixStamp;
@property (nonatomic, strong) NSDate *dueDate;

+ (CourseScoreSetting *)courseScoreSettingFromJSON:(NSDictionary *)dict;

@end

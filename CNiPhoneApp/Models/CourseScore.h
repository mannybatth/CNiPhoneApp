//
//  CourseScore.h
//  CNApp
//
//  Created by Manpreet Singh on 7/29/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface CourseScore : NSObject

@property (nonatomic) float averageScore;
@property (nonatomic) float averageStudentScore;
@property (nonatomic) float totalSeeds;

+ (CourseScore *)courseScoreFromJSON:(NSDictionary *)dict;

@end

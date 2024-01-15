//
//  UserScore.h
//  CNApp
//
//  Created by Manpreet Singh on 7/10/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface UserScore : NSObject

@property (nonatomic) float total;
@property (nonatomic) float totalSeeds;
@property (nonatomic) float subTotal;
@property (nonatomic) float subTotalSeeds;

+ (UserScore *)scoreFromJSON:(NSDictionary *)dict;

@end

//
//  PostCount.h
//  CNApp
//
//  Created by Manpreet Singh on 7/7/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface PostCount : NSObject

@property (nonatomic) int comments;
@property (nonatomic) int likes;
@property (nonatomic) int remembers;
@property (nonatomic) int reposts;
@property (nonatomic) int views;

+ (PostCount *)countFromJSON:(NSDictionary *)dict;

@end

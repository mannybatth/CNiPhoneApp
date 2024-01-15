//
//  PollChoice.h
//  CNApp
//
//  Created by Manpreet Singh on 9/24/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface PollChoice : NSObject

@property (nonatomic, strong) NSString *seqId;
@property (nonatomic, strong) NSString *subject;

+ (PollChoice *)choiceFromJSON:(NSDictionary *)dict;
+ (NSArray *)choicesFromJSONArray:(NSArray *)arr;

@end

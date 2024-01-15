//
//  PollChoice.m
//  CNApp
//
//  Created by Manpreet Singh on 9/24/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "PollChoice.h"

@implementation PollChoice

+ (PollChoice *)choiceFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"seq_id": @"seqId",
                              @"subject": @"subject"
                              };
    PollChoice *choice = [PollChoice objectFromJSONObject:dict mapping:mapping];
    return choice;
}

+ (NSArray *)choicesFromJSONArray:(NSArray *)arr
{
    NSMutableArray *choicesMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        PollChoice *choice = [PollChoice choiceFromJSON:obj];
        [choicesMapped addObject:choice];
    }];
    
    return choicesMapped;
}

@end

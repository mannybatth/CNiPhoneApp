//
//  SearchStore.h
//  CNApp
//
//  Created by Manpreet Singh on 8/17/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "BaseStore.h"

@interface SearchStore : BaseStore

+ (NSOperation*)searchForUser:(NSString*)keyword limit:(int)limit offset:(int)offset block:(void (^)(NSArray *, NSString *))block;

@end

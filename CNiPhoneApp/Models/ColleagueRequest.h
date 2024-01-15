//
//  ColleagueRequest.h
//  CNApp
//
//  Created by Manpreet Singh on 7/2/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "User.h"

@interface ColleagueRequest : NSObject

@property (nonatomic, strong) NSString *displayTime;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *type;

@property (nonatomic) BOOL isAccepted;
@property (nonatomic) BOOL isRejected;

+ (ColleagueRequest *)requestFromJSON:(NSDictionary *)dict;
+ (NSArray *)requestsFromJSONArray:(NSArray *)arr;

@end

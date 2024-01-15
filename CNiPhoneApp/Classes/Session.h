//
//  Session.h
//  CNApp
//
//  Created by Manpreet Singh on 6/24/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "User.h"

@interface Session : NSObject

@property (nonatomic, strong) NSString *currentToken;
@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) NSArray *currentUserCourses;
@property (nonatomic, strong) NSArray *currentUserConexus;
@property (nonatomic) BOOL timerStarted;

+ (instancetype)shared;
+ (void)setUserToken:(NSString*)token;

@end

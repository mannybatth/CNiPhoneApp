//
//  Comment.h
//  CNApp
//
//  Created by Manpreet Singh on 6/27/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "User.h"

@interface Comment : NSObject

@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *displayTime;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) User *user;

+ (Comment *)commentFromJSON:(NSDictionary *)dict;
+ (NSArray *)commentsFromJSONArray:(NSArray *)arr;

@property (nonatomic) CGFloat commentContentHeight;

@end

//
//  Comment.m
//  CNApp
//
//  Created by Manpreet Singh on 6/27/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "Comment.h"
#import "Tools.h"

@implementation Comment

+ (Comment *)commentFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"id": @"commentId",
                              @"display_time": @"displayTime",
                              @"text": @"text"
                              };
    Comment *comment = [Comment objectFromJSONObject:dict mapping:mapping];
    comment.user = [User userFromJSON:[dict objectForKey:@"user"]];
    comment.text = [NSString trimWhiteSpace:comment.text];
    comment.text = [Tools replaceHtmlCharacters:comment.text];
    comment.text = [Tools removeBreaks:comment.text];
    if (comment.text == nil) comment.text = @"";
    return comment;
}

+ (NSArray *)commentsFromJSONArray:(NSArray *)arr
{
    NSMutableArray *commentsMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        Comment *comment = [Comment commentFromJSON:obj];
        [commentsMapped addObject:comment];
    }];
    
    return commentsMapped;
}

@end

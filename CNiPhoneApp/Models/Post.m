//
//  Post.m
//  CNApp
//
//  Created by Manpreet Singh on 6/26/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "Post.h"
#import "Course.h"
#import "Conexus.h"
#import "Tools.h"

@implementation Post

+ (Post *)postFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"id": @"postId",
                              @"display_time": @"displayTime",
                              @"pictures": @"pictures",
                              @"text": @"rawText",
                              @"type": @"postType",
                              @"user_position": @"userPosition",
                              @"comments": @"comments",
                              @"title": @"title",
                              @"original_share_link": @"originalShareLink",
                              @"share_link": @"shareLink",
                              @"description": @"description",
                              @"display_start_time": @"eventDisplayStartTime",
                              @"display_end_time": @"eventDisplayEndTime",
                              @"where": @"eventWhere",
                              @"has_set_good": @"isLiked",
                              @"is_deletable": @"isDeletable",
                              @"is_editable": @"isEditable",
                              @"is_from_admin": @"isFromAdmin",
                              @"is_owner": @"isOwner",
                              @"is_repostable": @"isRepostable"
                              };
    Post *post = [Post objectFromJSONObject:dict mapping:mapping];
    post.postDate = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"ctime"] doubleValue]];
    post.user = [User userFromJSON:[dict objectForKey:@"user"]];
    post.comments = [Comment commentsFromJSONArray:[dict objectForKey:@"comments"]];
    post.pictures = (NSMutableArray*)[Picture picturesFromJSONArray:[dict objectForKey:@"pictures"]];
    post.count = [PostCount countFromJSON:[dict objectForKey:@"count"]];
    post.links = [Link linksFromJSONArray:[dict objectForKey:@"links"]];
    post.videos = [Video videosFromJSONArray:[dict objectForKey:@"videos"]];
    post.attachments = [Attachment attachmentsFromJSONArray:[dict objectForKey:@"attachments"]];
    post.title = [Tools replaceHtmlCharacters:post.title];
    post.description = [Tools replaceHtmlCharacters:post.description];
    post.courses = [Course coursesFromJSONArray:[dict objectForKey:@"courses"]];
    post.conexuses = [Conexus conexusesFromJSONArray:[dict objectForKey:@"conexuses"]];
    
    // use index 0 for sharelink pic
    if ([post.postType isEqualToString:CONTENT_TYPE_SHARELINK] && post.pictures.count > 0) {
        post.shareLinkPicture = [post.pictures objectAtIndex:0];
        [post.pictures removeObjectAtIndex:0];
    }
    
    // event
    if ([post.postType isEqualToString:CONTENT_TYPE_EVENT]) {
        post.rawText = [NSString stringWithFormat:@"<b>When</b> %@ to %@ \n\n<b>Where</b> %@ \n\n%@", post.eventDisplayStartTime, post.eventDisplayEndTime, post.eventWhere, post.rawText];
    }
    
    post.hasAttachments = ([post.pictures count] > 0 || [post.videos count] > 0) ? YES : NO;
    post.hasLinks = ([post.links count] > 0 || [post.attachments count]) ? YES : NO;
    
    // polls
    post.pollItems = [PollItem itemsFromJSONArray:[dict objectForKey:@"items"]];
    
    if (post.rawText != nil) {
        post.rawText = [NSString trimWhiteSpace:post.rawText];
        post.rawText = [Tools replaceHtmlCharacters:post.rawText];
        post.rawText = [Tools removeBreaks:post.rawText];
        post.text = [Tools stripTags:post.rawText];
        
        CGFloat maxLength = 500;
        NSRange stringRange = {0, MIN([post.rawText length], maxLength)};
        if (stringRange.length <= [post.rawText length]) {
            stringRange = [post.rawText rangeOfComposedCharacterSequencesForRange:stringRange];
            NSString *shortString = [post.rawText substringWithRange:stringRange];
            post.shortRawText = [shortString mutableCopy];
        } else {
            post.shortRawText = [post.rawText mutableCopy];
        }
        if (post.shortRawText == nil) post.shortRawText = @"";
        if (post.text == nil) post.text = @"";
    } else {
        post.rawText = @"";
        post.text = @"";
        post.shortRawText = @"";
    }
    
    return post;
}

+ (NSArray*)postsFromJSONArray:(NSArray *)arr
{
    NSArray *supportedTypes = @[
                                CONTENT_TYPE_POST,
                                CONTENT_TYPE_ASSIGNMENT,
                                CONTENT_TYPE_EVENT,
                                CONTENT_TYPE_QUIZ,
                                CONTENT_TYPE_POLL,
                                CONTENT_TYPE_CLASSCAST,
                                CONTENT_TYPE_EMAIL,
                                CONTENT_TYPE_SHARELINK
                                ];
    
    NSMutableArray *postsMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        if ([supportedTypes containsObject:[obj objectForKey:@"type"]]) {
            Post *post = [Post postFromJSON:obj];
            [postsMapped addObject:post];
        }
    }];
    
    return postsMapped;
}

@end

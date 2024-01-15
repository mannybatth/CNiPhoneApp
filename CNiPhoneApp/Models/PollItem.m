//
//  PollItem.m
//  CNApp
//
//  Created by Manpreet Singh on 9/5/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "PollItem.h"
#import "Tools.h"

@implementation PollItem

+ (PollItem *)itemFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"text": @"rawText",
                              @"survey_type": @"pollType",
                              @"correct_response_text": @"correctResponseText",
                              @"question_count": @"questionCount",
                              @"question_order": @"questionOrder",
                              @"submission_count": @"submissionCount",
                              @"has_submissions_count": @"hasSubmissionsCount",
                              @"is_display_result": @"isDisplayResult",
                              @"is_display_user": @"isDisplayUser",
                              @"is_enable": @"isEnable",
                              @"is_end": @"isEnd",
                              @"is_owner": @"isOwner",
                              @"is_pictures": @"isPictures",
                              @"is_short_answer_type": @"isShortAnswerType",
                              @"is_user_submit": @"isUserSubmit",
                              @"result_message": @"resultMessage"
                              };
    
    PollItem *item = [PollItem objectFromJSONObject:dict mapping:mapping];
    item.choices = [PollChoice choicesFromJSONArray:[dict objectForKey:@"choices"]];
    item.pictures = (NSMutableArray*)[Picture picturesFromJSONArray:[dict objectForKey:@"pictures"]];
    item.links = [Link linksFromJSONArray:[dict objectForKey:@"links"]];
    item.videos = [Video videosFromJSONArray:[dict objectForKey:@"videos"]];
    item.attachments = [Attachment attachmentsFromJSONArray:[dict objectForKey:@"attachments"]];
    if (item.rawText != nil) {
        item.rawText = [NSString trimWhiteSpace:item.rawText];
        item.rawText = [Tools replaceHtmlCharacters:item.rawText];
        item.rawText = [Tools removeBreaks:item.rawText];
        item.text = [Tools stripTags:item.rawText];
        
        CGFloat maxLength = 500;
        NSRange stringRange = {0, MIN([item.rawText length], maxLength)};
        if (stringRange.length <= [item.rawText length]) {
            stringRange = [item.rawText rangeOfComposedCharacterSequencesForRange:stringRange];
            NSString *shortString = [item.rawText substringWithRange:stringRange];
            item.shortRawText = [shortString mutableCopy];
        } else {
            item.shortRawText = [item.rawText mutableCopy];
        }
        if (item.shortRawText == nil) item.shortRawText = @"";
        if (item.text == nil) item.text = @"";
    } else {
        
    }
    
    return item;
}

+ (NSArray *)itemsFromJSONArray:(NSArray *)arr
{
    NSMutableArray *itemsMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        PollItem *item = [PollItem itemFromJSON:obj];
        [itemsMapped addObject:item];
    }];
    
    return itemsMapped;
}

@end

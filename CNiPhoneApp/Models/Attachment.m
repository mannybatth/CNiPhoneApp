//
//  Attachment.m
//  CNApp
//
//  Created by Manpreet Singh on 8/13/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "Attachment.h"

@implementation Attachment

+ (Attachment *)attachmentFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"id": @"attachmentId",
                              @"name": @"attachmentName",
                              @"view_url": @"attachmentURL",
                              @"extension": @"attachmentExt",
                              @"size": @"attachmentSize",
                              @"display_time": @"attachmentDisplayTime"
                              };
    Attachment *attachment = [Attachment objectFromJSONObject:dict mapping:mapping];
    return attachment;
}

+ (NSArray *)attachmentsFromJSONArray:(NSArray *)arr
{
    NSArray *supportedExts = @[@"bmp", @"jpg", @"jpeg", @"png", @"gif", @"tiff", @"doc", @"docx", @"ppt", @"pptx", @"xls", @"xlsx", @"pdf", @"txt", @"rtf"];
    NSMutableArray *attachmentsMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        Attachment *attachment = [Attachment attachmentFromJSON:obj];
        if ([supportedExts containsObject:attachment.attachmentExt]) [attachmentsMapped addObject:attachment];
    }];
    
    return attachmentsMapped;
}

@end

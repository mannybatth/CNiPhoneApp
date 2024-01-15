//
//  Video.m
//  CNApp
//
//  Created by Manpreet Singh on 7/29/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "Video.h"

@implementation Video

+ (Video *)videoFromJSON:(NSDictionary *)dict
{
    NSDictionary *mapping = @{
                              @"view_url": @"viewUrl"
                              };
    Video *video = [Video objectFromJSONObject:dict mapping:mapping];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)"
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:nil];
    [regex enumerateMatchesInString:video.viewUrl options:0 range:NSMakeRange(0, [video.viewUrl length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSString *youtubeKey = [video.viewUrl substringWithRange:[result range]];
        video.youtubeId = youtubeKey;
    }];
    
    return video;
}

+ (NSArray *)videosFromJSONArray:(NSArray *)arr
{
    NSMutableArray *videosMapped = [NSMutableArray new];
    
    [arr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        Video *video = [Video videoFromJSON:obj];
        [videosMapped addObject:video];
    }];
    
    return videosMapped;
}

@end

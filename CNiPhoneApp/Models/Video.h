//
//  Video.h
//  CNApp
//
//  Created by Manpreet Singh on 7/29/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface Video : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *viewUrl;
@property (nonatomic, strong) NSString *youtubeId;

+ (Video *)videoFromJSON:(NSDictionary *)dict;
+ (NSArray *)videosFromJSONArray:(NSArray *)arr;

@end

//
//  Picture.h
//  CNApp
//
//  Created by Manpreet Singh on 6/28/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface Picture : NSObject

@property (nonatomic, strong) NSString *pictureId;
@property (nonatomic, strong) NSString *pictureName;
@property (nonatomic, strong) NSString *pictureURL;
@property (nonatomic, strong) NSString *pictureExt;
@property (nonatomic, strong) NSString *pictureSize;
@property (nonatomic, strong) NSString *pictureDisplayTime;

+ (Picture *)pictureFromJSON:(NSDictionary *)dict;
+ (NSArray *)picturesFromJSONArray:(NSArray *)arr;

@end

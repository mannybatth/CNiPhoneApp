//
//  Attachment.h
//  CNApp
//
//  Created by Manpreet Singh on 8/13/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSObject+JTObjectMapping.h"

@interface Attachment : NSObject

@property (nonatomic, strong) NSString *attachmentId;
@property (nonatomic, strong) NSString *attachmentName;
@property (nonatomic, strong) NSString *attachmentURL;
@property (nonatomic, strong) NSString *attachmentExt;
@property (nonatomic, strong) NSString *attachmentSize;
@property (nonatomic, strong) NSString *attachmentDisplayTime;

+ (Attachment *)attachmentFromJSON:(NSDictionary *)dict;
+ (NSArray *)attachmentsFromJSONArray:(NSArray *)arr;

@end

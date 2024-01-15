//
//  Tools.h
//  CNApp
//
//  Created by Manpreet Singh on 7/5/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "NSString+Trim.h"

@interface Tools : NSObject

+ (NSString *)shortenedDate:(NSDate *)date;
+ (NSString*)formatTextString:(NSString*)text;
+ (NSString*)replaceHtmlCharacters:(NSString*)s;
+ (NSString *)removeBreaks:(NSString*)s;
+ (NSString *)stripTags:(NSString *)str;

+ (NSData*)imageDataWithRatio:(UIImage*)image maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;
+ (UIImage*)resizeImageToRatio:(UIImage*)image maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;
+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)newSize;

+ (void)makeRoundedCornersForImageView:(UIImageView*)imgV withCornerRadius:(float)cornerRadius borderColor:(CGColorRef)borderColor andBorderWidth:(float)borderWidth;

@end

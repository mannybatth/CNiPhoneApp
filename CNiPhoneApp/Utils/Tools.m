//
//  Tools.m
//  CNApp
//
//  Created by Manpreet Singh on 7/5/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "Tools.h"

@implementation Tools

+ (NSString *)shortenedDate:(NSDate *)date
{
    NSTimeInterval timeSinceDate = [[NSDate date] timeIntervalSinceDate:date];
    
    if (timeSinceDate < 60.0) // less than 60 secs
    {
        NSUInteger secondsSinceDate = (NSUInteger)(timeSinceDate);
        return [NSString stringWithFormat:@"%lu sec%s", (unsigned long)secondsSinceDate, secondsSinceDate == 1 ? "" : "s"];
    }
    else if (timeSinceDate < 60.0 * 60.0) // less than 60 mins
    {
        NSUInteger minutesSinceDate = (NSUInteger)(timeSinceDate / 60.0);
        return [NSString stringWithFormat:@"%lu min%s", (unsigned long)minutesSinceDate, minutesSinceDate == 1 ? "" : "s"];
    }
    else if (timeSinceDate < 24.0 * 60.0 * 60.0) // less than 24 hrs
    {
        NSUInteger hoursSinceDate = (NSUInteger)(timeSinceDate / (60.0 * 60.0));
        return [NSString stringWithFormat:@"%lu hr%s", (unsigned long)hoursSinceDate, hoursSinceDate == 1 ? "" : "s"];
    }
    else if (timeSinceDate < 30 * 24.0 * 60.0 * 60.0) // less than 30 days
    {
        NSUInteger daysSinceDate = (NSUInteger)(timeSinceDate / (24.0 * 60.0 * 60.0));
        return [NSString stringWithFormat:@"%lu day%s", (unsigned long)daysSinceDate, daysSinceDate == 1 ? "" : "s"];
    }
    else
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd, yyyy"];
        return [formatter stringFromDate:date];
    }
    return nil;
}

+ (NSString*)formatTextString:(NSString*)text
{
    if (text == NULL) return @"";
    NSString *s = [NSString stringWithString:text];
    
    s = [Tools removeBreaks:s];
    s = [Tools stripTags:s];
    
    return s;
}

+ (NSString*)replaceHtmlCharacters:(NSString*)s
{
    NSDictionary *characterMapping = @{
                                       @"&quot;": @"\"",
                                       @"&#034;": @"\"",
                                       @"&apos;": @"'",
                                       @"&#039;": @"'",
                                       @"&amp;": @"&",
                                       @"&#038;": @"&",
                                       @"&nbsp;": @" "
                                       };
    NSString *key;
    for (key in characterMapping) {
        s = [s stringByReplacingOccurrencesOfString:key withString:[characterMapping objectForKey:key]];
    }
    return s;
}

+ (NSString *)removeBreaks:(NSString*)s
{
    s = [s stringByReplacingOccurrencesOfString: @"<br />" withString: @"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    s = [s stringByReplacingOccurrencesOfString: @"<br/>" withString: @"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    s = [s stringByReplacingOccurrencesOfString: @"<br>" withString: @"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return s;
}

+ (NSString *)stripTags:(NSString *)str
{
    NSMutableString *html = [NSMutableString stringWithCapacity:[str length]];
    
    NSScanner *scanner = [NSScanner scannerWithString:str];
    scanner.charactersToBeSkipped = NULL;
    NSString *tempText = nil;
    
    while (![scanner isAtEnd])
    {
        [scanner scanUpToString:@"<" intoString:&tempText];
        
        if (tempText != nil)
            [html appendString:tempText];
        
        [scanner scanUpToString:@">" intoString:NULL];
        
        if (![scanner isAtEnd])
            [scanner setScanLocation:[scanner scanLocation] + 1];
        
        tempText = nil;
    }
    
    return html;
}

+ (NSData*)imageDataWithRatio:(UIImage*)image maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    UIImage *newImage = [Tools resizeImageToRatio:image maxWidth:maxWidth maxHeight:maxHeight];
    NSData *imageData = UIImageJPEGRepresentation(newImage, 0.8);
    return imageData;
}

+ (UIImage*)resizeImageToRatio:(UIImage*)image maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight
{
    CGFloat oldWidth = image.size.width;
    CGFloat oldHeight = image.size.height;
    
    CGFloat scaleFactor;
    if (oldWidth > oldHeight) {
        scaleFactor = maxWidth / oldWidth;
    } else {
        scaleFactor = maxHeight / oldHeight;
    }
    CGFloat newHeight = oldHeight * scaleFactor;
    CGFloat newWidth = oldWidth * scaleFactor;
    
    UIImage *newImage = [Tools imageWithImage:image scaledToSize:CGSizeMake(newWidth, newHeight)];
    return newImage;
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)makeRoundedCornersForImageView:(UIImageView*)imgV withCornerRadius:(float)cornerRadius borderColor:(CGColorRef)borderColor andBorderWidth:(float)borderWidth
{
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:imgV.frame];
    UIGraphicsBeginImageContextWithOptions(tempImageView.bounds.size, NO, 1.0);
    [[UIBezierPath bezierPathWithRoundedRect:tempImageView.bounds
                                cornerRadius:cornerRadius] addClip];
    [imgV.image drawInRect:tempImageView.bounds];
    tempImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    imgV.image = tempImageView.image;
    imgV.layer.shouldRasterize = YES;
    imgV.layer.borderColor = borderColor;
    imgV.layer.borderWidth = borderWidth;
    imgV.layer.cornerRadius = cornerRadius;
}

@end

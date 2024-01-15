//
//  CNButton.m
//  CNApp
//
//  Created by Manpreet Singh on 7/28/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "CNButton.h"

@implementation CNButton

- (void) drawRect:(CGRect)rect {
    
    if (isButtonTouching) {
        CGRect textRect = self.titleLabel.frame;
        CGFloat descender = self.titleLabel.font.descender;
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.textColor.CGColor);
        CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender);
        CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender);
        CGContextClosePath(contextRef);
        CGContextDrawPath(contextRef, kCGPathStroke);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    isButtonTouching = YES;
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    isButtonTouching = NO;
    [self setNeedsDisplay];
}

@end

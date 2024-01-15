//
//  PostButton.m
//  CNiPhoneApp
//
//  Created by Manny on 2/22/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "PostButton.h"

@implementation PostButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    UIImage *likeBtnImage = [UIImage imageNamed:@"post_btn_skin"];
    UIEdgeInsets likeBtnInsets = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
    UIImage *likeBtnStretchableImage = [likeBtnImage resizableImageWithCapInsets:likeBtnInsets];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundImage:likeBtnStretchableImage forState:UIControlStateNormal];
}

- (CGSize) intrinsicContentSize
{
    CGSize s = [super intrinsicContentSize];
    return CGSizeMake(s.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right,
                      s.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
}

@end

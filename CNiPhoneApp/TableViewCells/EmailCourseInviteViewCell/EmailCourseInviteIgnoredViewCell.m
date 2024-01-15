//
//  EmailCourseInviteIgnoredViewCell.m
//  CNiPhoneApp
//
//  Created by Manny on 4/3/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "EmailCourseInviteIgnoredViewCell.h"

@implementation EmailCourseInviteIgnoredViewCell

+ (CGFloat)heightOfCellWithEmailMessage:(EmailMessage *)message
{
    return 44;
}

- (void)awakeFromNib
{
}

- (void)setupViewForEmailMessage:(EmailMessage *)message
{
    CGFloat height = [EmailCourseInviteIgnoredViewCell heightOfCellWithEmailMessage:message];
    
    UIImage *backgroundImage = [[UIImage imageNamed:@"NotificationBackgroundError.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    backgroundImageView.frame = CGRectMake(0.0f, 0.0f, 270.0f, height);
    [self insertSubview:backgroundImageView belowSubview:self.rejectedLabel];
    
    self.rejectedLabel.text = @"Ignored course invite!";
}

@end

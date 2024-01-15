//
//  EmailCourseInviteAcceptedViewCell.m
//  CNiPhoneApp
//
//  Created by Manny on 4/3/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "EmailCourseInviteAcceptedViewCell.h"

@implementation EmailCourseInviteAcceptedViewCell

+ (CGFloat)heightOfCellWithEmailMessage:(EmailMessage *)message
{
    return 44;
}

- (void)awakeFromNib
{
}

- (void)setupViewForEmailMessage:(EmailMessage *)message
{
    CGFloat height = [EmailCourseInviteAcceptedViewCell heightOfCellWithEmailMessage:message];
    
    UIImage *backgroundImage = [[UIImage imageNamed:@"NotificationBackgroundSuccess.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    backgroundImageView.frame = CGRectMake(0.0f, 0.0f, 270.0f, height);
    [self insertSubview:backgroundImageView belowSubview:self.acceptedLabel];
    
    self.acceptedLabel.text = @"Accepted course invite!";
}

@end

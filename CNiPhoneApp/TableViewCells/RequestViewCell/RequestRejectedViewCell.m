//
//  RequestRejectedViewCell.m
//  CNiPhoneApp
//
//  Created by Manny on 4/3/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "RequestRejectedViewCell.h"

@implementation RequestRejectedViewCell

+ (CGFloat)heightOfCellWithColleageRequest:(ColleagueRequest *)request
{
    return 44;
}

- (void)awakeFromNib
{
}

- (void)setupViewForColleageRequest:(ColleagueRequest *)request
{
    CGFloat height = [RequestRejectedViewCell heightOfCellWithColleageRequest:request];
    
    UIImage *backgroundImage = [[UIImage imageNamed:@"NotificationBackgroundError.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth);
    backgroundImageView.frame = CGRectMake(0.0f, 0.0f, 270.0f, height);
    [self insertSubview:backgroundImageView belowSubview:self.rejectedLabel];
    
    self.rejectedLabel.text = @"Request rejected!";
}

@end

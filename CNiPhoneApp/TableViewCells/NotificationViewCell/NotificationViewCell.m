//
//  NotificationViewCell.m
//  CNiPhoneApp
//
//  Created by Manny on 3/19/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "NotificationViewCell.h"
#import "CNNavigationHelper.h"
#import "PKRevealController.h"

#define NOTF_TEXT_LABEL_WIDTH 196

@implementation NotificationViewCell

+ (CGFloat)heightOfCellWithNotification:(Notification *)notification
{
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:@"Verdana" size:12.0f]};
    CGFloat textHeight = [notification.notificationDescription boundingRectWithSize:CGSizeMake(NOTF_TEXT_LABEL_WIDTH, MAXFLOAT)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:attributes
                                                         context:nil].size.height;
    
    return MAX(66, textHeight+15);
}

- (void)awakeFromNib
{
    self.notificationAvatarView.layer.masksToBounds = YES;
    self.notificationAvatarView.layer.cornerRadius = 4;
}

- (void)setupViewForNotification:(Notification *)notification
{
    self.notification = notification;
    
    [self.notificationAvatarView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", self.notification.referencedUser.avatar]] placeholderImage:[UIImage imageNamed:@"default_profile.gif"]];
    
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myButton setTitle:@"" forState:UIControlStateNormal];
    myButton.backgroundColor = [UIColor clearColor];
    myButton.frame = self.notificationAvatarView.frame;
    myButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [myButton addTarget:self action:@selector(onAvatarBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:myButton];
    
    self.notificationTextLabel.text = self.notification.notificationDescription;
}

- (void)onAvatarBtnClick
{
    [CNNavigationHelper openProfileViewWithUser:self.notification.referencedUser];
    [self.delegate.revealController showViewController:self.delegate.revealController.frontViewController];
}

@end

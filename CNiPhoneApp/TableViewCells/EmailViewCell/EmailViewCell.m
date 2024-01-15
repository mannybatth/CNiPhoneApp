//
//  EmailViewCell.m
//  CNiPhoneApp
//
//  Created by Manny on 3/19/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "EmailViewCell.h"
#import "CNNavigationHelper.h"
#import "PKRevealController.h"

#define EMAIL_TEXT_LABEL_WIDTH 200
#define EMAIL_TEXT_LABEL_HEIGHT 44

@implementation EmailViewCell

+ (CGFloat)heightOfCellWithEmailMessage:(EmailMessage *)message
{
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:@"Verdana" size:12.0f]};
    CGFloat textHeight = [message.emailText boundingRectWithSize:CGSizeMake(EMAIL_TEXT_LABEL_WIDTH, EMAIL_TEXT_LABEL_HEIGHT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:attributes
                                                   context:nil].size.height;
    
    return MAX(66, textHeight + 47);
}

- (void)awakeFromNib
{
    self.emailAvatarView.layer.masksToBounds = YES;
    self.emailAvatarView.layer.cornerRadius = 4;
}

- (void)setupViewForEmailMessage:(EmailMessage *)message
{
    self.message = message;
    
    self.emailUserNameLabel.text = self.message.sender.displayName;
    self.emailDisplayDateLabel.text = self.message.displayTime;
    [self.emailAvatarView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", self.message.sender.avatar]] placeholderImage:[UIImage imageNamed:@"default_profile.gif"]];
    
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myButton setTitle:@"" forState:UIControlStateNormal];
    myButton.backgroundColor = [UIColor clearColor];
    myButton.frame = self.emailAvatarView.frame;
    myButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [myButton addTarget:self action:@selector(onAvatarBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:myButton];
    
    if ([self.message.type isEqualToString:@"course_invite"] && self.message.isSender) {
        __block NSString *receiversNames = @"";
        [self.message.receivers enumerateObjectsUsingBlock:^(User *user, NSUInteger idx, BOOL *stop) {
            receiversNames = [receiversNames stringByAppendingString:user.displayName];
            if (idx < self.message.receivers.count-1) {
                receiversNames = [receiversNames stringByAppendingString:@", "];
            }
        }];
        NSString *emailText = [NSString stringWithFormat:@"You have invited %@ to join the Course %@", receiversNames, self.message.inviteCourseName];
        self.emailTextLabel.text = emailText;
    } else {
        self.emailTextLabel.text = self.message.emailText;
    }
}

- (void)onAvatarBtnClick
{
    [CNNavigationHelper openProfileViewWithUser:self.message.sender];
    [self.delegate.revealController showViewController:self.delegate.revealController.frontViewController];
}

@end

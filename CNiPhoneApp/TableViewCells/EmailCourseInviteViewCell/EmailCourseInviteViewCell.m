//
//  EmailCourseInviteViewCell.m
//  CNiPhoneApp
//
//  Created by Manny on 4/3/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "EmailCourseInviteViewCell.h"
#import "CNNavigationHelper.h"
#import "PKRevealController.h"
#import "EmailStore.h"
#import "CourseStore.h"

#define EMAIL_TEXT_LABEL_WIDTH 200
#define EMAIL_TEXT_LABEL_HEIGHT 44

@implementation EmailCourseInviteViewCell

+ (CGFloat)heightOfCellWithEmailMessage:(EmailMessage *)message
{
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:@"Verdana" size:12.0f]};
    CGFloat textHeight = [message.emailText boundingRectWithSize:CGSizeMake(EMAIL_TEXT_LABEL_WIDTH, EMAIL_TEXT_LABEL_HEIGHT)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:attributes
                                                         context:nil].size.height;
    
    return MAX(66, textHeight + 90);
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
    
    NSString *emailText = [NSString stringWithFormat:@"%@ has invited you to join the Course %@.", self.message.sender.displayName, self.message.inviteCourseName];
    self.emailTextLabel.text = emailText;
}

- (void)onAvatarBtnClick
{
    [CNNavigationHelper openProfileViewWithUser:self.message.sender];
    [self.delegate.revealController showViewController:self.delegate.revealController.frontViewController];
}

- (IBAction)onAcceptBtnClick:(id)sender
{
    self.acceptBtn.enabled = NO;
    [CourseStore addUserToCourseByInvite:self.message.emailId courseId:self.message.inviteCourseId block:^(BOOL success, NSString *error) {
        if (success) {
            [EmailStore deleteEmail:self.message.emailId block:^(BOOL success, NSString *error) {
                if (success) {
                    self.message.isInviteAccepted = YES;
                    [self.delegate onCourseInviteRequestAccepted:self.message];
                } else {
                    // error deleting email
                }
                self.acceptBtn.enabled = YES;
            }];
        } else {
            // error joining course
        }
    }];
}

- (IBAction)onIgnoreBtnClick:(id)sender
{
    self.ignoreBtn.enabled = NO;
    [EmailStore deleteEmail:self.message.emailId block:^(BOOL success, NSString *error) {
        if (success) {
            self.message.isInviteIgnored = YES;
            [self.delegate onCourseInviteRequestIgnored:self.message];
        } else {
            // error deleting email
        }
        self.ignoreBtn.enabled = YES;
    }];
}

@end

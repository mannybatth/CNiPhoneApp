//
//  RequestViewCell.m
//  CNiPhoneApp
//
//  Created by Manny on 3/19/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "RequestViewCell.h"
#import "CNNavigationHelper.h"
#import "PKRevealController.h"
#import "ColleageRequestStore.h"

@implementation RequestViewCell

+ (CGFloat)heightOfCellWithColleageRequest:(ColleagueRequest *)request
{
    return 90;
}

- (void)awakeFromNib
{
    self.requestAvatarView.layer.masksToBounds = YES;
    self.requestAvatarView.layer.cornerRadius = 4;
}

- (void)setupViewForColleageRequest:(ColleagueRequest *)request
{
    self.request = request;
    
    self.requestUserNameLabel.text = self.request.user.displayName;
    self.requestDisplayDateLabel.text = self.request.displayTime;
    [self.requestAvatarView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", self.request.user.avatar]] placeholderImage:[UIImage imageNamed:@"default_profile.gif"]];
    
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [myButton setTitle:@"" forState:UIControlStateNormal];
    myButton.backgroundColor = [UIColor clearColor];
    myButton.frame = self.requestAvatarView.frame;
    myButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [myButton addTarget:self action:@selector(onAvatarBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:myButton];
}

- (void)onAvatarBtnClick
{
    [CNNavigationHelper openProfileViewWithUser:self.request.user];
    [self.delegate.revealController showViewController:self.delegate.revealController.frontViewController];
}

- (IBAction)onAcceptBtnClick:(id)sender
{
    self.acceptBtn.enabled = NO;
    [ColleageRequestStore setUserColleageRequestStatus:self.request.user.userId status:1 block:^(BOOL success, NSString *error) {
        if (success) {
            self.request.isAccepted = YES;
            [self.delegate onRequestAccepted:self.request];
        }
        self.acceptBtn.enabled = YES;
    }];
}

- (IBAction)onRejectBtnClick:(id)sender
{
    self.rejectBtn.enabled = NO;
    [ColleageRequestStore setUserColleageRequestStatus:self.request.user.userId status:0 block:^(BOOL success, NSString *error) {
        if (success) {
            self.request.isRejected = YES;
            [self.delegate onRequestRejected:self.request];
        }
        self.rejectBtn.enabled = YES;
    }];
}

@end

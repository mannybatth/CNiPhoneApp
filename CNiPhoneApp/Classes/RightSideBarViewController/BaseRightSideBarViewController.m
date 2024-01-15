//
//  BaseRightSideBarViewController.m
//  CNiPhoneApp
//
//  Created by Manny on 3/19/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "BaseRightSideBarViewController.h"
#import "PKRevealController.h"
#import "BaseRightSideBarNavigationController.h"
#import "BaseViewController.h"
#import "BadgeLabel.h"
#import "CNNavigationHelper.h"

@interface BaseRightSideBarViewController ()
{
    BaseRightSideBarNavigationController *baseNavigationController;
    
    BadgeLabel *notificationBadge;
    BadgeLabel *mailBadge;
    BadgeLabel *requestBadge;
}

@end

@implementation BaseRightSideBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    baseNavigationController = (BaseRightSideBarNavigationController*)self.navigationController;
    
    notificationArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_up"]];
    mailArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_up"]];
    requestArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_up"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"#2e3e52"]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationItem setHidesBackButton:YES];
    
    UIButton *notificationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [notificationBtn setImage:[UIImage imageNamed:@"notf_bell_icon"] forState:UIControlStateNormal];
    [notificationBtn setFrame:CGRectMake(0, 0, 40, 35)];
    [notificationBtn addTarget:self action:@selector(onNotificationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    notificationBadge = [[BadgeLabel alloc] init];
    notificationBadge.hideWhenZero = YES;
    notificationBadge.backgroundColor = [UIColor colorWithHexString:@"#e34639"];
    notificationBadge.font = [UIFont boldSystemFontOfSize:13];
    notificationBadge.point = CGPointMake(notificationBtn.center.x+10, notificationBtn.center.y-10);
    [notificationBtn addSubview:notificationBadge];
    
    notificationArrow.x = 13;
    notificationArrow.y = notificationBtn.height;
    [notificationBtn addSubview:notificationArrow];
    
    UIBarButtonItem *notificationBtnItem = [[UIBarButtonItem alloc] initWithCustomView:notificationBtn];
    
    UIButton *mailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [mailBtn setImage:[UIImage imageNamed:@"notf_mail_icon"] forState:UIControlStateNormal];
    [mailBtn setFrame:CGRectMake(0, 0, 40, 35)];
    [mailBtn addTarget:self action:@selector(onEmailBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    mailBadge = [[BadgeLabel alloc] init];
    mailBadge.hideWhenZero = YES;
    mailBadge.backgroundColor = [UIColor colorWithHexString:@"#e34639"];
    mailBadge.font = [UIFont boldSystemFontOfSize:13];
    mailBadge.point = CGPointMake(mailBtn.center.x+10, mailBtn.center.y-10);
    [mailBtn addSubview:mailBadge];
    
    mailArrow.x = 13;
    mailArrow.y = mailBtn.height;
    [mailBtn addSubview:mailArrow];
    
    UIBarButtonItem *mailBtnItem = [[UIBarButtonItem alloc] initWithCustomView:mailBtn];
    
    UIButton *requestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [requestBtn setImage:[UIImage imageNamed:@"notf_request_icon"] forState:UIControlStateNormal];
    [requestBtn setFrame:CGRectMake(0, 0, 40, 35)];
    [requestBtn addTarget:self action:@selector(onRequestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    requestBadge = [[BadgeLabel alloc] init];
    requestBadge.hideWhenZero = YES;
    requestBadge.backgroundColor = [UIColor colorWithHexString:@"#e34639"];
    requestBadge.font = [UIFont boldSystemFontOfSize:13];
    requestBadge.point = CGPointMake(requestBtn.center.x+10, requestBtn.center.y-10);
    [requestBtn addSubview:requestBadge];
    
    requestArrow.x = 13;
    requestArrow.y = requestBtn.height;
    [requestBtn addSubview:requestArrow];
    
    UIBarButtonItem *requestBtnItem = [[UIBarButtonItem alloc] initWithCustomView:requestBtn];
    
    [self.navigationItem setRightBarButtonItems:@[requestBtnItem, mailBtnItem, notificationBtnItem]];
    [self updateNavBtnBadges];
}

- (void)updateNavBtnBadges
{
    UserCount *count = [Session shared].currentUser.userCount;
    notificationBadge.text = [self formatNumber:count.newNotifications];
    mailBadge.text = [self formatNumber:count.newEmails];
    requestBadge.text = [self formatNumber:count.newColleagueRequests];
    if ([[CNNavigationHelper shared].navigationController.visibleViewController respondsToSelector:@selector(updateNavBtnBadges)]) {
        [(BaseViewController*)[CNNavigationHelper shared].navigationController.visibleViewController updateNavBtnBadges];
    }
}

- (NSString*)formatNumber:(int)x
{
    if (x >= 1000000000) return [NSString stringWithFormat:@"%iB", x/1000000000];
    else if (x >= 1000000) return [NSString stringWithFormat:@"%iM", x/1000000];
    else if (x >= 1000) return [NSString stringWithFormat:@"%ik", x/1000];
    else return [NSString stringWithFormat:@"%i", x];
}

- (void)onNotificationBtnClick:(id)sender
{
    [baseNavigationController popToRootViewControllerAnimated:NO];
    if (!baseNavigationController.notificationsViewController) {
        baseNavigationController.notificationsViewController = [[RightSideBarNotificationsViewController alloc] init];
    }
    if (![baseNavigationController.topViewController isKindOfClass:[RightSideBarNotificationsViewController class]])
        [baseNavigationController pushViewController:baseNavigationController.notificationsViewController animated:NO];
}

- (void)onEmailBtnClick:(id)sender
{
    [baseNavigationController popToRootViewControllerAnimated:NO];
    if (!baseNavigationController.emailsViewController) {
        baseNavigationController.emailsViewController = [[RightSideBarEmailsViewController alloc] init];
    }
    if (![baseNavigationController.topViewController isKindOfClass:[RightSideBarEmailsViewController class]])
        [baseNavigationController pushViewController:baseNavigationController.emailsViewController animated:NO];
}

- (void)onRequestBtnClick:(id)sender
{
    [baseNavigationController popToRootViewControllerAnimated:NO];
    if (!baseNavigationController.requestsViewController) {
        baseNavigationController.requestsViewController = [[RightSideBarRequestsViewController alloc] init];
    }
    if (![baseNavigationController.topViewController isKindOfClass:[RightSideBarRequestsViewController class]])
        [baseNavigationController pushViewController:baseNavigationController.requestsViewController animated:NO];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

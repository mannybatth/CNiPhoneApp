//
//  BaseViewController.m
//  CNApp
//
//  Created by Manpreet Singh on 6/27/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "BaseViewController.h"
#import "WebViewController.h"
#import "Session.h"
#import "BadgeLabel.h"

@interface BaseViewController ()
{
    BadgeLabel *notificationBadge;
}

@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.revealController.recognizesPanningOnFrontView = YES;
    
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIColor whiteColor], NSForegroundColorAttributeName,
                                      nil];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:textTitleOptions];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationItem.rightBarButtonItem = nil;
    
    UIImage *backBtnImage;
    if (showHomeBtn) {
        [self.navigationItem setHidesBackButton:YES animated:NO];
        self.navigationItem.leftBarButtonItem = nil;
        backBtnImage = [UIImage imageNamed:@"nav_home_btn"];
        
        CGRect backBtnImageFrame = CGRectMake(0, 0, backBtnImage.size.width, backBtnImage.size.height);
        UIButton *backBtn = [[UIButton alloc] initWithFrame:backBtnImageFrame];
        [backBtn setImage:backBtnImage forState:UIControlStateNormal];
        [backBtn setTitle:nil forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(onBackBtnClick) forControlEvents:UIControlEventTouchUpInside];
        backBtn.showsTouchWhenHighlighted = !showHomeBtn;
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -16, 0, 0)];
        UIBarButtonItem *backBtnItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        self.navigationItem.leftBarButtonItem = backBtnItem;
    }
    
    self.navigationItem.rightBarButtonItem = nil;
    UIImage *rightBtnImage = [UIImage imageNamed:@"navBarRightBtn"];
    CGRect rightBtnImageFrame = CGRectMake(0, 0, rightBtnImage.size.width, rightBtnImage.size.height);
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:rightBtnImageFrame];
    [rightBtn setImage:rightBtnImage forState:UIControlStateNormal];
    [rightBtn setTitle:nil forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(onRightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    notificationBadge = [[BadgeLabel alloc] init];
    notificationBadge.hideWhenZero = YES;
    notificationBadge.backgroundColor = [UIColor colorWithHexString:@"#e34639"];
    notificationBadge.font = [UIFont boldSystemFontOfSize:13];
    notificationBadge.point = CGPointMake(0, 0);
    [rightBtn addSubview:notificationBadge];
    
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    
    [self updateNavBtnBadges];
}

- (void)updateNavBtnBadges
{
    UserCount *count = [Session shared].currentUser.userCount;
    notificationBadge.text = [self formatNumber:count.newNotifications+count.newEmails+count.newColleagueRequests];
}

- (NSString*)formatNumber:(int)x
{
    if (x >= 1000000000) return [NSString stringWithFormat:@"%iB", x/1000000000];
    else if (x >= 1000000) return [NSString stringWithFormat:@"%iM", x/1000000];
    else if (x >= 1000) return [NSString stringWithFormat:@"%ik", x/1000];
    else return [NSString stringWithFormat:@"%i", x];
}

- (void)onBackBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onRightBtnClick
{
    [self showRightView:self];
}

- (void)showLeftView:(id)sender
{
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.leftViewController)
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    }
    else
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
    }
}

- (void)showRightView:(id)sender
{
    if (self.navigationController.revealController.focusedController == self.navigationController.revealController.rightViewController)
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.frontViewController];
    }
    else
    {
        [self.navigationController.revealController showViewController:self.navigationController.revealController.rightViewController];
    }
}

- (void)processRTLabelLinkBtnClick:(RTLabelButton *)button
{
    if ([[button.attributes objectForKey:@"data-type"] isEqualToString:@"outside_link"]) {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:button.url];
        
        if ([request.URL.scheme isEqualToString:@"tel"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Call"
                                                            message:@"Do you want to call this number?"
                                                   cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel" action:nil]
                                                   otherButtonItems:[RIButtonItem itemWithLabel:@"Call" action:^{
                [[UIApplication sharedApplication] openURL:request.URL];
            }], nil];
            [alert show];
            
        } else if ([request.URL.scheme isEqualToString:@"mailto"]) {
            
            [[UIApplication sharedApplication] openURL:request.URL];
            
        } else {
            
            if ([request.URL.host isEqualToString:@"connect.iu.edu"]) {
                
                UIApplication *ourApplication = [UIApplication sharedApplication];
                NSString *URLEncodedText = [request.URL.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *ourPath = [@"connectpro://" stringByAppendingString:URLEncodedText];
                NSURL *ourURL = [NSURL URLWithString:ourPath];
                if ([ourApplication canOpenURL:ourURL]) {
                    [ourApplication openURL:ourURL];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Adobe Connect"
                                          message:@"Need to install Adobe Connect Mobile app for this link to work.\n Note: Some Adobe Connect links may not work."
                                          cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel" action:nil]
                                          otherButtonItems:[RIButtonItem itemWithLabel:@"Install" action:^{
                        
                        NSString *appUrl = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%i", ADOBE_CONNECT_APP_STORE_ID];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appUrl]];
                        
                    }], nil];
                    [alert show];
                }
                
            } else {
                WebViewController *webViewController = [[WebViewController alloc] initWithURL:request.URL];
                [self.navigationController pushViewController:webViewController animated:YES];
            }
        }
        
    } else if ([[button.attributes objectForKey:@"data-type"] isEqualToString:@"cn_number"]) {
        User *user = [[User alloc] init];
        user.CNNumber = [button.attributes objectForKey:@"data-id"];
        [CNNavigationHelper openProfileViewWithUser:user];
    }
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

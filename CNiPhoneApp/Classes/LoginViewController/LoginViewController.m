//
//  LoginViewController.m
//  CNiPhoneApp
//
//  Created by Manny on 2/18/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginStore.h"
#import "UserStore.h"
#import "CourseStore.h"
#import "ConexusStore.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "UIView+GCLibrary.h"
#import "MBProgressHUD.h"
#import "TSMessage.h"
#import "HomeViewController.h"

@interface LoginViewController () <UITextFieldDelegate>
{
    BOOL isLoading;
    BOOL isAnimating;
    
    CGRect largeLogoFrame;
}

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    largeLogoFrame = self.largeLogo.frame;
    
    // Go to Home if already logged in
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([Session shared].currentToken) {
            HomeViewController *homeViewController = [[HomeViewController alloc] init];
            CATransition *transition = [CATransition animation];
            transition.duration = 0.3f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            [self.navigationController.view.layer addAnimation:transition forKey:nil];
            [self.navigationController pushViewController:homeViewController animated:NO];
        }
    });
    
    // add selector to loginBtn
    [self.loginBtn addTarget:self action:@selector(tryToLogin) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.revealController.recognizesPanningOnFrontView = NO;
    
    // Prepare view if not logged in
    if (![Session shared].currentToken) {
        
        // Animate Logo
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [UIView animateWithDuration:0.8 delay:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.largeLogo.frame = [self.smallLogo.superview convertRect:self.smallLogo.frame toView:nil];
            } completion:^(BOOL finished) {
                self.masterScrollView.hidden = NO;
                [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveLinear animations:^{
                    self.masterScrollView.layer.opacity = 1;
                } completion:^(BOOL finished) {
                    self.smallLogo.hidden = NO;
                    self.largeLogo.hidden = YES;
                    self.masterScrollView.userInteractionEnabled = YES;
                }];
            }];
            
        });
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Hide navigationBar
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationItem.title = @"";
    
    // Fix for scrollview not showing under statusBar
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // Clear password field
    self.passwordTextField.text = nil;
    
    // reset views
    self.masterScrollView.hidden = YES;
    self.masterScrollView.layer.opacity = 0;
    self.smallLogo.hidden = YES;
    self.largeLogo.hidden = NO;
    self.largeLogo.frame = largeLogoFrame;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Update position of scrollView
    if (self.view.bounds.size.height > 480) {
        [self.masterScrollView setCalculatedContentPadding:50];
    } else {
        [self.masterScrollView setCalculatedContentPadding:10];
    }
    [self.masterScrollView contentSizeToFit];
    [self.masterScrollView scrollToActiveTextFieldWithDuration:0.0f];
}

- (void)resignTextView
{
	[self.usernameTextField resignFirstResponder];
	[self.passwordTextField resignFirstResponder];
}

- (void)tryToLogin
{
    if (isLoading == YES) return;
    isLoading = YES;
    
    // Check for text in fields
    if ([self.usernameTextField.text length] == 0 || [self.passwordTextField.text length] == 0) {
        isLoading = NO;
        return;
    }
    
    [self doLogin];
}

- (void)doLogin
{
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    [self resignTextView];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [LoginStore login:username password:password block:^(id response, NSString *error) {
        if (error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            isLoading = NO;
            [self handleErrorMsg:response];
            return;
        }
        
        [Session setUserToken:response];
        [UserStore getMe:^(User *user, NSString *error) {
            if (error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                isLoading = NO;
                return;
            }
            
            [Session shared].currentUser = user;
            [UserStore getUserCourseConexusTab:^(NSArray *content, NSString *error) {
                
                if (error) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    isLoading = NO;
                    return;
                }
                
                NSMutableArray *courses = [NSMutableArray new];
                NSMutableArray *conexuses = [NSMutableArray new];
                [content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    if ([obj isKindOfClass:[Course class]]) {
                        [courses addObject:obj];
                        
                    } else if ([obj isKindOfClass:[Conexus class]]) {
                        [conexuses addObject:obj];
                        
                    }
                }];
                
                [Session shared].currentUserCourses = courses;
                [Session shared].currentUserConexus = conexuses;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTF_REFRESH_LEFT_BAR object:nil];
                
                if (!isAnimating) {
                    isAnimating = YES;
                    HomeViewController *homeViewController = [[HomeViewController alloc] init];
                    CATransition *transition = [CATransition animation];
                    transition.duration = 0.3f;
                    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    transition.type = kCATransitionFade;
                    [self.navigationController.view.layer addAnimation:transition forKey:nil];
                    [self.navigationController pushViewController:homeViewController animated:NO];
                    isAnimating = NO;
                    isLoading = NO;
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }
                
            }];
        }];
    }];
}

- (void)handleErrorMsg:(id)response
{
    NSString *msg = @"";
    if ([[response objectForKey:@"errors"] isKindOfClass:[NSArray class]]) {
        NSArray *errors = [response objectForKey:@"errors"];
        if (errors.count > 0) msg = [errors objectAtIndex:0];
        
    } else if ([[response objectForKey:@"errors"] isKindOfClass:[NSString class]]) {
        msg = [response objectForKey:@"errors"];
    }
    
    [TSMessage showNotificationInViewController:self
                                          title:@"Login Error"
                                       subtitle:msg
                                           type:TSMessageNotificationTypeError];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1) {   // Go button was clicked
        [textField resignFirstResponder];
        [self tryToLogin];
    } else {                    // Next button was clicked
        [self.passwordTextField becomeFirstResponder];
    }
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

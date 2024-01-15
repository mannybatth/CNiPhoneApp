//
//  LogoutViewController.m
//  CNApp
//
//  Created by Manpreet Singh on 7/3/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "LogoutViewController.h"
#import "HomeViewController.h"
#import "BaseStore.h"
#import "Session.h"

@interface LogoutViewController ()

@end

@implementation LogoutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:62.0f/255.0f blue:124.0f/255.0f alpha:1.0f]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Hide navigationBar
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.navigationItem.title = @"";
    
    self.navigationController.revealController.recognizesPanningOnFrontView = NO;
    
    [self clearData];
    [self logout];
}

- (void)logout
{
    NSLog(@"logging out");
    
    if ([Session shared].currentToken) {
        [BaseStore api:@"/auth?action=logout" completionBlock:^(id response, NSString *error) {
            [Session shared].currentToken = nil;
            [self.navigationController popToRootViewControllerAnimated:NO];
        }];
    } else {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
}

- (void)clearData
{
    NSLog(@"clearing Data");
    [[CNHTTPClient sharedClient].operationQueue cancelAllOperations];
    [Session shared].currentUser = nil;
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"currentToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[EGOCache globalCache] clearCache];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
}

@end

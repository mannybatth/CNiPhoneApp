//
//  CNNavigationController.m
//  CNApp
//
//  Created by Manpreet Singh on 6/28/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "CNNavigationController.h"
#import "Session.h"
#import "UserStore.h"
#import "BaseViewController.h"
#import "LogoutViewController.h"
#import "BaseRightSideBarNavigationController.h"

@interface CNNavigationController ()
{
    NSTimer *repeatTimer;
    BOOL error401Received;
}

@end

@implementation CNNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(HTTPOperationDidFinish:)
                                                 name:AFNetworkingOperationDidFinishNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillBecomeResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [self startTimer];
    [self setNeedsStatusBarAppearanceUpdate];
    
    //self.navigationBar.tintColor = [UIColor colorWithRed:169.0f/255.0f green:6.0f/255.0f blue:38.0f/255.0f alpha:1];
}

- (void)appDidBecomeActive:(NSNotification*)notification
{
    [self checkForNewNotifications];
    
    // get user courses, & conexus
    if ([Session shared].currentToken != nil) {
        [UserStore getUserCourseConexusTab:^(NSArray *content, NSString *error) {
           
            if (!error) {
                
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
                
            }
            
        }];
    }
    
    [self startTimer];
}

- (void)appWillBecomeResignActive:(NSNotification*)notification
{
    [self stopTimer];
}

- (void)startTimer
{
    if (repeatTimer == nil && [Session shared].timerStarted == NO)
    {
        [Session shared].timerStarted = YES;
        repeatTimer = [NSTimer scheduledTimerWithTimeInterval:20.0f
                                                       target:self
                                                     selector:@selector(checkForNewNotifications)
                                                     userInfo:nil
                                                      repeats:YES];
    }
}

- (void)stopTimer
{
    if (repeatTimer != nil)
    {
        [Session shared].timerStarted = NO;
        [repeatTimer invalidate];
        repeatTimer = nil;
    }
}

- (void)checkForNewNotifications
{
    if ([Session shared].currentToken != nil) {
        [UserStore getMe:^(User *user, NSString *error) {
            if (!error) {
                [Session shared].currentUser = user;
                [self updateNotificationContent];
            }
        }];
    }
}

- (void)updateNotificationContent
{
    if ([self.visibleViewController respondsToSelector:@selector(updateNavBtnBadges)]) {
        [(BaseViewController*)self.visibleViewController updateNavBtnBadges];
    }
    if ([((BaseRightSideBarNavigationController*)self.revealController.rightViewController).visibleViewController respondsToSelector:@selector(updateNavBtnBadges)]) {
        [(BaseRightSideBarViewController*)((BaseRightSideBarNavigationController*)self.revealController.rightViewController).visibleViewController updateNavBtnBadges];
    }
}

- (void)HTTPOperationDidFinish:(NSNotification*)notification
{
//    AFHTTPRequestOperation *operation = (AFHTTPRequestOperation *)[notification object];
//    
//    if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
//        return;
//    }
//    
//    if ([operation.response statusCode] == 401 || [operation.response statusCode] == 403) {
//        
//        NSLog(@"RECEIVED %i ERROR", [operation.response statusCode]);
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:AFNetworkingOperationDidFinishNotification
//                                                      object:nil];
//        if (error401Received == NO) {
//            error401Received = YES;
//            [self.revealController showViewController:self.revealController.frontViewController animated:NO completion:^(BOOL finished) {
//                
//                LogoutViewController *logoutViewController = [[LogoutViewController alloc] init];
//                [logoutViewController clearData];
//                
//                [UIView animateWithDuration:0.95 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                    
//                    [self pushViewController:logoutViewController animated:NO];
//                    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.revealController.frontViewController.view cache:NO];
//                    
//                } completion:^(BOOL finished) {
//                    
//                    [logoutViewController logout];
//                    double delayInSeconds = 2.0;
//                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                        error401Received = NO;
//                        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                                 selector:@selector(HTTPOperationDidFinish:)
//                                                                     name:AFNetworkingOperationDidFinishNotification
//                                                                   object:nil];
//                    });
//                    
//                }];
//                
//            }];
//        }
//    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

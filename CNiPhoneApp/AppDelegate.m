//
//  AppDelegate.m
//  CNiPhoneApp
//
//  Created by Manny on 2/7/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "AppDelegate.h"
#import "PKRevealController.h"
#import "CNNavigationController.h"
#import "BaseRightSideBarNavigationController.h"
#import "LoginViewController.h"
#import "LeftSideBarViewController.h"
#import "RightSideBarNotificationsViewController.h"
#import "Session.h"
#import "CNNavigationHelper.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "TestFlight.h"
//#import <Crashlytics/Crashlytics.h>

@interface AppDelegate() <PKRevealing>

#pragma mark - Properties
@property (nonatomic, strong, readwrite) PKRevealController *revealController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"a680f004-3408-4354-9cc9-b7de78f62ac6"];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
//    [Crashlytics startWithAPIKey:@"c305266f58c90b93f9951b8bdd1425d1c324df30"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    
    // Step 1: Create your controllers.
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    LeftSideBarViewController *leftViewController = [[LeftSideBarViewController alloc] init];
    RightSideBarNotificationsViewController *notificationViewController = [[RightSideBarNotificationsViewController alloc] init];
    BaseRightSideBarNavigationController *rightViewController = [[BaseRightSideBarNavigationController alloc] initWithRootViewController:notificationViewController];
    CNNavigationController *frontNavigationController = [[CNNavigationController alloc] initWithRootViewController:loginViewController];
    [CNNavigationHelper shared].navigationController = frontNavigationController;
    rightViewController.notificationsViewController = notificationViewController;
    
    // Step 2: Instantiate.
    self.revealController = [PKRevealController revealControllerWithFrontViewController:frontNavigationController
                                                                     leftViewController:leftViewController
                                                                    rightViewController:rightViewController];
    
    // Step 3: Configure.
    self.revealController.delegate = self;
    self.revealController.animationDuration = 0.25;
    self.revealController.quickSwipeVelocity = 800;
    self.revealController.animationCurve = UIViewAnimationCurveLinear;
    [self.revealController setMinimumWidth:255.0f maximumWidth:255.0f forViewController:leftViewController];
    [self.revealController setMinimumWidth:270.0f maximumWidth:270.0f forViewController:rightViewController];
    
    // Step 4: Apply.
    self.window.rootViewController = self.revealController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - PKRevealing

- (void)revealController:(PKRevealController *)revealController didChangeToState:(PKRevealControllerState)state
{
    NSLog(@"%@ (%d)", NSStringFromSelector(_cmd), (int)state);
}

- (void)revealController:(PKRevealController *)revealController willChangeToState:(PKRevealControllerState)next
{
    PKRevealControllerState current = revealController.state;
    NSLog(@"%@ (%d -> %d)", NSStringFromSelector(_cmd), (int)current, (int)next);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
    [[NSUserDefaults standardUserDefaults] setValue:[Session shared].currentToken forKey:@"currentToken"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
    [Session shared].currentToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"currentToken"];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground.
    NSLog(@"applicationWillTerminate");
    [[NSUserDefaults standardUserDefaults] setValue:[Session shared].currentToken forKey:@"currentToken"];
}

@end

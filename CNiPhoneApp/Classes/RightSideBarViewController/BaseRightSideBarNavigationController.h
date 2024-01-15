//
//  BaseRightSideBarNavigationController.h
//  CNiPhoneApp
//
//  Created by Manny on 3/19/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "BaseNavigationController.h"
#import "RightSideBarNotificationsViewController.h"
#import "RightSideBarEmailsViewController.h"
#import "RightSideBarRequestsViewController.h"

@interface BaseRightSideBarNavigationController : BaseNavigationController

@property (strong, nonatomic) RightSideBarNotificationsViewController *notificationsViewController;
@property (strong, nonatomic) RightSideBarEmailsViewController *emailsViewController;
@property (strong, nonatomic) RightSideBarRequestsViewController *requestsViewController;

@end

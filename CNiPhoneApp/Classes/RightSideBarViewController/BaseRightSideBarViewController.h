//
//  BaseRightSideBarViewController.h
//  CNiPhoneApp
//
//  Created by Manny on 3/19/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "UIViewController+PKRevealController.h"
#import "PKRevealController.h"
#import "UITableViewLoadingFooter.h"
#import "UIView+GCLibrary.h"
#import "Session.h"
#import "CNNavigationHelper.h"

@interface BaseRightSideBarViewController : UIViewController
{
    UIImageView *notificationArrow;
    UIImageView *mailArrow;
    UIImageView *requestArrow;
}

- (void)updateNavBtnBadges;

@end

//
//  BaseViewController.h
//  CNApp
//
//  Created by Manpreet Singh on 6/27/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#define NAV_POPUP_WIDTH 300

#import "PKRevealController.h"
#import "CNNavigationHelper.h"
#import "CNNavigationController.h"
#import "NSString+Trim.h"
#import "UIAlertView+Blocks.h"
#import "UIView+GCLibrary.h"
#import "UIViewController+PKRevealController.h"
#import "UITableViewLoadingFooter.h"
#import "RTLabel.h"

@interface BaseViewController : UIViewController
{
    BOOL showHomeBtn;
}

- (void)onBackBtnClick;
- (void)showLeftView:(id)sender;
- (void)showRightView:(id)sender;

- (void)processRTLabelLinkBtnClick:(RTLabelButton*)button;
- (void)updateNavBtnBadges;

@end

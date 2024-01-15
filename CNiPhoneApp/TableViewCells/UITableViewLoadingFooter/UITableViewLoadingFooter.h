//
//  UITableViewLoadingFooter.h
//  CNiPhoneApp
//
//  Created by Manny on 2/20/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewLoadingFooter : UIView

@property (nonatomic, strong) UIView *view;

- (void)startLoading;
- (void)stopLoading;

@end

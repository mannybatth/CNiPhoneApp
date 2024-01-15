//
//  LoginViewController.h
//  CNiPhoneApp
//
//  Created by Manny on 2/18/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TPKeyboardAvoidingScrollView;

@interface LoginViewController : UIViewController

@property (nonatomic, strong) IBOutlet TPKeyboardAvoidingScrollView *masterScrollView;
@property (nonatomic, strong) IBOutlet UIView *formContainerView;
@property (nonatomic, strong) IBOutlet UITextField *usernameTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UIButton *loginBtn;

@property (nonatomic, strong) IBOutlet UIImageView *smallLogo;
@property (nonatomic, strong) IBOutlet UIImageView *largeLogo;

@end

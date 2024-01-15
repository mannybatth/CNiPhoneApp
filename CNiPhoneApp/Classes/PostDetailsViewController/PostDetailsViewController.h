//
//  PostDetailsViewController.h
//  CNiPhoneApp
//
//  Created by Manny on 2/22/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "BaseViewController.h"

@interface PostDetailsViewController : BaseViewController

@property (nonatomic, strong) Post *post;
@property (nonatomic) BOOL focusReflectionTextViewOnLoad;

- (void)focusReflectionTextView;

@end

//
//  EmailDetailsViewController.h
//  CNiPhoneApp
//
//  Created by Manny on 3/21/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "BaseViewController.h"

@interface EmailDetailsViewController : BaseViewController

@property (nonatomic, strong) NSString *parentId;
@property (nonatomic) BOOL focusMessageTextViewOnLoad;

- (void)focusMessageTextView;

@end

//
//  ShowPreviousCommentsCell.h
//  CNiPhoneApp
//
//  Created by Manny on 3/4/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowPreviousCommentsCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *showReflectionsLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicatorView;

- (void)startLoading;
- (void)stopLoading;

@end

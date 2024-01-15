//
//  ShowPreviousMessagesCell.h
//  CNiPhoneApp
//
//  Created by Manny on 3/4/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowPreviousMessagesCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *showMesssagesLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicatorView;

- (void)startLoading;
- (void)stopLoading;

@end

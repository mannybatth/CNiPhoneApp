//
//  ShowPreviousMessagesCell.m
//  CNiPhoneApp
//
//  Created by Manny on 3/4/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "ShowPreviousMessagesCell.h"

@implementation ShowPreviousMessagesCell

- (void)startLoading
{
    [self.indicatorView startAnimating];
    self.showMesssagesLabel.hidden = YES;
}

- (void)stopLoading
{
    [self.indicatorView stopAnimating];
    self.showMesssagesLabel.hidden = NO;
}

@end

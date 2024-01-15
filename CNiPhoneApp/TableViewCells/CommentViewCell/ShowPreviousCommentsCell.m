//
//  ShowPreviousCommentsCell.m
//  CNiPhoneApp
//
//  Created by Manny on 3/4/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "ShowPreviousCommentsCell.h"

@implementation ShowPreviousCommentsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)startLoading
{
    [self.indicatorView startAnimating];
    self.showReflectionsLabel.hidden = YES;
}

- (void)stopLoading
{
    [self.indicatorView stopAnimating];
    self.showReflectionsLabel.hidden = NO;
}

@end

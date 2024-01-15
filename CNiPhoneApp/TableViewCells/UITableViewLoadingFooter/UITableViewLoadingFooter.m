//
//  UITableViewLoadingFooter.m
//  CNiPhoneApp
//
//  Created by Manny on 2/20/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "UITableViewLoadingFooter.h"

@interface UITableViewLoadingFooter()

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation UITableViewLoadingFooter

- (void)awakeFromNib
{
    self.view = [[[NSBundle mainBundle] loadNibNamed:@"UITableViewLoadingFooter" owner:self options:nil] objectAtIndex:0];
    self.view.frame = CGRectMake(self.view.frame.origin.x,
                                 self.view.frame.origin.x,
                                 self.frame.size.width,
                                 self.view.frame.size.height);
    [self addSubview:self.view];
    [self stopLoading];
}

- (void)startLoading
{
    [self.indicatorView startAnimating];
}

- (void)stopLoading
{
    [self.indicatorView stopAnimating];
}

@end

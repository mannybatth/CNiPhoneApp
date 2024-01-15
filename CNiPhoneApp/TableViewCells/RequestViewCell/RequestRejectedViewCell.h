//
//  RequestRejectedViewCell.h
//  CNiPhoneApp
//
//  Created by Manny on 4/3/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "ColleagueRequest.h"

@interface RequestRejectedViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *rejectedLabel;

+ (CGFloat)heightOfCellWithColleageRequest:(ColleagueRequest *)request;
- (void)setupViewForColleageRequest:(ColleagueRequest *)request;

@end

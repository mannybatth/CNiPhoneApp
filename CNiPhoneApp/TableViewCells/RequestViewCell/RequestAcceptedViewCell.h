//
//  RequestAcceptedViewCell.h
//  CNiPhoneApp
//
//  Created by Manny on 4/3/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "ColleagueRequest.h"

@interface RequestAcceptedViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *acceptedLabel;

+ (CGFloat)heightOfCellWithColleageRequest:(ColleagueRequest *)request;
- (void)setupViewForColleageRequest:(ColleagueRequest *)request;

@end

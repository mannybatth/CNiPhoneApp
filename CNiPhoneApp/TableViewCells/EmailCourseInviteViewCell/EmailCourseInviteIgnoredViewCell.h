//
//  EmailCourseInviteIgnoredViewCell.h
//  CNiPhoneApp
//
//  Created by Manny on 4/3/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "EmailMessage.h"

@interface EmailCourseInviteIgnoredViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *rejectedLabel;

+ (CGFloat)heightOfCellWithEmailMessage:(EmailMessage *)message;
- (void)setupViewForEmailMessage:(EmailMessage *)message;

@end

//
//  EmailViewCell.h
//  CNiPhoneApp
//
//  Created by Manny on 3/19/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "EmailMessage.h"

@protocol EmailViewCellDelegate <NSObject>
@end

@interface EmailViewCell : UITableViewCell

@property (nonatomic, weak) UIViewController<EmailViewCellDelegate> *delegate;

@property (nonatomic, strong) EmailMessage *message;

@property (nonatomic, strong) IBOutlet UIImageView *emailAvatarView;
@property (nonatomic, strong) IBOutlet UILabel *emailUserNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *emailDisplayDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *emailTextLabel;

+ (CGFloat)heightOfCellWithEmailMessage:(EmailMessage *)message;
- (void)setupViewForEmailMessage:(EmailMessage *)message;

@end

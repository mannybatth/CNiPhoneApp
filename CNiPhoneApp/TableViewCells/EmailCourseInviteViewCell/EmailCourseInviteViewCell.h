//
//  EmailCourseInviteViewCell.h
//  CNiPhoneApp
//
//  Created by Manny on 4/3/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "EmailMessage.h"
#import "BButton.h"

@protocol EmailCourseInviteViewCell <NSObject>

@optional
- (void)onCourseInviteRequestAccepted:(EmailMessage *)message;
- (void)onCourseInviteRequestIgnored:(EmailMessage *)message;

@end

@interface EmailCourseInviteViewCell : UITableViewCell

@property (nonatomic, weak) UIViewController<EmailCourseInviteViewCell> *delegate;

@property (nonatomic, strong) EmailMessage *message;

@property (nonatomic, strong) IBOutlet UIImageView *emailAvatarView;
@property (nonatomic, strong) IBOutlet UILabel *emailUserNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *emailDisplayDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *emailTextLabel;

@property (nonatomic, strong) IBOutlet BButton *acceptBtn;
@property (nonatomic, strong) IBOutlet BButton *ignoreBtn;

+ (CGFloat)heightOfCellWithEmailMessage:(EmailMessage *)message;
- (void)setupViewForEmailMessage:(EmailMessage *)message;

@end

//
//  EmailDetailsViewCell.h
//  CNiPhoneApp
//
//  Created by Manny on 3/21/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "EmailMessage.h"
#import "RTLabel.h"

@protocol EmailMessageViewCellDelegate <NSObject>

@optional
- (void)processRTLabelLinkBtnClick:(RTLabelButton *)button;

@end

@interface EmailDetailsViewCell : UITableViewCell

@property (nonatomic, strong) EmailMessage *message;

@property (nonatomic, weak) UIViewController<EmailMessageViewCellDelegate> *delegate;

@property (nonatomic, strong) IBOutlet UIImageView *messageAvatar;
@property (nonatomic, strong) IBOutlet UIButton *messageUsername;
@property (nonatomic, strong) IBOutlet UILabel *messageCNNumber;
@property (nonatomic, strong) IBOutlet UILabel *messageDisplayDate;
@property (nonatomic, strong) IBOutlet RTLabel *messageContent;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageContentViewHeight;

+ (CGFloat)heightOfCellWithEmailMessage:(EmailMessage *)message;
- (void)setupViewForEmailMessage:(EmailMessage *)message;

@end

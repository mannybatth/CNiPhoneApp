//
//  EmailDetailsViewCell.m
//  CNiPhoneApp
//
//  Created by Manny on 3/21/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "EmailDetailsViewCell.h"
#import "CNNavigationHelper.h"

@interface EmailDetailsViewCell() <RTLabelDelegate>
@end

@implementation EmailDetailsViewCell

+ (RTLabel*)emailMessageRTLabel
{
	RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectMake(0, 0, 310, 0)];
	[label setFont:[UIFont fontWithName:@"Verdana" size:12.0]];
    label.lineSpacing = 0.0;
	return label;
}

+ (CGFloat)heightOfCellWithEmailMessage:(EmailMessage *)message
{
    CGFloat cellHeight = 0;
    
    if (!message.messageContentHeight) {
        RTLabel *rtLabel = [EmailDetailsViewCell emailMessageRTLabel];
        rtLabel.maxHeight = MAXFLOAT;
        [rtLabel setText:message.emailRawText];
        message.messageContentHeight = [rtLabel optimumSize].height+5;
    }
    
    cellHeight += message.messageContentHeight;
    cellHeight += 70;
    
    return cellHeight;
}

- (void)awakeFromNib
{
    self.messageAvatar.layer.masksToBounds = YES;
    self.messageAvatar.layer.cornerRadius = 4;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.messageContent.delegate = self;
    [self.messageContent setFont:[UIFont fontWithName:@"Verdana" size:12.0]];
    self.messageContent.lineSpacing = 0.0;
}

- (void)setupViewForEmailMessage:(EmailMessage *)message
{
    self.message = message;
    
    [self.messageAvatar setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", self.message.sender.avatar]]
                       placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
    
    [self.messageUsername setTitle:self.message.sender.displayName forState:UIControlStateNormal];
    self.messageCNNumber.text = [NSString stringWithFormat:@"%@", self.message.sender.CNNumber];
    self.messageDisplayDate.text = self.message.displayTime;
    
    [self setupContentLabel];
}

- (void)setupContentLabel
{
    self.messageContent.maxHeight = MAXFLOAT;
    
    [self.messageContent setText:self.message.emailRawText];
    
    if (!self.message.messageContentHeight) {
        self.message.messageContentHeight = [self.messageContent optimumSize].height+5;
    }
    self.messageContentViewHeight.constant = self.message.messageContentHeight;
}

- (IBAction)onAvatarBtnClick:(id)sender
{
    [CNNavigationHelper openProfileViewWithUser:self.message.sender];
}

- (IBAction)onUserNameBtnClick:(id)sender
{
    [CNNavigationHelper openProfileViewWithUser:self.message.sender];
}

#pragma mark -
#pragma mark RTLabel delegate

- (void)rtLabel:(id)rtLabel didSelectLinkWithButton:(RTLabelButton *)button
{
    if ([self.delegate respondsToSelector:@selector(processRTLabelLinkBtnClick:)]) {
        [self.delegate processRTLabelLinkBtnClick:button];
    }
}

@end

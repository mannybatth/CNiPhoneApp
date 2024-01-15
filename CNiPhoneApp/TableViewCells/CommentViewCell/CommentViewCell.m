//
//  CommentViewCell.m
//  CNiPhoneApp
//
//  Created by Manny on 2/24/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "CommentViewCell.h"
#import "CNNavigationHelper.h"

@interface CommentViewCell()  <RTLabelDelegate>

@end

@implementation CommentViewCell

+ (RTLabel*)commentRTLabel
{
	RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectMake(0, 0, 307, 0)];
	[label setFont:[UIFont fontWithName:@"Verdana" size:12.0]];
    label.lineSpacing = 0.0;
	return label;
}

+ (CGFloat)heightOfCellWithComment:(Comment *)comment
{
    CGFloat cellHeight = 0;
    
    if (!comment.commentContentHeight) {
        RTLabel *rtLabel = [CommentViewCell commentRTLabel];
        rtLabel.maxHeight = MAXFLOAT;
        [rtLabel setText:comment.text];
        comment.commentContentHeight = [rtLabel optimumSize].height+5;
    }
    
    cellHeight += comment.commentContentHeight;
    
    cellHeight += 70;
    
    return cellHeight;
}

- (void)awakeFromNib
{
    self.commentAvatar.layer.masksToBounds = YES;
    self.commentAvatar.layer.cornerRadius = 4;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.commentContent.delegate = self;
    [self.commentContent setFont:[UIFont fontWithName:@"Verdana" size:12.0]];
    self.commentContent.lineSpacing = 0.0;
}

- (void)setupViewForComment:(Comment *)comment
{
    self.comment = comment;
    [self setupView];
}

- (void)setupView
{
    [self.commentAvatar setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", self.comment.user.avatar]]
                       placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
    
    [self.commentUsername setTitle:self.comment.user.displayName forState:UIControlStateNormal];
    self.commentCNNumber.text = [NSString stringWithFormat:@"%@", self.comment.user.CNNumber];
    self.commentDisplayDate.text = self.comment.displayTime;
    
    [self setupContentLabel];
}

- (void)setupContentLabel
{
    self.commentContent.maxHeight = MAXFLOAT;
    
    [self.commentContent setText:self.comment.text];
    
    if (!self.comment.commentContentHeight) {
        self.comment.commentContentHeight = [self.commentContent optimumSize].height+5;
    }
    self.commentContentViewHeight.constant = self.comment.commentContentHeight;
}

- (IBAction)onAvatarBtnClick:(id)sender
{
    //if (!self.comment.isFromAdmin) {
        [CNNavigationHelper openProfileViewWithUser:self.comment.user];
    //}
}

- (IBAction)onUserNameBtnClick:(id)sender
{
    //if (!self.comment.isFromAdmin) {
        [CNNavigationHelper openProfileViewWithUser:self.comment.user];
    //}
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

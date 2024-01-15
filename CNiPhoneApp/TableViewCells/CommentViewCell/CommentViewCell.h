//
//  CommentViewCell.h
//  CNiPhoneApp
//
//  Created by Manny on 2/24/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "PostStore.h"
#import "RTLabel.h"

@protocol CommentViewCellDelegate <NSObject>

@optional
- (void)processRTLabelLinkBtnClick:(RTLabelButton *)button;

@end

@interface CommentViewCell : UITableViewCell

@property (nonatomic, weak) UIViewController<CommentViewCellDelegate> *delegate;

@property (nonatomic, strong) Comment *comment;
@property (nonatomic, strong) IBOutlet UIImageView *commentAvatar;
@property (nonatomic, strong) IBOutlet UIButton *commentUsername;
@property (nonatomic, strong) IBOutlet UILabel *commentCNNumber;
@property (nonatomic, strong) IBOutlet UILabel *commentDisplayDate;
@property (nonatomic, strong) IBOutlet RTLabel *commentContent;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentContentViewHeight;

+ (CGFloat)heightOfCellWithComment:(Comment *)comment;
- (void)setupViewForComment:(Comment*)comment;
- (void)setupView;

@end

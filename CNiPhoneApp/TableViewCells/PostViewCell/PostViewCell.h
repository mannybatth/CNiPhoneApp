//
//  PostViewCell.h
//  CNiPhoneApp
//
//  Created by Manny on 2/20/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "PostStore.h"
#import "RTLabel.h"

@class PostViewCell;
@protocol PostViewCellDelegate <NSObject>

@optional
- (void)processRTLabelLinkBtnClick:(RTLabelButton *)button;

@end

@interface PostViewCell : UITableViewCell

@property (nonatomic, weak) UIViewController<PostViewCellDelegate> *delegate;

@property (nonatomic, strong) Post *post;
@property (nonatomic) BOOL showFullPost;

@property (nonatomic, strong) IBOutlet UIImageView *postAvatar;
@property (nonatomic, strong) IBOutlet UIButton *postAvatarBtn;
@property (nonatomic, strong) IBOutlet UIButton *postUsername;
@property (nonatomic, strong) IBOutlet UILabel *postCNNumber;
@property (nonatomic, strong) IBOutlet UILabel *postDate;
@property (nonatomic, strong) IBOutlet UILabel *postRelations;
@property (nonatomic, strong) IBOutlet UIImageView *postUserFlag;
@property (nonatomic, strong) IBOutlet UIView *postTagsView;
@property (nonatomic, strong) IBOutlet UILabel *postTitle;
@property (nonatomic, strong) IBOutlet RTLabel *postContent;
@property (nonatomic, strong) IBOutlet UIScrollView *postAttachmentsScrollView;
@property (nonatomic, strong) IBOutlet UIView *postLinksView;
@property (nonatomic, strong) IBOutlet UILabel *postInfoLabel;
@property (nonatomic, strong) IBOutlet UIButton *postLikeBtn;
@property (nonatomic, strong) IBOutlet UIButton *postReflectBtn;
@property (nonatomic, strong) IBOutlet UIButton *postMoreBtn;

@property (nonatomic, strong) IBOutlet UIView *postShareLinkView;
@property (nonatomic, strong) IBOutlet UIImageView *postShareLinkImageView;
@property (nonatomic, strong) IBOutlet UILabel *postShareLinkTitle;
@property (nonatomic, strong) IBOutlet UILabel *postShareLinkDesc;
@property (nonatomic, strong) IBOutlet UIButton *postShareLinkBtn;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *postTagsViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *postTitleHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *postContentViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *postShareLinkViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *postAttachmentsScrollViewWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *postAttachmentsScrollViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *postLinksViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *postInfoLabelHeight;

+ (CGFloat)heightOfCellWithPost:(Post*)post withFullText:(BOOL)showFullPost;
- (void)setupViewForPost:(Post*)post withFullText:(BOOL)showFullPost;
- (void)setupView;
- (void)sendUpdatePostViewNotification;

@end

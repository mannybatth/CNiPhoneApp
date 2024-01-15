//
//  PostViewCell.m
//  CNiPhoneApp
//
//  Created by Manny on 2/20/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "PostViewCell.h"
#import "CNNavigationHelper.h"
#import "PostLikesViewController.h"
#import "UIView+GCLibrary.h"
#import "UIView+AutoLayout.h"
#import "UIActionSheet+Blocks.h"
#import "UIAlertView+Blocks.h"
#import "HexColor.h"
#import "TSMessage.h"
#import "CNButton.h"
#import "BadgeLabel.h"
#import "WebViewController.h"
#import "Tools.h"
#import "MWPhotoBrowser.h"

#define POST_TAGS_VIEW_HEIGHT 20
#define POST_TITLE_HEIGHT 21
#define POST_TEXT_WIDTH 282
#define POST_TEXT_HEIGHT 110
#define POST_SHARELINK_HEIGHT 86
#define POST_PICTURE_THUMBNAIL_SIZE 180
#define POST_PICTURE_THUMBNAIL_SPACING 6
#define POST_LINKS_TOP_PADDING 7
#define POST_LINK_HEIGHT 14
#define POST_LINK_SPACING 2
#define POST_INFO_LABEL_HEIGHT 5

typedef enum {
    PhotoType,
    VideoType
} AttachmentType;

@interface AttachmentButton : UIButton

@property (nonatomic) AttachmentType type;
@property (nonatomic) NSUInteger index;
@property (nonatomic, readwrite, retain) id userData;

@end
@implementation AttachmentButton @end

@interface PostViewCell() <RTLabelDelegate, MWPhotoBrowserDelegate>
{
    NSMutableArray *photos;
    NSMutableArray *thumbs;
}

@end

@implementation PostViewCell

+ (RTLabel*)postRTLabel
{
	RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectMake(0, 0, POST_TEXT_WIDTH, POST_TEXT_HEIGHT)];
	[label setFont:[UIFont fontWithName:@"Verdana" size:12.0]];
    label.lineSpacing = 0.0;
	return label;
}

+ (CGFloat)heightOfCellWithPost:(Post *)post withFullText:(BOOL)showFullPost
{
    CGFloat cellHeight = 0;
    
    if (![post.userPosition isEqualToString:@""] && post.userPosition != nil) {
        cellHeight += POST_TAGS_VIEW_HEIGHT;
    }
    
    if (post.title && !post.shareLink) {
        cellHeight += POST_TITLE_HEIGHT;
    }
    
    if (post.shareLink) {
        cellHeight += POST_SHARELINK_HEIGHT;
    }
    
    if (!showFullPost && post.postShortContentHeight == 0) {
        
        RTLabel *rtLabel = [PostViewCell postRTLabel];
        rtLabel.maxHeight = POST_TEXT_HEIGHT;
        [rtLabel setText:post.shortRawText];
        post.postShortContentHeight = [rtLabel optimumSize].height+5;
        
    } else if (showFullPost && post.postFullContentHeight == 0) {
        
        RTLabel *rtLabel = [PostViewCell postRTLabel];
        rtLabel.maxHeight = MAXFLOAT;
        [rtLabel setText:post.rawText];
        post.postFullContentHeight = [rtLabel optimumSize].height+5;
        
    }
    cellHeight += showFullPost ? post.postFullContentHeight : post.postShortContentHeight;
    
    if (post.hasAttachments) {
        cellHeight += POST_PICTURE_THUMBNAIL_SIZE;
    }
    
    if (post.hasLinks) {
        cellHeight += (post.links.count+post.attachments.count)*(POST_LINK_HEIGHT+POST_LINK_SPACING)+POST_LINKS_TOP_PADDING;
    }
    
    cellHeight += POST_INFO_LABEL_HEIGHT;
    
    cellHeight += 121;
    
    return cellHeight;
}

- (void)awakeFromNib
{
    UIImage *bgImage = [UIImage imageNamed:@"post_bg"];
    UIEdgeInsets bgInsets = UIEdgeInsetsMake(12.0f, 12.0f, 9.0f, 11.0f);
    UIImage *bgStretchableImage = [bgImage resizableImageWithCapInsets:bgInsets];
    UIImageView *bgView = [[UIImageView alloc] initWithImage:bgStretchableImage];
    self.backgroundView = bgView;
    
    self.postAvatar.layer.masksToBounds = YES;
    self.postAvatar.layer.cornerRadius = 4;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.postContent.delegate = self;
    [self.postContent setFont:[UIFont fontWithName:@"Verdana" size:12.0]];
    self.postContent.lineSpacing = 0.0;
    
    self.postAttachmentsScrollView.scrollsToTop = NO;
    [self.postTagsView setBackgroundColor:[UIColor whiteColor]];
    [self.postLinksView setBackgroundColor:[UIColor whiteColor]];
    
    [self.postLikeBtn setImage:[[UIImage imageNamed:@"like_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.postReflectBtn setImage:[UIImage imageNamed:@"comment_icon"] forState:UIControlStateNormal];
    [self.postMoreBtn setImage:[UIImage imageNamed:@"post_more_btn"] forState:UIControlStateNormal];
}

- (void)setupViewForPost:(Post *)post withFullText:(BOOL)showFullPost
{
    self.post = post;
    self.showFullPost = showFullPost;
    [self setupView];
}

- (void)setupView
{
    [self.postAvatar setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", self.post.user.avatar]]
                    placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
    [self.postUsername setTitle:self.post.user.displayName forState:UIControlStateNormal];
    self.postCNNumber.text = [NSString stringWithFormat:@"%@", self.post.user.CNNumber];
    self.postDate.text = [Tools shortenedDate:self.post.postDate];
    [self.postUserFlag setImageWithURL:[NSURL URLWithString:self.post.user.flagURL]];
    
    //self.postInfoLabel.text = [NSString stringWithFormat:@"Posted %@", self.post.displayTime];
    self.postInfoLabel.text = @"";
    self.postInfoLabelHeight.constant = POST_INFO_LABEL_HEIGHT;
    
    [self setupContentLabel];
    
    // Relations 23 max char
    self.postRelations.text = @"";
    if (self.post.courses.count > 0) {
        NSString *text;
        Course *course = [self.post.courses objectAtIndex:0];
        if (self.post.courses.count == 1) {
            text = course.name;
        } else {
            text = [NSString stringWithFormat:@"%@, %u other%s", course.name, self.post.courses.count-1, (self.post.courses.count-1 > 1) ? "s" : ""];
        }
        self.postRelations.text = text;
    } else if (self.post.conexuses.count > 0) {
        NSString *text;
        Conexus *conexus = [self.post.conexuses objectAtIndex:0];
        if (self.post.conexuses.count == 1) {
            text = conexus.name;
        } else {
            text = [NSString stringWithFormat:@"%@, %u other%s", conexus.name, self.post.conexuses.count-1, (self.post.conexuses.count-1 > 1) ? "s" : ""];
        }
        self.postRelations.text = text;
    }
    
    // Tags View
    for (UIImageView *subview in [self.postTagsView subviews]) {
        [subview removeFromSuperview];
    }
    if (![self.post.userPosition isEqualToString:@""] && self.post.userPosition != nil) {
        self.postTagsViewHeight.constant = POST_TAGS_VIEW_HEIGHT;
        BadgeLabel *badge = [[BadgeLabel alloc] init];
        badge.font = [UIFont boldSystemFontOfSize:11.0f];
        badge.text = [self.post.userPosition uppercaseString];
        
        if ([[self.post.userPosition uppercaseString] isEqualToString:@"CN ADMIN"]) {
            badge.backgroundColor = [[UIColor colorWithHexString:@"#d50000"] colorWithAlphaComponent:0.6f];
        } else if ([[self.post.userPosition uppercaseString] isEqualToString:@"INSTRUCTOR"]) {
            badge.backgroundColor = [[UIColor colorWithHexString:@"#ff8200"] colorWithAlphaComponent:0.6f];
        } else {
            badge.backgroundColor = [[UIColor colorWithHexString:@"#5ab125"] colorWithAlphaComponent:0.6f];
        }
        
        badge.layer.cornerRadius = 2;
        badge.x = 0; badge.y = 0;
        [self.postTagsView addSubview:badge];
    } else {
        self.postTagsViewHeight.constant = 0.0f;
    }
    
    // Post Title
    if (self.post.title && !self.post.shareLink) {
        self.postTitleHeight.constant = POST_TITLE_HEIGHT;
        self.postTitle.text = self.post.title;
    } else {
        self.postTitleHeight.constant = 0.0f;
    }
    
    // ShareLink
    if (self.post.shareLink) {
        self.postShareLinkViewHeight.constant = POST_SHARELINK_HEIGHT;
        self.postShareLinkView.hidden = NO;
        self.postShareLinkBtn.hidden = NO;
        self.postShareLinkTitle.text = self.post.title;
        self.postShareLinkTitle.textColor = [UIColor colorWithRed:34.0f/255.0f green:71.0f/255.0f blue:132.0f/255.0f alpha:1.0f];
        if ([self.post.description isEqualToString:@""]) {
            self.postShareLinkDesc.text = self.post.originalShareLink;
        } else {
            self.postShareLinkDesc.text = self.post.description;
        }
        self.postShareLinkImageView.clipsToBounds = YES;
        if (self.post.shareLinkPicture.pictureURL) [self.postShareLinkImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", self.post.shareLinkPicture.pictureURL]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
        self.postShareLinkView.layer.borderColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.09f] CGColor];
        self.postShareLinkView.layer.borderWidth = 1.0f;
    } else {
        self.postShareLinkViewHeight.constant = 0.0f;
        self.postShareLinkView.hidden = YES;
        self.postShareLinkBtn.hidden = YES;
    }
    
    // Post Pic/Vids ScrollView
    for (UIImageView *subview in [self.postAttachmentsScrollView subviews]) {
        [subview removeFromSuperview];
    }
    [self setupAttachmentsScrollView];
    if (self.post.hasAttachments) {
        [self displayAttachments];
    }
    
    // Links View
    for (UIButton *subview in [self.postLinksView subviews]) {
        [subview removeFromSuperview];
    }
    if (self.post.hasLinks) {
        [self displayLinks];
    } else {
        self.postLinksViewHeight.constant = 0.0f;
    }
    
    // Buttons
    self.postLikeBtn.selected = self.post.isLiked;
    if (self.post.isLiked) {
        [self.postLikeBtn setTintColor:[UIColor colorWithHexString:@"#10a2ff"]];
    } else {
        [self.postLikeBtn setTintColor:[UIColor colorWithHexString:@"#a2a2a2"]];
    }
    [self updateLikeBtnLabel];
    
    [self.postReflectBtn setTitle:[NSString stringWithFormat:@"%i %@", self.post.count.comments, self.post.count.comments == 1 ? @"Reflection" : @"Reflections"] forState:UIControlStateNormal];
}

- (void)setupContentLabel
{
    self.postContent.maxHeight = self.showFullPost ? MAXFLOAT : POST_TEXT_HEIGHT;
    [self.postContent setText:self.showFullPost ? self.post.rawText : self.post.shortRawText];
    
    CGFloat labelHeight = self.showFullPost ? self.post.postFullContentHeight : self.post.postShortContentHeight;
    if (!labelHeight) {
        labelHeight = [self.postContent optimumSize].height+5;
        if (self.showFullPost) {
            self.post.postFullContentHeight = labelHeight;
        } else {
            self.post.postShortContentHeight = labelHeight;
        }
    }
    self.postContentViewHeight.constant = self.showFullPost ? self.post.postFullContentHeight : self.post.postShortContentHeight;
}

- (void)setupAttachmentsScrollView
{
    if (self.post.hasAttachments) {
        self.postAttachmentsScrollViewHeight.constant = POST_PICTURE_THUMBNAIL_SIZE;
        if (self.post.videos.count+self.post.pictures.count > 1) {
            self.postAttachmentsScrollViewWidth.constant = 295.0f;
        } else {
            self.postAttachmentsScrollViewWidth.constant = POST_PICTURE_THUMBNAIL_SIZE;
        }
    } else {
        self.postAttachmentsScrollViewHeight.constant = 0.0f;
    }
}

- (void)displayAttachments
{
    __block int picX = 0;
    
    CGFloat scrollWidth = ((self.post.pictures.count+self.post.videos.count)*(POST_PICTURE_THUMBNAIL_SIZE+POST_PICTURE_THUMBNAIL_SPACING))+picX;
    self.postAttachmentsScrollView.userInteractionEnabled = YES;
    [self.postAttachmentsScrollView setContentSize:CGSizeMake(scrollWidth, POST_PICTURE_THUMBNAIL_SIZE)];
    self.postAttachmentsScrollView.height = POST_PICTURE_THUMBNAIL_SIZE;
    
    [self.post.videos enumerateObjectsUsingBlock:^(Video *video, NSUInteger idx, BOOL *stop) {
        
        NSString *thumbnail = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/0.jpg", video.youtubeId];
        UIImageView *videoImageView = [[UIImageView alloc] init];
        videoImageView.contentMode = UIViewContentModeScaleAspectFill;
        videoImageView.clipsToBounds = YES;
        videoImageView.frame = CGRectMake(picX, 0, POST_PICTURE_THUMBNAIL_SIZE, POST_PICTURE_THUMBNAIL_SIZE);
        [videoImageView setImageWithURL:[NSURL URLWithString:thumbnail]
                       placeholderImage:nil];
        
        AttachmentButton *videoButton = [AttachmentButton buttonWithType:UIButtonTypeCustom];
        [videoButton setImage:[UIImage imageNamed:@"post_video_play_btn"] forState:UIControlStateNormal];
        videoButton.type = VideoType;
        videoButton.userData = video;
        videoButton.index = idx;
        [videoButton setFrame:CGRectMake(picX, 0, POST_PICTURE_THUMBNAIL_SIZE, POST_PICTURE_THUMBNAIL_SIZE)];
        [videoButton addTarget:self action:@selector(onAttachmentClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.postAttachmentsScrollView addSubview:videoImageView];
        [self.postAttachmentsScrollView addSubview:videoButton];
        
        picX = picX+POST_PICTURE_THUMBNAIL_SIZE+POST_PICTURE_THUMBNAIL_SPACING;
    }];
    
    [self.post.pictures enumerateObjectsUsingBlock:^(Picture *picture, NSUInteger idx, BOOL *stop) {
        NSString *thumbnail = [NSString stringWithFormat:@"%@.w%i.jpg", picture.pictureURL, POST_PICTURE_THUMBNAIL_SIZE+100];
        UIImageView *picImageView = [[UIImageView alloc] init];
        picImageView.contentMode = UIViewContentModeScaleAspectFill;
        picImageView.clipsToBounds = YES;
        picImageView.frame = CGRectMake(picX, 0, POST_PICTURE_THUMBNAIL_SIZE, POST_PICTURE_THUMBNAIL_SIZE);
        [picImageView setImageWithURL:[NSURL URLWithString:thumbnail]
                     placeholderImage:nil];
        
        AttachmentButton *picButton = [AttachmentButton buttonWithType:UIButtonTypeCustom];
        picButton.type = PhotoType;
        picButton.userData = picture;
        picButton.index = idx;
        [picButton setFrame:picImageView.frame];
        [picButton addTarget:self action:@selector(onAttachmentClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.postAttachmentsScrollView addSubview:picImageView];
        [self.postAttachmentsScrollView addSubview:picButton];
        
        picX = picX+POST_PICTURE_THUMBNAIL_SIZE+POST_PICTURE_THUMBNAIL_SPACING;
    }];
}

- (void)displayLinks
{
    __block int linkY = POST_LINKS_TOP_PADDING;
    
    CGFloat viewHeight = (self.post.links.count+self.post.attachments.count)*(POST_LINK_HEIGHT+POST_LINK_SPACING)+linkY;
    self.postLinksView.height = viewHeight;
    
    [self.post.links enumerateObjectsUsingBlock:^(Link *link, NSUInteger idx, BOOL *stop) {
        
        CNButton *linkBtn = [CNButton buttonWithType:UIButtonTypeCustom];
        [linkBtn setFrame:CGRectMake(0, linkY, self.postLinksView.width, POST_LINK_HEIGHT)];
        [linkBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [linkBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [linkBtn setTitle:link.displayUrl forState:UIControlStateNormal];
        [linkBtn setTitleColor:[UIColor colorWithRed:34.0f/255.0f green:71.0f/255.0f blue:132.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        linkBtn.userData = link;
        [linkBtn addTarget:self action:@selector(onLinkClick:) forControlEvents:UIControlEventTouchUpInside];
        [linkBtn sizeThatFits:CGSizeMake(self.postLinksView.width, POST_LINK_HEIGHT)];
        linkBtn.height = POST_LINK_HEIGHT;
        
        [self.postLinksView addSubview:linkBtn];
        
        linkY = linkY+POST_LINK_HEIGHT+POST_LINK_SPACING;
        
    }];
    
    [self.post.attachments enumerateObjectsUsingBlock:^(Attachment *attachment, NSUInteger idx, BOOL *stop) {
        
        CNButton *linkBtn = [CNButton buttonWithType:UIButtonTypeCustom];
        [linkBtn setFrame:CGRectMake(0, linkY, self.postLinksView.width, POST_LINK_HEIGHT)];
        [linkBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [linkBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [linkBtn setTitle:attachment.attachmentName forState:UIControlStateNormal];
        [linkBtn setTitleColor:[UIColor colorWithRed:34.0f/255.0f green:71.0f/255.0f blue:132.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        linkBtn.userData = attachment;
        [linkBtn addTarget:self action:@selector(onFileAttachmentClick:) forControlEvents:UIControlEventTouchUpInside];
        [linkBtn sizeThatFits:CGSizeMake(self.postLinksView.width, POST_LINK_HEIGHT)];
        linkBtn.height = POST_LINK_HEIGHT;
        
        [self.postLinksView addSubview:linkBtn];
        
        linkY = linkY+POST_LINK_HEIGHT+POST_LINK_SPACING;
        
    }];
    self.postLinksViewHeight.constant = viewHeight;
}

- (void)updateLikeBtnLabel
{
    if (self.post.count.likes > 0) {
        [self.postLikeBtn setTitle:[NSString stringWithFormat:@"%i", self.post.count.likes] forState:UIControlStateNormal];
    } else {
        [self.postLikeBtn setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)sendUpdatePostViewNotification
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          ACTION_UPDATE_VIEW, @"Action",
                          self.post, @"Post",
                          nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTF_POST_VIEW_CHANGED
                                                        object:nil
                                                      userInfo:dict];
}

- (void)onAttachmentClick:(AttachmentButton*)sender
{
    if (sender.type == PhotoType) {
        
        photos = [[NSMutableArray alloc] init];
        thumbs = [[NSMutableArray alloc] init];
        
        [self.post.pictures enumerateObjectsUsingBlock:^(Picture *picture, NSUInteger idx, BOOL *stop) {
            NSString *thumbnail = [NSString stringWithFormat:@"%@.w%i.jpg", picture.pictureURL, POST_PICTURE_THUMBNAIL_SIZE+100];
            [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:picture.pictureURL]]];
            [thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:thumbnail]]];
        }];
        
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = NO;
        browser.displayNavArrows = NO;
        browser.displaySelectionButtons = NO;
        browser.alwaysShowControls = NO;
        browser.zoomPhotosToFill = YES;
        browser.enableGrid = NO;
        browser.startOnGrid = NO;
        browser.enableSwipeToDismiss = YES;
        [browser setCurrentPhotoIndex:sender.index];
        
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.delegate presentViewController:nc animated:YES completion:nil];
        
    } else if (sender.type == VideoType) {
        Video *video = sender.userData;
        if (video.youtubeId) {
            NSString *urlPath = [NSString stringWithFormat:@"http://youtube.com/watch?v=%@", video.youtubeId];
            WebViewController *webViewController = [[WebViewController alloc] initWithPath:urlPath];
            [self.delegate.navigationController pushViewController:webViewController animated:YES];
        }
    }
}

- (void)onLinkClick:(CNButton*)sender
{
    Link *link = sender.userData;
    if (link.viewUrl) {
        WebViewController *webViewController = [[WebViewController alloc] initWithPath:link.viewUrl];
        [self.delegate.navigationController pushViewController:webViewController animated:YES];
    }
}

- (void)onFileAttachmentClick:(CNButton*)sender
{
    Attachment *attachment = sender.userData;
    if (attachment.attachmentURL) {
        WebViewController *webViewController = [[WebViewController alloc] initWithPath:attachment.attachmentURL];
        [self.delegate.navigationController pushViewController:webViewController animated:YES];
    }
}

- (IBAction)onShareLinkBtnClick:(UIButton*)sender
{
    if (self.post.shareLink) {
        WebViewController *webViewController = [[WebViewController alloc] initWithPath:self.post.shareLink];
        [self.delegate.navigationController pushViewController:webViewController animated:YES];
    }
}

- (IBAction)onOptionsBtnClick:(id)sender
{
    RIButtonItem *deleteBtn = nil;
    if (self.post.isOwner && self.post.isDeletable) {
        deleteBtn = [RIButtonItem itemWithLabel:@"Delete Post" action:^{
            [self deleteThisPost];
        }];
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                     cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel" action:nil]
                                                destructiveButtonItem:deleteBtn
                                                     otherButtonItems:[RIButtonItem itemWithLabel:@"Show Likes" action:^{
        
        PostLikesViewController *postLikesViewController = [[PostLikesViewController alloc] init];
        postLikesViewController.post = self.post;
        [self.delegate.navigationController pushViewController:postLikesViewController animated:YES];
        
                                                                    }], nil];
    [actionSheet showInView:self];
}

- (IBAction)onLikeBtnClick:(id)sender
{
    self.postLikeBtn.selected = !self.postLikeBtn.selected;
    self.postLikeBtn.enabled = NO;
    if (!self.post.isLiked) {
        [PostStore likePostWithId:self.post.postId block:^(BOOL success, NSString *error) {
            self.postLikeBtn.enabled = YES;
            if (!error) {
                self.post.isLiked = YES;
                self.post.count.likes++;
                [self updateLikeBtnLabel];
                [self.postLikeBtn setTintColor:[UIColor colorWithHexString:@"#10a2ff"]];
                
                [UIView animateWithDuration:0.4f delay:0.0f options:0 animations:^{
                    self.postLikeBtn.imageView.transform = CGAffineTransformMakeScale(0.7, 0.7);
                } completion:^(BOOL finished) {
                    self.postLikeBtn.imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                }];
                
                [self setupView];
                [self sendUpdatePostViewNotification];
            } else {
                self.postLikeBtn.selected = NO;
            }
        }];
    } else {
        [PostStore unlikePostWithId:self.post.postId block:^(BOOL success, NSString *error) {
            self.postLikeBtn.enabled = YES;
            if (!error) {
                self.post.isLiked = NO;
                self.post.count.likes--;
                [self updateLikeBtnLabel];
                [self.postLikeBtn setTintColor:[UIColor colorWithHexString:@"#a2a2a2"]];
                
                [UIView animateWithDuration:0.3f delay:0.0f options:0 animations:^{
                    self.postLikeBtn.imageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                } completion:^(BOOL finished) {
                    self.postLikeBtn.imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                }];
                
                [self setupView];
                [self sendUpdatePostViewNotification];
            } else {
                self.postLikeBtn.selected = YES;
            }
        }];
    }
}

- (IBAction)onReflectionBtnClick:(id)sender
{
    [CNNavigationHelper openPostDetailsViewWithPost:self.post focusTextBox:YES];
}

- (IBAction)onAvatarBtnClick:(id)sender
{
    if (!self.post.isFromAdmin) {
        [CNNavigationHelper openProfileViewWithUser:self.post.user];
    }
}

- (IBAction)onUserNameBtnClick:(id)sender
{
    if (!self.post.isFromAdmin) {
        [CNNavigationHelper openProfileViewWithUser:self.post.user];
    }
}

- (void)deleteThisPost
{
    UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Are you sure to want to delete this post?"
                                                      message:nil
                                             cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"]
                                             otherButtonItems:[RIButtonItem itemWithLabel:@"Yes delete it" action:^{
                                                                [PostStore deletePost:self.post.postId block:^(BOOL success, NSString *error) {
                                                                    if (!error) {
                                                                        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                                              ACTION_DELETE_VIEW, @"Action",
                                                                                              self.post, @"Post",
                                                                                              nil];
                                                                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTF_POST_VIEW_CHANGED
                                                                                                                            object:nil
                                                                                                                          userInfo:dict];
                                                                        
                                                                        [TSMessage showNotificationInViewController:self.delegate
                                                                                                              title:@"Post deleted!"
                                                                                                           subtitle:nil
                                                                                                               type:TSMessageNotificationTypeSuccess];
                                                                    } else {
                                                                        [TSMessage showNotificationInViewController:self.delegate
                                                                                                              title:@"Failed to delete post."
                                                                                                           subtitle:nil
                                                                                                               type:TSMessageNotificationTypeError];
                                                                    }
                                                                }];
                                                            }], nil];
    [confirm show];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < photos.count)
        return [photos objectAtIndex:index];
    return nil;
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

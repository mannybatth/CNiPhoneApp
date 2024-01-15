//
//  ProfileViewController.m
//  CNiPhoneApp
//
//  Created by Manny on 2/24/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "ProfileViewController.h"
#import "PostViewCell.h"
#import "UserListCell.h"
#import "UserAboutMeCell.h"
#import "HMSegmentedControl.h"
#import "UserStore.h"
#import "ColleageRequestStore.h"
#import "MWPhotoBrowser.h"
#import "UIAlertView+Blocks.h"

#define SUB_TITLE_LABEL_HEIGHT 53
#define DESCRIPTION_LABEL_HEIGHT 21

typedef enum {
    AboutTab,
    PostsTab,
    FollowersTab,
    FollowingTab,
    ColleaguesTab
} Tab;

typedef enum {
    Normal,
    Pending,
    Selected
} ColleagueBtnState;

@interface ProfileViewController () <PostViewCellDelegate,MWPhotoBrowserDelegate>
{
    NSMutableArray *posts;
    NSMutableArray *followers;
    NSMutableArray *following;
    NSMutableArray *colleages;
    
    int contentLimit;
    int contentOffset;
    BOOL loadingContent;
    BOOL noMoreContent;
    BOOL initialLoadDone;
    
    BOOL descriptionLabelHidden;
    Tab currentTab;
    ColleagueBtnState colleagueBtnState;
    HMSegmentedControl *segmentedControl;
    MWPhoto *avatarPhoto;
    
    UITableViewLoadingFooter *tableViewLoadingFooter;
}

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UIImageView *avatarImg;
@property (nonatomic, strong) IBOutlet UILabel *profileFullName;
@property (nonatomic, strong) IBOutlet UILabel *profileCNNumber;
@property (nonatomic, strong) IBOutlet UILabel *profileSubTitle;
@property (nonatomic, strong) IBOutlet UILabel *profileDescription;
@property (nonatomic, strong) IBOutlet UILabel *anarSeedsLabel;

@property (nonatomic, strong) IBOutlet UIButton *addColleagueBtn;
@property (nonatomic, strong) IBOutlet UIButton *addFollowBtn;
@property (nonatomic, strong) IBOutlet UIButton *sendEmailBtn;

@property (nonatomic, strong) IBOutlet UIView *segmentContainer;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *profileSubTitleLabelHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *profileDescriptionLabelHeight;

@end

@implementation ProfileViewController

@synthesize user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Profile";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onPostViewChanged:)
                                                 name:NOTF_POST_VIEW_CHANGED
                                               object:nil];
    
    posts = [[NSMutableArray alloc] init];
    followers = [[NSMutableArray alloc] init];
    following = [[NSMutableArray alloc] init];
    colleages = [[NSMutableArray alloc] init];
    
    contentLimit = 10;
    contentOffset = 0;
    currentTab = PostsTab;
    
    [self.tableView setScrollsToTop:YES];
    tableViewLoadingFooter = (UITableViewLoadingFooter*)self.tableView.tableFooterView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(beginRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.tableView.tableHeaderView.hidden = YES;
    [tableViewLoadingFooter startLoading];
    if (user.userId) {
        [UserStore getUserById:user.userId full:YES block:^(User *userObj, NSString *error) {
            if (!error) {
                user = userObj;
                [self setupView];
            }
        }];
    } else if (user.CNNumber) {
        [UserStore getUserByCNNumber:user.CNNumber full:YES block:^(User *userObj, NSString *error) {
            if (!error) {
                user = userObj;
                [self setupView];
            }
        }];
    }
}

- (void)setupView
{
    [self.avatarImg setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", user.avatar]]
                   placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
    
    avatarPhoto = [MWPhoto photoWithURL:[NSURL URLWithString:user.avatar]];
    
    self.profileFullName.text = user.displayName;
    self.profileCNNumber.text = [NSString stringWithFormat:@"%@", user.CNNumber];
    
    // profile description
    if ([self.user.profile.about isEqualToString:@""] || !self.user.profile.about) {
        self.profileDescriptionLabelHeight.constant = 0.0f;
        descriptionLabelHidden = YES;
    } else {
        self.profileDescription.text = self.user.profile.about;
    }
    
    // display subTitle
    if ([[user.profile.currentPosition.positionName lowercaseString] isEqualToString:@"other"]) {
        self.profileSubTitle.text = user.profile.currentPosition.positionType;
    } else if (![user.profile.currentPosition.positionName isEqualToString:@""] && ![user.profile.currentPosition.positionSchoolName isEqualToString:@""] && (user.profile.currentPosition.positionName != nil) && (user.profile.currentPosition.positionSchoolName != nil)) {
        self.profileSubTitle.text = [NSString stringWithFormat:@"%@ at %@", user.profile.currentPosition.positionName, user.profile.currentPosition.positionSchoolName];
    } else if (![user.profile.currentPosition.positionName isEqualToString:@""] && (user.profile.currentPosition.positionName != nil)) {
        self.profileSubTitle.text = user.profile.currentPosition.positionName;
    } else {
        self.profileSubTitleLabelHeight.constant = 0.0f;
    }
    
    // setup profile buttons
    if ([user.userId isEqualToString:[Session shared].currentUser.userId]) {
        self.addFollowBtn.enabled = NO;
        self.addColleagueBtn.enabled = NO;
    } else {
        if (user.relations.isMyFollowingUser) {
            self.addFollowBtn.selected = YES;
        } else {
            self.addFollowBtn.selected = NO;
        }
        
        if (user.relations.isMyColleagueUser) {
            colleagueBtnState = Selected;
        } else if (user.relations.isMyPendingColleagueUser) {
            colleagueBtnState = Pending;
        } else {
            colleagueBtnState = Normal;
        }
        [self updateColleagueButtonState];
    }
    
    // show anar seeds
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setGroupingSeparator:@","];
    NSString *anarSeedsString = [numberFormatter stringForObjectValue:[NSNumber numberWithInt:user.score.total]];
    self.anarSeedsLabel.text = [NSString stringWithFormat:@"%@ Anar Seeds", anarSeedsString];
    
    NSArray *segmentItems;
    HMSegmentedControlSegmentWidthStyle widthStyle;
    if ([user.userId isEqualToString:[Session shared].currentUser.userId]) {
        segmentItems = [NSArray arrayWithObjects:
                        @"About Me",
                        @"Posts",
                        [NSString stringWithFormat:@"%i Followers", user.userCount.numOfFollowers],
                        [NSString stringWithFormat:@"%i Following", user.userCount.numOfFollowing],
                        [NSString stringWithFormat:@"%i Colleagues", user.userCount.numOfColleagues], nil];
        widthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    } else {
        segmentItems = [NSArray arrayWithObjects:
                        @"About Me",
                        @"Posts", nil];
        widthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    }
    segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:segmentItems];
    [segmentedControl setFrame:CGRectMake(0, 0, 320, 40)];
    [segmentedControl setSegmentEdgeInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    [segmentedControl setFont:[UIFont fontWithName:@"Verdana" size:12.0f]];
    [segmentedControl setSelectionIndicatorHeight:4.0f];
    [segmentedControl setBackgroundColor:[UIColor whiteColor]];
    [segmentedControl setTextColor:[UIColor darkGrayColor]];
    [segmentedControl setSelectedTextColor:[UIColor colorWithRed:0.0 green:66.0f/255.0f blue:118.0f/255.0f alpha:1]];
    [segmentedControl setSelectionBoxBackgroundColor:[UIColor lightGrayColor]];
    [segmentedControl setSelectionIndicatorColor:[UIColor colorWithRed:0.0 green:66.0f/255.0f blue:118.0f/255.0f alpha:1]];
    [segmentedControl setSelectedSegmentIndex:currentTab animated:NO];
    [segmentedControl setSelectionIndicatorLocation:HMSegmentedControlSelectionIndicatorLocationDown];
    [segmentedControl setSegmentWidthStyle:widthStyle];
    [segmentedControl setSelectionStyle:HMSegmentedControlSelectionStyleBox];
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.scrollEnabled = YES;
    [self.segmentContainer addSubview:segmentedControl];
    
    [self segmentedControlChangedValue:segmentedControl];
    
    if (descriptionLabelHidden) {
        self.tableView.tableHeaderView.height = self.tableView.tableHeaderView.height-DESCRIPTION_LABEL_HEIGHT-32;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
    }
    self.tableView.tableHeaderView.hidden = NO;
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)control
{
    switch ([control selectedSegmentIndex]) {
        case AboutTab:
            currentTab = AboutTab;
            break;
        case PostsTab:
            currentTab = PostsTab;
            break;
        case FollowersTab:
            currentTab = FollowersTab;
            break;
        case FollowingTab:
            currentTab = FollowingTab;
            break;
        case ColleaguesTab:
            currentTab = ColleaguesTab;
            break;
            
        default:
            break;
    }
    [self refreshContent];
    [self.tableView reloadData];
}

- (void)beginRefresh
{
    [tableViewLoadingFooter stopLoading];
    [self refreshContent];
}

- (void)refreshContent
{
    noMoreContent = NO;
    loadingContent = NO;
    contentOffset = 0;
    [tableViewLoadingFooter startLoading];
    [self getTabContents];
}

- (void)onLoadMoreContent
{
    if (loadingContent == NO && noMoreContent == NO && initialLoadDone == YES) {
        [tableViewLoadingFooter startLoading];
        contentOffset = contentOffset+contentLimit;
        [self getTabContents];
    }
}

- (void)getTabContents
{
    if (currentTab == AboutTab) {
        [tableViewLoadingFooter stopLoading];
        [self.refreshControl endRefreshing];
    }
    else if (currentTab == PostsTab) {
        
        if (loadingContent == NO && noMoreContent == NO) {
            loadingContent = YES;
            [PostStore getPostsFromUser:user.userId limit:contentLimit offset:contentOffset block:^(NSArray *contentsArr, NSString *error) {
                [tableViewLoadingFooter stopLoading];
                [self.refreshControl endRefreshing];
                if (!error) {
                    if ([contentsArr count] == 0) {
                        noMoreContent = YES;
                    } else {
                        if (contentOffset == 0) {
                            initialLoadDone = YES;
                            posts = [contentsArr mutableCopy];
                            [self.tableView reloadData];
                        } else {
                            NSMutableArray *rowsToInsert = [NSMutableArray new];
                            
                            [contentsArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                [rowsToInsert addObject:[NSIndexPath indexPathForItem:posts.count + idx inSection:0]];
                            }];
                            
                            [posts addObjectsFromArray:contentsArr];
                            [self.tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationFade];
                        }
                    }
                }
                loadingContent = NO;
            }];
        }
        
    }
    else if (currentTab == ColleaguesTab) {
        
        if (loadingContent == NO && noMoreContent == NO) {
            loadingContent = YES;
            [UserStore getUserColleagues:user.userId limit:contentLimit offset:contentOffset block:^(NSArray *contentsArr, NSString *error) {
                [tableViewLoadingFooter stopLoading];
                [self.refreshControl endRefreshing];
                if (!error) {
                    if ([contentsArr count] == 0) {
                        noMoreContent = YES;
                    } else {
                        if (contentOffset == 0) {
                            initialLoadDone = YES;
                            colleages = [contentsArr mutableCopy];
                            [self.tableView reloadData];
                        } else {
                            NSMutableArray *rowsToInsert = [NSMutableArray new];
                            
                            [contentsArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                [rowsToInsert addObject:[NSIndexPath indexPathForItem:colleages.count + idx inSection:0]];
                            }];
                            
                            [colleages addObjectsFromArray:contentsArr];
                            [self.tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationFade];
                        }
                    }
                }
                loadingContent = NO;
            }];
        }
        
    }
    else if (currentTab == FollowersTab) {
        
        if (loadingContent == NO && noMoreContent == NO) {
            loadingContent = YES;
            [UserStore getUserFollowers:user.userId limit:contentLimit offset:contentOffset block:^(NSArray *contentsArr, NSString *error) {
                [tableViewLoadingFooter stopLoading];
                [self.refreshControl endRefreshing];
                if (!error) {
                    if ([contentsArr count] == 0) {
                        noMoreContent = YES;
                    } else {
                        if (contentOffset == 0) {
                            initialLoadDone = YES;
                            followers = [contentsArr mutableCopy];
                            [self.tableView reloadData];
                        } else {
                            NSMutableArray *rowsToInsert = [NSMutableArray new];
                            
                            [contentsArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                [rowsToInsert addObject:[NSIndexPath indexPathForItem:followers.count + idx inSection:0]];
                            }];
                            
                            [followers addObjectsFromArray:contentsArr];
                            [self.tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationFade];
                        }
                    }
                }
                loadingContent = NO;
            }];
        }
        
    }
    else if (currentTab == FollowingTab) {
        
        if (loadingContent == NO && noMoreContent == NO) {
            loadingContent = YES;
            [UserStore getUserFollowing:user.userId limit:contentLimit offset:contentOffset block:^(NSArray *contentsArr, NSString *error) {
                [tableViewLoadingFooter stopLoading];
                [self.refreshControl endRefreshing];
                if (!error) {
                    if ([contentsArr count] == 0) {
                        noMoreContent = YES;
                    } else {
                        if (contentOffset == 0) {
                            initialLoadDone = YES;
                            following = [contentsArr mutableCopy];
                            [self.tableView reloadData];
                        } else {
                            NSMutableArray *rowsToInsert = [NSMutableArray new];
                            
                            [contentsArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                [rowsToInsert addObject:[NSIndexPath indexPathForItem:following.count + idx inSection:0]];
                            }];
                            
                            [following addObjectsFromArray:contentsArr];
                            [self.tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationFade];
                        }
                    }
                }
                loadingContent = NO;
            }];
        }
        
    }
}

- (void)updateColleagueButtonState
{
    if (colleagueBtnState == Selected) {
        [self.addColleagueBtn setImage:[UIImage imageNamed:@"profile_colleagues_btn.png"] forState:UIControlStateNormal];
    } else if (colleagueBtnState == Pending) {
        [self.addColleagueBtn setImage:[UIImage imageNamed:@"profile_pending_colleague_btn.png"] forState:UIControlStateNormal];
    } else {
        [self.addColleagueBtn setImage:[UIImage imageNamed:@"profile_colleague_btn.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)onAddFollowBtnClick:(UIButton*)sender
{
    if (user.relations.isMyFollowingUser) {
        self.addFollowBtn.enabled = NO;
        [UserStore unFollowUser:user.userId block:^(BOOL success, NSString *error) {
            if (!error) {
                user.relations.isMyFollowingUser = NO;
                self.addFollowBtn.selected = NO;
            }
            self.addFollowBtn.enabled = YES;
        }];
    } else {
        self.addFollowBtn.enabled = NO;
        [UserStore followUser:user.userId block:^(BOOL success, NSString *error) {
            if (!error) {
                user.relations.isMyFollowingUser = YES;
                self.addFollowBtn.selected = YES;
            }
            self.addFollowBtn.enabled = YES;
        }];
    }
}

- (IBAction)onAddColleagueBtnClick:(UIButton*)sender
{
    if (user.relations.isMyColleagueUser) {
        
        self.addColleagueBtn.enabled = NO;
        UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Colleague"
                                                        message:@"Are you sure to want to remove this colleague?"
                                                 cancelButtonItem:[RIButtonItem itemWithLabel:@"No" action:^{
            self.addColleagueBtn.enabled = YES;
        }]
                                               otherButtonItems:[RIButtonItem itemWithLabel:@"Remove" action:^{
            [ColleageRequestStore cancelColleageRequest:user.userId block:^(BOOL success, NSString *error) {
                if (!error) {
                    user.relations.isMyColleagueUser = NO;
                    colleagueBtnState = Normal;
                    [self updateColleagueButtonState];
                }
                self.addColleagueBtn.enabled = YES;
            }];
        }], nil];
        [confirm show];
        
    } else if (user.relations.isMyPendingColleagueUser) {
        
        self.addColleagueBtn.enabled = NO;
        UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Colleague"
                                                          message:@"Are you sure to want to cancel this colleague request?"
                                                 cancelButtonItem:[RIButtonItem itemWithLabel:@"No" action:^{
            self.addColleagueBtn.enabled = YES;
        }]
                                                 otherButtonItems:[RIButtonItem itemWithLabel:@"Remove" action:^{
            [ColleageRequestStore cancelColleageRequest:user.userId block:^(BOOL success, NSString *error) {
                if (!error) {
                    user.relations.isMyPendingColleagueUser = NO;
                    colleagueBtnState = Normal;
                    [self updateColleagueButtonState];
                }
                self.addColleagueBtn.enabled = YES;
            }];
        }], nil];
        [confirm show];
        
    } else {
        
        self.addColleagueBtn.selected = NO;
        [ColleageRequestStore sendColleageRequest:user.userId block:^(BOOL success, NSString *error) {
            if (!error) {
                user.relations.isMyPendingColleagueUser = YES;
                colleagueBtnState = Pending;
                [self updateColleagueButtonState];
            }
            self.addColleagueBtn.enabled = YES;
        }];
        
    }
}

- (IBAction)onSendEmailBtnClick:(id)sender
{
}

- (IBAction)onProfileAvatarBtnClick:(id)sender
{
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = NO;
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = NO;
    browser.startOnGrid = NO;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:0];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
}

- (void)onPostViewChanged:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    NSString *action = [dict objectForKey:@"Action"];
    
    if ([action isEqualToString:ACTION_UPDATE_VIEW]) {
        NSInteger index = 0;
        Post *post = [dict objectForKey:@"Post"];
        for (Post *obj in posts) {
            if ([obj.postId isEqualToString:post.postId]) {
                [posts replaceObjectAtIndex:index withObject:post];
                if (currentTab == PostsTab) [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
            index++;
        }
        
    } else if ([action isEqualToString:ACTION_DELETE_VIEW]) {
        NSInteger index = 0;
        Post *post = [dict objectForKey:@"Post"];
        for (Post *obj in posts) {
            if ([obj.postId isEqualToString:post.postId]) {
                [posts removeObjectAtIndex:index];
                if (currentTab == PostsTab) [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
            index++;
        }
        
    }
}

#pragma mark -
#pragma mark MWPhotoBrowser Delegates

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    return avatarPhoto;
}

#pragma mark -
#pragma mark UITableView Delegates

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 && currentTab == PostsTab) return 1;
    return 0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (currentTab == AboutTab) return 7;
    else if (currentTab == PostsTab) return [posts count];
    else if (currentTab == FollowersTab) return [followers count];
    else if (currentTab == FollowingTab) return [following count];
    else if (currentTab == ColleaguesTab) return [colleages count];
    else return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentTab == PostsTab) {
        Post *post = [posts objectAtIndex:indexPath.row];
        return [PostViewCell heightOfCellWithPost:post withFullText:NO];
        
    } else if (currentTab == AboutTab) {
        return [UserAboutMeCell heightOfCellWithUser:user atIndex:(int)indexPath.row];
        
    }
    return 72;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentTab == PostsTab) {
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentTab == PostsTab) {
        
        static NSString *cellIdentifier = @"PostViewCell";
        PostViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
        
        Post *post = [posts objectAtIndex:indexPath.row];
        
        cell.delegate = self;
        [cell setupViewForPost:post withFullText:NO];
        
        return cell;
        
    } else if (currentTab == ColleaguesTab || currentTab == FollowersTab || currentTab == FollowingTab) {
        
        static NSString *cellIdentifier = @"UserListCell";
        UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
        
        User *contentUser;
        if (currentTab == ColleaguesTab) {
            contentUser = [colleages objectAtIndex:indexPath.row];
        } else if (currentTab == FollowersTab) {
            contentUser = [followers objectAtIndex:indexPath.row];
        } else if (currentTab == FollowingTab) {
            contentUser = [following objectAtIndex:indexPath.row];
        }
        
        [cell setupViewForUser:contentUser];
        
        cell.userScoreLabel.hidden = YES;
        cell.anarSeedsImageView.hidden = YES;
        
        return cell;
        
    } else if (currentTab == AboutTab) {
        
        static NSString *cellIdentifier = @"UserAboutMeCell";
        UserAboutMeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
        
        [cell setupViewForUser:user atIndex:(int)indexPath.row];
        
        return cell;
        
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentTab == PostsTab) {
        
        Post *post = [posts objectAtIndex:indexPath.row];
        [CNNavigationHelper openPostDetailsViewWithPost:post];
        
    } else if (currentTab == ColleaguesTab || currentTab == FollowersTab || currentTab == FollowingTab) {
        
        User *contentUser;
        if (currentTab == ColleaguesTab) {
            contentUser = [colleages objectAtIndex:indexPath.row];
        } else if (currentTab == FollowersTab) {
            contentUser = [followers objectAtIndex:indexPath.row];
        } else if (currentTab == FollowingTab) {
            contentUser = [following objectAtIndex:indexPath.row];
        }
        [CNNavigationHelper openProfileViewWithUser:contentUser];
        
    } else {
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -60;
    if(y > h + reload_distance) {
        [self onLoadMoreContent];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

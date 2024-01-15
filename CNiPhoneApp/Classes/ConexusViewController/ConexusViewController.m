//
//  ConexusViewController.m
//  CNiPhoneApp
//
//  Created by Manny on 3/4/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "ConexusViewController.h"
#import "PostViewCell.h"
#import "UserListCell.h"
#import "HMSegmentedControl.h"
#import "ConexusStore.h"
#import "AboutConexusCell.h"

typedef enum {
    AboutConexusTab,
    PostsTab,
    MembersTab
} Tab;

@interface ConexusViewController () <PostViewCellDelegate>
{
    Tab currentTab;
    
    NSMutableArray *posts;
    NSMutableArray *members;
    
    int contentLimit;
    int contentOffset;
    BOOL loadingContent;
    BOOL noMoreContent;
    BOOL initialLoadDone;
    
    UITableViewLoadingFooter *tableViewLoadingFooter;
    HMSegmentedControl *segmentedControl;
}

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UIImageView *conexusLogoView;
@property (nonatomic, strong) IBOutlet UILabel *conexusTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *conexusNumberLabel;

@property (nonatomic, strong) IBOutlet UIView *segmentContainer;

@end

@implementation ConexusViewController

@synthesize conexus;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Conexus";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onPostViewChanged:)
                                                 name:NOTF_POST_VIEW_CHANGED
                                               object:nil];
    
    [self.tableView setScrollsToTop:YES];
    tableViewLoadingFooter = (UITableViewLoadingFooter*)self.tableView.tableFooterView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(beginRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    posts = [[NSMutableArray alloc] init];
    members = [[NSMutableArray alloc] init];
    
    contentLimit = 10;
    contentOffset = 0;
    currentTab = PostsTab;
    
    self.tableView.tableHeaderView.hidden = YES;
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    
    [ConexusStore getConexusDetails:conexus.conexusId block:^(Conexus *conexusObj, NSString *error) {
        if (!error) {
            conexus = conexusObj;
            
            [self setupView];
            self.tableView.tableHeaderView.hidden = NO;
            [self.refreshControl endRefreshing];
        }
    }];
}

- (void)setupView
{
    // Logo
    [self.conexusLogoView setClipsToBounds:YES];
    [self.conexusLogoView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", conexus.logoURL]]
                         placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
    
    // Title
    self.conexusTitleLabel.text = conexus.name;
    
    // Conexus Number
    self.conexusNumberLabel.text = conexus.conexusNumber;
    
    NSArray *segmentItems = @[@"About Conexus", @"Posts", @"Members"];
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
    [segmentedControl setSegmentWidthStyle:HMSegmentedControlSegmentWidthStyleDynamic];
    [segmentedControl setSelectionStyle:HMSegmentedControlSelectionStyleBox];
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.scrollEnabled = YES;
    [self.segmentContainer addSubview:segmentedControl];
    
    [self segmentedControlChangedValue:segmentedControl];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)control
{
    switch ([control selectedSegmentIndex]) {
        case AboutConexusTab:
            currentTab = AboutConexusTab;
            break;
        case PostsTab:
            currentTab = PostsTab;
            break;
        case MembersTab:
            currentTab = MembersTab;
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
    [self openCurrentTab];
}

- (void)onLoadMoreContent
{
    if (loadingContent == NO && noMoreContent == NO && initialLoadDone == YES) {
        [tableViewLoadingFooter startLoading];
        contentOffset = contentOffset+contentLimit;
        [self openCurrentTab];
    }
}

- (void)openCurrentTab
{
    if (currentTab == AboutConexusTab) {
        
        [self.refreshControl endRefreshing];
        [tableViewLoadingFooter stopLoading];
        initialLoadDone = YES;
        
    } else if (currentTab == PostsTab) {
        
        if (loadingContent == NO && noMoreContent == NO) {
            loadingContent = YES;
            [ConexusStore getConexusPosts:conexus.conexusId limit:contentLimit offset:contentOffset block:^(NSArray *contentsArr, NSString *error) {
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
        
    } else if (currentTab == MembersTab) {
        
        if (loadingContent == NO && noMoreContent == NO) {
            loadingContent = YES;
            [ConexusStore getConexusMembers:conexus.conexusId limit:contentLimit offset:contentOffset block:^(NSArray *contentsArr, NSString *error) {
                [tableViewLoadingFooter stopLoading];
                [self.refreshControl endRefreshing];
                if (!error) {
                    if ([contentsArr count] == 0) {
                        noMoreContent = YES;
                    } else {
                        if (contentOffset == 0) {
                            initialLoadDone = YES;
                            members = [contentsArr mutableCopy];
                            [self.tableView reloadData];
                        } else {
                            NSMutableArray *rowsToInsert = [NSMutableArray new];
                            
                            [contentsArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                [rowsToInsert addObject:[NSIndexPath indexPathForItem:members.count + idx inSection:0]];
                            }];
                            
                            [members addObjectsFromArray:contentsArr];
                            [self.tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationFade];
                        }
                    }
                }
                loadingContent = NO;
            }];
        }
        
    }
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
#pragma mark UITableView Delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!initialLoadDone) return 0;
    if (currentTab == AboutConexusTab) return 3;
    else if (currentTab == PostsTab) return [posts count];
    else if (currentTab == MembersTab) return [members count];
    else return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentTab == AboutConexusTab) {
        return [AboutConexusCell heightOfCellWithConexus:conexus atIndex:(int)indexPath.row];
        
    } else if (currentTab == PostsTab) {
        Post *post = [posts objectAtIndex:indexPath.row];
        return [PostViewCell heightOfCellWithPost:post withFullText:NO];
        
    } else if (currentTab == MembersTab) {
        return 72;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentTab == PostsTab) {
        [cell setBackgroundColor:[UIColor clearColor]];
    }
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentTab == AboutConexusTab) {
        
        static NSString *cellIdentifier = @"AboutConexusCell";
        AboutConexusCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
        
        [cell setupViewForConexus:conexus atIndex:(int)indexPath.row];
        
        return cell;
        
    } else if (currentTab == PostsTab) {
        
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
        
    } else if (currentTab == MembersTab) {
        
        CourseUser *user = [members objectAtIndex:indexPath.row];
        
        static NSString *nibName = @"UserListCell";
        static NSString *cellIdentifier = @"UserListCell";
        
        UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            [self.tableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setGroupingSeparator:@","];
        NSString *anarSeedsString = [numberFormatter stringForObjectValue:[NSNumber numberWithInt:user.userScore.subTotal]];
        
        cell.userScoreLabel.text = anarSeedsString;
        
        [cell setupViewForUser:user.user];
        
        return cell;
        
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentTab == PostsTab) {
        
        Post *post = [posts objectAtIndex:indexPath.row];
        [CNNavigationHelper openPostDetailsViewWithPost:post];
        
    } else if (currentTab == MembersTab) {
        
        CourseUser *contentUser = [members objectAtIndex:indexPath.row];
        [CNNavigationHelper openProfileViewWithUser:contentUser.user];
        
    } else {
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -60;
    if(y > h + reload_distance) {
        if (currentTab == PostsTab || currentTab == MembersTab)
            [self onLoadMoreContent];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

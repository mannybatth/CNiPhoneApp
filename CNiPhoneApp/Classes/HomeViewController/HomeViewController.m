//
//  HomeViewController.m
//  CNiPhoneApp
//
//  Created by Manny on 2/19/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "HomeViewController.h"
#import "PostViewCell.h"
#import "BaseNavigationController.h"
#import "CreatePostViewController.h"
#import "BaseRightSideBarNavigationController.h"

@interface HomeViewController () <PostViewCellDelegate,UIScrollViewDelegate>
{
    NSMutableArray *posts;
    int postsLimit;
    int postsOffset;
    BOOL loadingPosts;
    BOOL isRefreshing;
    BOOL noMorePosts;
    BOOL initialLoadDone;
    
    UITableViewLoadingFooter *tableViewLoadingFooter;
    CGFloat previousScrollViewYOffset;
}

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *toolbar;

@property (nonatomic, strong) IBOutlet UIButton *createPostBtn;

@end

@implementation HomeViewController

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
    
    self.title = @"Home";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onPostViewChanged:)
                                                 name:NOTF_POST_VIEW_CHANGED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadHomePage)
                                                 name:NOTF_REFRESH_HOME_FEED
                                               object:nil];
    
    BaseRightSideBarNavigationController *rightNavigationController = (BaseRightSideBarNavigationController*)[self.revealController rightViewController];
    [rightNavigationController popToRootViewControllerAnimated:NO];
    rightNavigationController.notificationsViewController.forceReloadOnViewAppear = YES;
    rightNavigationController.emailsViewController.forceReloadOnViewAppear = YES;
    rightNavigationController.requestsViewController.forceReloadOnViewAppear = YES;
    
    [self.tableView setScrollsToTop:YES];
    tableViewLoadingFooter = (UITableViewLoadingFooter*)self.tableView.tableFooterView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(beginRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(self.toolbar.height, 0, 0, 0)];
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.toolbar.height, 0, 0, 0);
    
    UIImage *createPostBtnBg = [UIImage imageNamed:@"create_post_btn_bg"];
    UIImage *createPostBtnBgOn = [UIImage imageNamed:@"create_post_btn_bg_on"];
    UIEdgeInsets bgInsets = UIEdgeInsetsMake(0.0f, 0.0f, 4.0f, 0.0f);
    UIImage *createPostBtnbgStretchableImage = [createPostBtnBg resizableImageWithCapInsets:bgInsets];
    UIImage *createPostBtnBgOnStretchableImage = [createPostBtnBgOn resizableImageWithCapInsets:bgInsets];
    [self.createPostBtn setBackgroundImage:createPostBtnbgStretchableImage forState:UIControlStateNormal];
    [self.createPostBtn setBackgroundImage:createPostBtnBgOnStretchableImage forState:UIControlStateHighlighted];
    
    posts = [[NSMutableArray alloc] init];
    postsLimit = 20;
    postsOffset = 0;
    [self refreshHomePosts];
}

- (void)viewWillAppear:(BOOL)animated
{
    showHomeBtn = YES;
    [super viewWillAppear:animated];
}

- (void)onBackBtnClick
{
    [self showLeftView:self];
}

- (void)beginRefresh
{
    [tableViewLoadingFooter stopLoading];
    [self refreshHomePosts];
}

- (void)reloadHomePage
{
    //currentFilter = @"New Posts";
    //currentFilterIndex = 0;
    [self refreshHomePosts];
}

- (void)refreshHomePosts
{
    noMorePosts = NO;
    loadingPosts = NO;
    postsOffset = 0;
    isRefreshing = YES;
    [tableViewLoadingFooter stopLoading];
    [self.refreshControl beginRefreshing];
    [self getHomeContents];
}

- (void)getHomeContents
{
    //self.currenFilterLabel.text = currentFilter;
    if (!loadingPosts && !noMorePosts) {
        loadingPosts = YES;
        //self.currenFilterButton.enabled = NO;
        [PostStore getHomePostsWithFilter:@"New Posts" limit:postsLimit offset:postsOffset block:^(NSArray *postsArr, NSString *error) {
            
            [tableViewLoadingFooter stopLoading];
            [self.refreshControl endRefreshing];
            loadingPosts = NO;
            isRefreshing = NO;
            //self.currenFilterButton.enabled = YES;
            if (!error) {
                if ([postsArr count] == 0) {
                    noMorePosts = YES;
                } else {
                    if (postsOffset == 0) {
                        initialLoadDone = YES;
                        posts = [postsArr mutableCopy];
                        [self.tableView reloadData];
                        
                    } else {
                        NSMutableArray *rowsToInsert = [NSMutableArray new];
                        
                        [postsArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            [rowsToInsert addObject:[NSIndexPath indexPathForItem:posts.count + idx inSection:0]];
                        }];
                        
                        [posts addObjectsFromArray:postsArr];
                        [self.tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationFade];
                    }
                }
            } else {
                // prevents repeated requests from scrolling
                noMorePosts = YES;
            }
        }];
    }
}

- (void)onLoadMorePosts
{
    if (!loadingPosts && !noMorePosts && !isRefreshing) {
        postsOffset = postsOffset+postsLimit;
        [tableViewLoadingFooter startLoading];
        [self getHomeContents];
    }
}

- (IBAction)onCreatePostBtnClick:(id)sender
{
    CreatePostViewController *createPostViewController = [[CreatePostViewController alloc] init];
    createPostViewController.visibilitySettings = [[NSMutableArray alloc] initWithArray:@[@"public"]];
    BaseNavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:createPostViewController];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
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
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationFade];
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
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
            index++;
        }
        
    }
}

#pragma mark -
#pragma mark UITableView Delegates

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 1)];
    [view setBackgroundColor:[UIColor clearColor]];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [posts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *post = [posts objectAtIndex:indexPath.row];
    CGFloat height = [PostViewCell heightOfCellWithPost:post withFullText:NO];
    return height;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 500.0f;
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Post *post = [posts objectAtIndex:indexPath.row];
    [CNNavigationHelper openPostDetailsViewWithPost:post];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.toolbar.y = 0;
    }];
	return YES;
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
        [self onLoadMorePosts];
    }
    
    if (initialLoadDone && scrollView.isDragging) {
        CGRect toolbarFrame = self.toolbar.frame;
        CGFloat toolbarHeight = toolbarFrame.size.height;
        
        CGFloat scrollDiff = offset.y - previousScrollViewYOffset;
        CGFloat scrollHeight = scrollView.frame.size.height;
        CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
        
        if (offset.y <= -scrollView.contentInset.top) {
            toolbarFrame.origin.y = 0;
        } else if ((offset.y + scrollHeight) >= scrollContentSizeHeight) {
            toolbarFrame.origin.y = -toolbarHeight;
        } else {
            toolbarFrame.origin.y = MIN(0, MAX(-toolbarHeight, toolbarFrame.origin.y - scrollDiff));
        }
        
        [self.toolbar setFrame:toolbarFrame];
        previousScrollViewYOffset = offset.y;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self stoppedScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self stoppedScrolling];
    }
}

- (void)stoppedScrolling
{
    CGRect frame = self.toolbar.frame;
    if (frame.origin.y > -43) {
        [UIView animateWithDuration:0.2 animations:^{
            self.toolbar.y = 0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.toolbar.y = -self.toolbar.height;
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

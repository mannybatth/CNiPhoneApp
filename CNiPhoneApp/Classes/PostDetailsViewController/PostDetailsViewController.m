//
//  PostDetailsViewController.m
//  CNiPhoneApp
//
//  Created by Manny on 2/22/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "PostDetailsViewController.h"
#import "PostViewCell.h"
#import "CommentViewCell.h"
#import "ShowPreviousCommentsCell.h"
#import "MBProgressHUD.h"
#import "CNTextView.h"
#import "TSMessage.h"

@interface PostDetailsViewController () <PostViewCellDelegate, CommentViewCellDelegate, CNTextViewDelegate>
{
    NSMutableArray *comments;
    int contentLimit;
    int contentOffset;
    BOOL loadingContent;
    BOOL noMoreContent;
    BOOL mainPostLoadDone;
    
    PostViewCell *postCell;
    UITableViewLoadingFooter *tableViewLoadingFooter;
    CNTextView *reflectionsTextView;
    BOOL scrollToBottomOnLoad;
}

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation PostDetailsViewController

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
    
    self.title = @"Post";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onPostViewChanged:)
                                                 name:NOTF_POST_VIEW_CHANGED
                                               object:nil];
    
    comments = [[NSMutableArray alloc] init];
    contentLimit = 10;
    contentOffset = 0;
    
    [self.tableView setScrollsToTop:YES];
    tableViewLoadingFooter = (UITableViewLoadingFooter*)self.tableView.tableFooterView;
    [tableViewLoadingFooter.view setBackgroundColor:[UIColor whiteColor]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(beginRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    reflectionsTextView = [[CNTextView alloc] initWithTableView:self.tableView
                                                          frame:CGRectMake(0, 0, 325, 47)
                                                    placeholder:@"Click to make a reflection."];
    reflectionsTextView.delegate = self;
    reflectionsTextView.submitBtn.enabled = NO;
    [self.view addSubview:reflectionsTextView];
    
    if (self.focusReflectionTextViewOnLoad) [self focusReflectionTextView];
    
    self.tableView.hidden = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PostStore getPostById:self.post.postId block:^(Post *post, NSString *error) {
        if (!error) {
            self.post = post;
            [self loadMainPost];
            mainPostLoadDone = YES;
            [self refreshReflections];
            reflectionsTextView.submitBtn.enabled = YES;
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [TSMessage showNotificationInViewController:self
                                                  title:@"Failed to get post."
                                               subtitle:nil
                                                   type:TSMessageNotificationTypeError];
        }
    }];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    reflectionsTextView.y = self.view.height - self.tableView.contentInset.bottom;
}

- (void)loadMainPost
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PostViewCell" owner:self options:nil];
    postCell = [topLevelObjects lastObject];
    
    postCell.delegate = self;
    [postCell setupViewForPost:self.post withFullText:YES];
    
    postCell.height = [PostViewCell heightOfCellWithPost:self.post withFullText:YES]-14;
    postCell.y = 2;
    postCell.backgroundView = nil;
    
    [self.tableView.tableHeaderView addSubview:postCell];
    self.tableView.tableHeaderView.height = postCell.height+postCell.y+10;
    [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
}

- (void)beginRefresh
{
    [self refreshReflections];
}

- (void)refreshReflections
{
    noMoreContent = NO;
    loadingContent = NO;
    contentOffset = 0;
    [self getPostComments];
}

- (void)onLoadMoreComments
{
    if (loadingContent == NO && noMoreContent == NO) {
        contentOffset = contentOffset+contentLimit;
        [self getPostComments];
    }
}

- (void)getPostComments
{
    loadingContent = YES;
    [PostStore getPostComments:self.post.postId limit:contentLimit offset:contentOffset block:^(NSArray *commentsArr, NSString *error) {
        loadingContent = NO;
        if (!error) {
            [tableViewLoadingFooter stopLoading];
            [self.refreshControl endRefreshing];
            if (!error) {
                if ([commentsArr count] < contentLimit) {
                    noMoreContent = YES;
                    [self.tableView reloadData];
                }
                if (contentOffset == 0) {
                    comments = [commentsArr mutableCopy];
                    [self.tableView reloadData];
                    
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    self.tableView.hidden = NO;
                } else {
                    NSMutableArray *rowsToInsert = [NSMutableArray new];
                    
                    [commentsArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [rowsToInsert addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
                    }];
                    
                    [comments addObjectsFromArray:commentsArr];
                    
                    [UIView animateWithDuration:0.3
                                     animations:^(){
                                         [self.tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationFade];
                                     }
                                     completion:^(BOOL finished) {
                                         [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:commentsArr.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                                     }];
                }
                
                if (scrollToBottomOnLoad) {
                    scrollToBottomOnLoad = NO;
                    [self scrollToBottomOfTableView];
                }
            }
            loadingContent = NO;
        }
    }];
}

- (void)focusReflectionTextView
{
    scrollToBottomOnLoad = YES;
    [reflectionsTextView.hpTextView becomeFirstResponder];
}

- (void)scrollToBottomOfTableView
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height - self.tableView.contentInset.bottom)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height + self.tableView.contentInset.bottom);
        [self.tableView setContentOffset:offset animated:YES];
    }
}

- (void)onCNTextViewSubmitClick:(NSString *)text
{
    if (!mainPostLoadDone) return;
    if ([[NSString trimWhiteSpace:text] isEqualToString:@""]) return;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [PostStore createCommentWithPostId:self.post.postId text:text block:^(Comment *comment, NSString *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!error) {
            [TSMessage showNotificationInViewController:self
                                                  title:@"Posted reflection!"
                                               subtitle:nil
                                                   type:TSMessageNotificationTypeSuccess];
            
            reflectionsTextView.hpTextView.text = @"";
            postCell.post.count.comments++;
            [postCell setupView];
            [postCell sendUpdatePostViewNotification];
            
            [comments insertObject:comment atIndex:0];
            NSIndexPath *indexPath;
            if (noMoreContent) {
                indexPath = [NSIndexPath indexPathForItem:comments.count-1 inSection:0];
            } else {
                indexPath = [NSIndexPath indexPathForItem:comments.count inSection:0];
            }
            [UIView animateWithDuration:0.3
                             animations:^(){
                                 [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                             }
                             completion:^(BOOL finished) {
                                 [self scrollToBottomOfTableView];
                             }];
            
        } else {
            [TSMessage showNotificationInViewController:self
                                                  title:@"Failed to make reflection."
                                               subtitle:nil
                                                   type:TSMessageNotificationTypeError];
        }
    }];
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    [self scrollToBottomOfTableView];
}

- (void)onPostViewChanged:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    NSString *action = [dict objectForKey:@"Action"];
    
    if ([action isEqualToString:ACTION_UPDATE_VIEW]) {
        
        Post *post = [dict objectForKey:@"Post"];
        if ([self.post.postId isEqualToString:post.postId]) {
            self.post = post;
            [self loadMainPost];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    } else if ([action isEqualToString:ACTION_DELETE_VIEW]) {
        
        Post *post = [dict objectForKey:@"Post"];
        NSArray *viewControllers = [self.navigationController viewControllers];
        for (int i = 0; i < [viewControllers count]; i++) {
            id obj = [viewControllers objectAtIndex:i];
            if ([obj isKindOfClass:[PostDetailsViewController class]]) {
                PostDetailsViewController *controller = (PostDetailsViewController*)obj;
                if ([post.postId isEqualToString:controller.post.postId]) {
                    if ([[self.navigationController visibleViewController] isKindOfClass:[PostDetailsViewController class]]) {
                        [self.navigationController popViewControllerAnimated:YES];
                    } else {
                        NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
                        [navigationArray removeObjectAtIndex:[viewControllers indexOfObject:controller]];
                        self.navigationController.viewControllers = navigationArray;
                    }
                }
            }
        }
    }
}

#pragma mark -
#pragma mark UITableView Delegates

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%i %@", self.post.count.comments, self.post.count.comments == 1 ? @"Reflection" : @"Reflections"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!noMoreContent) return [comments count]+1;
    return [comments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!noMoreContent && indexPath.row == 0) return 40;
    
    NSInteger index = noMoreContent ? indexPath.row : indexPath.row-1;
    
    Comment *comment = [comments objectAtIndex:[comments count] - index - 1];
    CGFloat height = [CommentViewCell heightOfCellWithComment:comment];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!noMoreContent && indexPath.row == 0) {
        static NSString *cellIdentifier = @"ShowPreviousCommentsCell";
        ShowPreviousCommentsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
        cell.showReflectionsLabel.hidden = NO;
        return cell;
    }
    
    static NSString *cellIdentifier = @"CommentViewCell";
    CommentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    NSInteger index = noMoreContent ? indexPath.row : indexPath.row-1;
    
    Comment *comment = [comments objectAtIndex:[comments count] - index - 1];
    cell.delegate = self;
    [cell setupViewForComment:comment];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!noMoreContent && indexPath.row == 0) {
        ShowPreviousCommentsCell *cell = (ShowPreviousCommentsCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell startLoading];
        [self onLoadMoreComments];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

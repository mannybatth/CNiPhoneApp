//
//  PostLikesViewController.m
//  CNiPhoneApp
//
//  Created by Manny on 3/14/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "PostLikesViewController.h"
#import "UserListCell.h"
#import "PostStore.h"

@interface PostLikesViewController ()
{
    NSMutableArray *users;
    int contentLimit;
    int contentOffset;
    BOOL loadingContent;
    BOOL noMoreContent;
    
    UITableViewLoadingFooter *tableViewLoadingFooter;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation PostLikesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Likes";
    
    users = [[NSMutableArray alloc] init];
    contentLimit = 10;
    contentOffset = 0;
    
    [self.tableView setScrollsToTop:YES];
    tableViewLoadingFooter = (UITableViewLoadingFooter*)self.tableView.tableFooterView;
    [tableViewLoadingFooter.view setBackgroundColor:[UIColor whiteColor]];
    
    [tableViewLoadingFooter startLoading];
    [self getLikes];
}

- (void)getLikes
{
    loadingContent = YES;
    [PostStore getPostLikes:self.post.postId limit:contentLimit offset:contentOffset block:^(NSArray *usersArr, NSString *error) {
        [tableViewLoadingFooter stopLoading];
        loadingContent = NO;
        if (!error) {
            if ([usersArr count] == 0) {
                noMoreContent = YES;
            } else {
                if (contentOffset == 0) {
                    users = [usersArr mutableCopy];
                    [self.tableView reloadData];
                    
                } else {
                    NSMutableArray *rowsToInsert = [NSMutableArray new];
                    
                    [usersArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [rowsToInsert addObject:[NSIndexPath indexPathForItem:users.count + idx inSection:0]];
                    }];
                    
                    [users addObjectsFromArray:usersArr];
                    [self.tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationFade];
                }
            }
        } else {
            // prevents repeated requests from scrolling
            noMoreContent = YES;
        }
    }];
}

- (void)onLoadMoreLikes
{
    if (loadingContent == NO && noMoreContent == NO) {
        [tableViewLoadingFooter startLoading];
        contentOffset = contentOffset+contentLimit;
        [self getLikes];
    }
}

#pragma mark -
#pragma mark UITableView Delegates

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%i Likes", self.post.count.likes];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [users count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72;
}

- (UserListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UserListCell";
    UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    User *user = [users objectAtIndex:indexPath.row];
    [cell setupViewForUser:user];
    
    cell.userScoreLabel.hidden = YES;
    cell.anarSeedsImageView.hidden = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    User *user = [users objectAtIndex:indexPath.row];
    [CNNavigationHelper openProfileViewWithUser:user];
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
        [self onLoadMoreLikes];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

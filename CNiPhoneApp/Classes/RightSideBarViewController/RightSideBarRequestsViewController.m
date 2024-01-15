//
//  RightSideBarRequestsViewController.m
//  CNiPhoneApp
//
//  Created by Manny on 3/19/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "RightSideBarRequestsViewController.h"
#import "RequestViewCell.h"
#import "RequestAcceptedViewCell.h"
#import "RequestRejectedViewCell.h"
#import "ColleageRequestStore.h"

@interface RightSideBarRequestsViewController () <RequestViewCellDelegate>
{
    NSMutableArray *requests;
    int contentLimit;
    int contentOffset;
    BOOL loadingContent;
    BOOL noMoreContent;
    BOOL initialLoadStarted;
    BOOL initialLoadDone;
    
    UITableViewLoadingFooter *tableViewLoadingFooter;
}

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation RightSideBarRequestsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setScrollsToTop:YES];
    tableViewLoadingFooter = (UITableViewLoadingFooter*)self.tableView.tableFooterView;
    [tableViewLoadingFooter.view setBackgroundColor:[UIColor whiteColor]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(beginRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    requests = [[NSMutableArray alloc] init];
    contentLimit = 20;
    contentOffset = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    notificationArrow.hidden = YES;
    mailArrow.hidden = YES;
    requestArrow.hidden = NO;
    
    if ([Session shared].currentUser.userCount.newColleagueRequests > 0 || !initialLoadStarted || self.forceReloadOnViewAppear) {
        [Session shared].currentUser.userCount.newColleagueRequests = 0;
        [self updateNavBtnBadges];
        self.forceReloadOnViewAppear = NO;
        initialLoadStarted = YES;
        [requests removeAllObjects];
        [self.tableView reloadData];
        [self refreshContent];
    } else {
        [self.tableView reloadData];
    }
}

- (void)onRequestAccepted:(ColleagueRequest *)request
{
    NSUInteger index = [requests indexOfObject:request];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)onRequestRejected:(ColleagueRequest *)request
{
    NSUInteger index = [requests indexOfObject:request];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)beginRefresh
{
    [Session shared].currentUser.userCount.newColleagueRequests = 0;
    [self updateNavBtnBadges];
    
    // remove rows that have been altered
    NSMutableArray *rowsToDelete = [NSMutableArray new];
    [requests enumerateObjectsUsingBlock:^(ColleagueRequest *request, NSUInteger idx, BOOL *stop) {
        if (request.isAccepted || request.isRejected) {
            [rowsToDelete addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
            [requests removeObjectAtIndex:idx];
        }
    }];
    [self.tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationFade];
    
    [tableViewLoadingFooter stopLoading];
    [self refreshContent];
}

- (void)refreshContent
{
    noMoreContent = NO;
    loadingContent = NO;
    contentOffset = 0;
    [tableViewLoadingFooter startLoading];
    [self getColleagueRequests];
}

- (void)onLoadMoreContent
{
    if (loadingContent == NO && noMoreContent == NO && initialLoadDone == YES) {
        [tableViewLoadingFooter startLoading];
        contentOffset = contentOffset+contentLimit;
        [self getColleagueRequests];
    }
}

- (void)getColleagueRequests
{
    if (loadingContent == NO && noMoreContent == NO) {
        loadingContent = YES;
        [ColleageRequestStore getUserColleagueRequestsWithLimit:contentLimit offset:contentOffset block:^(NSArray *requestsArr, NSString *error) {
            [tableViewLoadingFooter stopLoading];
            [self.refreshControl endRefreshing];
            if (!error) {
                if ([requestsArr count] == 0) {
                    noMoreContent = YES;
                } else {
                    if (contentOffset == 0) {
                        initialLoadDone = YES;
                        requests = [requestsArr mutableCopy];
                        [self.tableView reloadData];
                    } else {
                        NSMutableArray *rowsToInsert = [NSMutableArray new];
                        
                        [requestsArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            [rowsToInsert addObject:[NSIndexPath indexPathForItem:requests.count + idx inSection:0]];
                        }];
                        
                        [requests addObjectsFromArray:requestsArr];
                        [self.tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationFade];
                    }
                }
                
            } else {
                self.forceReloadOnViewAppear = YES;
            }
            loadingContent = NO;
        }];
    }
}

#pragma mark -
#pragma mark UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return requests.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Colleague Requests";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ColleagueRequest *request = [requests objectAtIndex:indexPath.row];
    
    if (request.isAccepted) {
        return [RequestAcceptedViewCell heightOfCellWithColleageRequest:request];
    } else if (request.isRejected) {
        return [RequestRejectedViewCell heightOfCellWithColleageRequest:request];
    }
    return [RequestViewCell heightOfCellWithColleageRequest:request];
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ColleagueRequest *request = [requests objectAtIndex:indexPath.row];
    
    if (request.isAccepted) {
        
        static NSString *cellIdentifier = @"RequestAcceptedViewCell";
        RequestAcceptedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setupViewForColleageRequest:request];
        
        return cell;
        
    } else if (request.isRejected) {
        
        static NSString *cellIdentifier = @"RequestRejectedViewCell";
        RequestRejectedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setupViewForColleageRequest:request];
        
        return cell;
        
    }
    
    static NSString *cellIdentifier = @"RequestViewCell";
    RequestViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    [cell setupViewForColleageRequest:request];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = -20;
    if(y > h + reload_distance) {
        [self onLoadMoreContent];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

//
//  RightSideBarNotificationsViewController.m
//  CNiPhoneApp
//
//  Created by Manny on 3/19/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "RightSideBarNotificationsViewController.h"
#import "NotificationViewCell.h"
#import "NotificationStore.h"

@interface RightSideBarNotificationsViewController () <NotificationViewCellDelegate>
{
    NSMutableArray *notifications;
    int contentLimit;
    int contentOffset;
    BOOL loadingContent;
    BOOL noMoreContent;
    BOOL initialLoadStarted;
    BOOL initialLoadDone;
    
    UITableViewLoadingFooter *tableViewLoadingFooter;
    NSArray *supportedNotificationTypes;
}

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation RightSideBarNotificationsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setScrollsToTop:YES];
    tableViewLoadingFooter = (UITableViewLoadingFooter*)self.tableView.tableFooterView;
    [tableViewLoadingFooter.view setBackgroundColor:[UIColor whiteColor]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(beginRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    notifications = [[NSMutableArray alloc] init];
    supportedNotificationTypes = [NSArray arrayWithObjects:
                                  @"accept_colleague",
                                  @"accept_conexus_invite",
                                  @"accept_course_invite",
                                  @"accept_join_conexus",
                                  @"accept_join_course",
                                  //@"add_attachment_comment",
                                  @"add_content_comment",
                                  @"add_follow",
                                  //@"after_register",
                                  @"answer_survey",
                                  @"expired_remind",
                                  //@"grade_quiz",
                                  //@"inform_instructor_handle_join_course",
                                  @"join_conexus",
                                  @"join_course",
                                  //@"like_attachment",
                                  @"like_content",
                                  @"mentioned",
                                  @"others_add_content_comment",
                                  @"others_like_content",
                                  //@"publish_quiz",
                                  //@"submit_quiz",
                                  @"system_message",
                                  nil];
    contentLimit = 20;
    contentOffset = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    notificationArrow.hidden = NO;
    mailArrow.hidden = YES;
    requestArrow.hidden = YES;
    
    if ([Session shared].currentUser.userCount.newNotifications > 0 || !initialLoadStarted || self.forceReloadOnViewAppear) {
        [Session shared].currentUser.userCount.newNotifications = 0;
        [self updateNavBtnBadges];
        self.forceReloadOnViewAppear = NO;
        initialLoadStarted = YES;
        [notifications removeAllObjects];
        [self.tableView reloadData];
        [self refreshContent];
    } else {
        [self.tableView reloadData];
    }
}

- (void)beginRefresh
{
    [Session shared].currentUser.userCount.newNotifications = 0;
    [self updateNavBtnBadges];
    
    [tableViewLoadingFooter stopLoading];
    [self refreshContent];
}

- (void)refreshContent
{
    noMoreContent = NO;
    loadingContent = NO;
    contentOffset = 0;
    [tableViewLoadingFooter startLoading];
    [self getNotifications];
}

- (void)onLoadMoreContent
{
    if (loadingContent == NO && noMoreContent == NO && initialLoadDone == YES) {
        [tableViewLoadingFooter startLoading];
        contentOffset = contentOffset+contentLimit;
        [self getNotifications];
    }
}

- (void)getNotifications
{
    if (loadingContent == NO && noMoreContent == NO) {
        loadingContent = YES;
        [NotificationStore getUserNotificationsWithLimit:contentLimit offset:contentOffset block:^(NSArray *notificationsArr, NSString *error) {
            [tableViewLoadingFooter stopLoading];
            [self.refreshControl endRefreshing];
            if (!error) {
                if ([notificationsArr count] == 0) {
                    noMoreContent = YES;
                } else {
                    if (contentOffset == 0) {
                        initialLoadDone = YES;
                        notifications = [notificationsArr mutableCopy];
                        [self.tableView reloadData];
                    } else {
                        NSMutableArray *rowsToInsert = [NSMutableArray new];
                        
                        [notificationsArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            [rowsToInsert addObject:[NSIndexPath indexPathForItem:notifications.count + idx inSection:0]];
                        }];
                        
                        [notifications addObjectsFromArray:notificationsArr];
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
    return notifications.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Notifications";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Notification *notification = [notifications objectAtIndex:indexPath.row];
    return [NotificationViewCell heightOfCellWithNotification:notification];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([notifications count] == 0) {
        cell.backgroundColor = [UIColor clearColor];
        return;
    }
    
    Notification *notification = [notifications objectAtIndex:indexPath.row];
    
    if ([notification.mark isEqualToString:@"unread"]) {
        cell.backgroundColor = [UIColor colorWithRed:237.0f/255.0f green:239.0f/255.0f blue:246.0f/255.0f alpha:1.0f];
    } else {
        cell.backgroundColor = [UIColor clearColor];
    }
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"NotificationViewCell";
    NotificationViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    Notification *notification = [notifications objectAtIndex:indexPath.row];
    cell.delegate = self;
    [cell setupViewForNotification:notification];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Notification *notification = [notifications objectAtIndex:indexPath.row];
    NSString *type = notification.type;
    
    if ([notification.mark isEqualToString:@"unread"]) {
        [NotificationStore setNotificationReadById:notification.notificationId block:^(BOOL success, NSString *error) {}];
        notification.mark = @"read";
    }
    
    if ([supportedNotificationTypes containsObject:type]) {
        if ([type isEqualToString:@"accept_colleague"]) {
            
            [CNNavigationHelper openProfileViewWithUser:notification.referencedUser];
            [self.revealController showViewController:self.revealController.frontViewController];
            return;
            
        } else if ([type isEqualToString:@"add_follow"]) {
            
            [CNNavigationHelper openProfileViewWithUser:notification.referencedUser];
            [self.revealController showViewController:self.revealController.frontViewController];
            return;
            
        } else if ([type isEqualToString:@"accept_conexus_invite"]) {
            
            [CNNavigationHelper openConexusViewWithConexus:notification.referencedConexus];
            [self.revealController showViewController:self.revealController.frontViewController];
            return;
            
        } else if ([type isEqualToString:@"accept_course_invite"]) {
            
            [CNNavigationHelper openCourseViewWithCourse:notification.referencedCourse];
            [self.revealController showViewController:self.revealController.frontViewController];
            return;
            
        } else if ([type isEqualToString:@"accept_join_course"]) {
            
            [CNNavigationHelper openCourseViewWithCourse:notification.referencedCourse];
            [self.revealController showViewController:self.revealController.frontViewController];
            return;
            
        } else if ([type isEqualToString:@"add_content_comment"]) {
            
            if (notification.referencedPost.postId) {
                [CNNavigationHelper openPostDetailsViewWithPost:notification.referencedPost];
                [self.revealController showViewController:self.revealController.frontViewController];
                return;
            }
            
        } else if ([type isEqualToString:@"join_course"]) {
            
            [CNNavigationHelper openCourseViewWithCourse:notification.referencedCourse];
            [self.revealController showViewController:self.revealController.frontViewController];
            
        } else if ([type isEqualToString:@"join_conexus"]) {
            
            [CNNavigationHelper openConexusViewWithConexus:notification.referencedConexus];
            [self.revealController showViewController:self.revealController.frontViewController];
            return;
            
        } else if ([type isEqualToString:@"like_content"]) {
            
            if (notification.referencedPost.postId) {
                [CNNavigationHelper openPostDetailsViewWithPost:notification.referencedPost];
                [self.revealController showViewController:self.revealController.frontViewController];
                return;
            }
            
        } else if ([type isEqualToString:@"mentioned"]) {
            
            if (notification.referencedPost.postId) {
                [CNNavigationHelper openPostDetailsViewWithPost:notification.referencedPost];
                [self.revealController showViewController:self.revealController.frontViewController];
                return;
            }
            
        } else if ([type isEqualToString:@"others_add_content_comment"]) {
            
            if (notification.referencedPost.postId) {
                [CNNavigationHelper openPostDetailsViewWithPost:notification.referencedPost];
                [self.revealController showViewController:self.revealController.frontViewController];
                return;
            }
            
        } else if ([type isEqualToString:@"expired_remind"]) {
            
            if (notification.referencedPost.postId) {
                [CNNavigationHelper openPostDetailsViewWithPost:notification.referencedPost];
                [self.revealController showViewController:self.revealController.frontViewController];
                return;
            }
            
        } else if ([type isEqualToString:@"answer_survey"]) {
            
            if (notification.referencedPost.postId) {
                [CNNavigationHelper openPostDetailsViewWithPost:notification.referencedPost];
                [self.revealController showViewController:self.revealController.frontViewController];
                return;
            }
            
        } else if ([type isEqualToString:@"others_like_content"]) {
            
            if (notification.referencedPost.postId) {
                [CNNavigationHelper openPostDetailsViewWithPost:notification.referencedPost];
                [self.revealController showViewController:self.revealController.frontViewController];
                return;
            }
            
        }
    }
    
    //[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

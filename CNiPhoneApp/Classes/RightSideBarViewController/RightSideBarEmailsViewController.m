//
//  RightSideBarEmailsViewController.m
//  CNiPhoneApp
//
//  Created by Manny on 3/19/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "RightSideBarEmailsViewController.h"
#import "EmailViewCell.h"
#import "EmailCourseInviteViewCell.h"
#import "EmailCourseInviteAcceptedViewCell.h"
#import "EmailCourseInviteIgnoredViewCell.h"
#import "EmailStore.h"
#import "UserStore.h"

@interface RightSideBarEmailsViewController () <EmailViewCellDelegate, EmailCourseInviteViewCell>
{
    NSMutableArray *messages;
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

@implementation RightSideBarEmailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setScrollsToTop:YES];
    tableViewLoadingFooter = (UITableViewLoadingFooter*)self.tableView.tableFooterView;
    [tableViewLoadingFooter.view setBackgroundColor:[UIColor whiteColor]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(beginRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    messages = [[NSMutableArray alloc] init];
    contentLimit = 20;
    contentOffset = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    notificationArrow.hidden = YES;
    mailArrow.hidden = NO;
    requestArrow.hidden = YES;
    
    if ([Session shared].currentUser.userCount.newEmails > 0 || !initialLoadStarted || self.forceReloadOnViewAppear) {
        [Session shared].currentUser.userCount.newEmails = 0;
        [self updateNavBtnBadges];
        self.forceReloadOnViewAppear = NO;
        initialLoadStarted = YES;
        [messages removeAllObjects];
        [self.tableView reloadData];
        [self refreshContent];
    } else {
        [self.tableView reloadData];
    }
}

- (void)onCourseInviteRequestAccepted:(EmailMessage *)message
{
    NSUInteger index = [messages indexOfObject:message];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    Course *course = [[Course alloc] init];
    course.courseId = message.inviteCourseId;
    [CNNavigationHelper openCourseViewWithCourse:course];
    [self.revealController showViewController:self.revealController.frontViewController];
    
    // refresh course/conexus list
    [UserStore getUserCourseConexusTab:^(NSArray *content, NSString *error) {
        
        if (!error) {
            
            NSMutableArray *courses = [NSMutableArray new];
            NSMutableArray *conexuses = [NSMutableArray new];
            [content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                if ([obj isKindOfClass:[Course class]]) {
                    [courses addObject:obj];
                    
                } else if ([obj isKindOfClass:[Conexus class]]) {
                    [conexuses addObject:obj];
                    
                }
            }];
            
            [Session shared].currentUserCourses = courses;
            [Session shared].currentUserConexus = conexuses;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTF_REFRESH_LEFT_BAR object:nil];
            
        }
        
    }];
}

- (void)onCourseInviteRequestIgnored:(EmailMessage *)message
{
    NSUInteger index = [messages indexOfObject:message];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)beginRefresh
{
    [Session shared].currentUser.userCount.newEmails = 0;
    [self updateNavBtnBadges];
    
    // remove rows that have been altered
    NSMutableArray *rowsToDelete = [NSMutableArray new];
    [messages enumerateObjectsUsingBlock:^(EmailMessage *message, NSUInteger idx, BOOL *stop) {
        if (message.isInviteAccepted || message.isInviteIgnored) {
            [rowsToDelete addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
            [messages removeObjectAtIndex:idx];
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
    [self getEmails];
}

- (void)onLoadMoreContent
{
    if (loadingContent == NO && noMoreContent == NO && initialLoadDone == YES) {
        [tableViewLoadingFooter startLoading];
        contentOffset = contentOffset+contentLimit;
        [self getEmails];
    }
}

- (void)getEmails
{
    if (loadingContent == NO && noMoreContent == NO) {
        loadingContent = YES;
        [EmailStore getUserEmailsWithLimit:contentLimit offset:contentOffset block:^(NSArray *messagesArr, NSString *error) {
            [tableViewLoadingFooter stopLoading];
            [self.refreshControl endRefreshing];
            if (!error) {
                if ([messagesArr count] == 0) {
                    noMoreContent = YES;
                } else {
                    if (contentOffset == 0) {
                        initialLoadDone = YES;
                        messages = [messagesArr mutableCopy];
                        [self.tableView reloadData];
                    } else {
                        NSMutableArray *rowsToInsert = [NSMutableArray new];
                        
                        [messagesArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            [rowsToInsert addObject:[NSIndexPath indexPathForItem:messages.count + idx inSection:0]];
                        }];
                        
                        [messages addObjectsFromArray:messagesArr];
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
    return messages.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Emails";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmailMessage *message = [messages objectAtIndex:indexPath.row];
    if ([message.type isEqualToString:@"course_invite"] && !message.isSender) {
        if (message.isInviteAccepted) {
            return [EmailCourseInviteAcceptedViewCell heightOfCellWithEmailMessage:message];
        } else if (message.isInviteIgnored) {
            return [EmailCourseInviteIgnoredViewCell heightOfCellWithEmailMessage:message];
        }
        return [EmailCourseInviteViewCell heightOfCellWithEmailMessage:message];
    } else {
        return [EmailViewCell heightOfCellWithEmailMessage:message];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([messages count] == 0) {
        cell.backgroundColor = [UIColor clearColor];
        return;
    }
    
    EmailMessage *message = [messages objectAtIndex:indexPath.row];
    
    if (message.isUnread) {
        cell.backgroundColor = [UIColor colorWithRed:237.0f/255.0f green:239.0f/255.0f blue:246.0f/255.0f alpha:1.0f];
    } else {
        cell.backgroundColor = [UIColor clearColor];
    }
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmailMessage *message = [messages objectAtIndex:indexPath.row];
    
    if ([message.type isEqualToString:@"course_invite"] && !message.isSender) {
        
        if (message.isInviteAccepted) {
            
            static NSString *cellIdentifier = @"EmailCourseInviteAcceptedViewCell";
            EmailCourseInviteAcceptedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setupViewForEmailMessage:message];
            
            return cell;
            
        } else if (message.isInviteIgnored) {
            
            static NSString *cellIdentifier = @"EmailCourseInviteIgnoredViewCell";
            EmailCourseInviteIgnoredViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
                cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setupViewForEmailMessage:message];
            
            return cell;
            
        }
        
        static NSString *cellIdentifier = @"EmailCourseInviteViewCell";
        EmailCourseInviteViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        [cell setupViewForEmailMessage:message];
        
        return cell;
        
    } else {
        
        static NSString *cellIdentifier = @"EmailViewCell";
        EmailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
        
        cell.delegate = self;
        [cell setupViewForEmailMessage:message];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmailMessage *message = [messages objectAtIndex:indexPath.row];
    
    if ([message.type isEqualToString:@"course_invite"] && !message.isSender) {
        // do nothing
    } else if ([message.type isEqualToString:@"course_invite"]) {
        if (message.isUnread) [EmailStore setEmailRead:message block:^(BOOL success, NSString *error) {}];
        message.isUnread = NO;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } else {
        if (message.isUnread) [EmailStore setEmailRead:message block:^(BOOL success, NSString *error) {}];
        message.isUnread = NO;
        
        [CNNavigationHelper openEmailDetailsViewWithMessage:message];
        [self.revealController showViewController:self.revealController.frontViewController];
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

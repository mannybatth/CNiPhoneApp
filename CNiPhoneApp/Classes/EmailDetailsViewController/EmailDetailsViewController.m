//
//  EmailDetailsViewController.m
//  CNiPhoneApp
//
//  Created by Manny on 3/21/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "EmailDetailsViewController.h"
#import "EmailDetailsViewCell.h"
#import "ShowPreviousMessagesCell.h"
#import "MBProgressHUD.h"
#import "CNTextView.h"
#import "TSMessage.h"
#import "CNButton.h"
#import "EmailStore.h"

@interface EmailDetailsViewController () <EmailMessageViewCellDelegate, CNTextViewDelegate>
{
    NSMutableArray *messages;
    int contentLimit;
    int contentOffset;
    BOOL loadingContent;
    BOOL noMoreContent;
    BOOL mainPostLoadDone;
    
    EmailMessage *parentMessage;
    UITableViewLoadingFooter *tableViewLoadingFooter;
    CNTextView *messageTextView;
    BOOL scrollToBottomOnLoad;
}

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UIScrollView *fromScrollView;
@property (nonatomic, strong) IBOutlet UIScrollView *toScrollView;
@property (nonatomic, strong) IBOutlet UIScrollView *ccScrollView;
@property (nonatomic, strong) IBOutlet UILabel *ccLabel;

@end

@implementation EmailDetailsViewController

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
    
    self.title = @"Email Message";
    
    messages = [[NSMutableArray alloc] init];
    contentLimit = 5;
    contentOffset = 0;
    
    [self.tableView setScrollsToTop:YES];
    tableViewLoadingFooter = (UITableViewLoadingFooter*)self.tableView.tableFooterView;
    [tableViewLoadingFooter.view setBackgroundColor:[UIColor whiteColor]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(beginRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    messageTextView = [[CNTextView alloc] initWithTableView:self.tableView
                                                          frame:CGRectMake(0, 0, 325, 47)
                                                    placeholder:@"Click to reply."];
    messageTextView.delegate = self;
    messageTextView.submitBtn.enabled = NO;
    [self.view addSubview:messageTextView];
    
    if (self.focusMessageTextViewOnLoad) [self focusMessageTextView];
    
    self.tableView.hidden = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self getEmailMessages];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    messageTextView.y = self.view.height - self.tableView.contentInset.bottom;
}

- (void)setupHeaderView
{
    NSArray *fromUsers = [[NSArray alloc] initWithObjects:parentMessage.sender, nil];
    NSMutableArray *toUsers = [[NSMutableArray alloc] init];
    NSMutableArray *ccUsers = [[NSMutableArray alloc] init];
    [parentMessage.receivers enumerateObjectsUsingBlock:^(User *user, NSUInteger idx, BOOL *stop) {
        if ([user.receiveType isEqualToString:@"normal"]) {
            [toUsers addObject:user];
        } else if ([user.receiveType isEqualToString:@"cc"]) {
            [ccUsers addObject:user];
        }
    }];
    
    self.fromScrollView.showsHorizontalScrollIndicator = NO;
    self.toScrollView.showsHorizontalScrollIndicator = NO;
    self.ccScrollView.showsHorizontalScrollIndicator = NO;
    
    [self addUsersToScrollView:fromUsers scrollView:self.fromScrollView];
    [self addUsersToScrollView:toUsers scrollView:self.toScrollView];
    [self addUsersToScrollView:ccUsers scrollView:self.ccScrollView];
    
    if (ccUsers.count == 0) {
        self.tableView.tableHeaderView.height = 52;
        self.ccScrollView.hidden = YES;
        self.ccLabel.hidden = YES;
        [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
    }
    self.tableView.tableHeaderView.hidden = NO;
}

- (void)addUsersToScrollView:(NSArray*)arr scrollView:(UIScrollView*)scrollView
{
    __block int nextX = 0;
    [scrollView setContentSize:CGSizeMake(0, scrollView.height)];
    [arr enumerateObjectsUsingBlock:^(User *user, NSUInteger idx, BOOL *stop) {
        
        NSString *btnTitle;
        if (idx+1 != arr.count) {
            btnTitle = [NSString stringWithFormat:@"%@,", user.displayName];
        } else {
            btnTitle = [NSString stringWithFormat:@"%@", user.displayName];
        }
        CNButton *btn = [CNButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:btnTitle forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btn setTitleColor:[UIColor colorWithRed:0.0f/255.0f green:51.0f/255.0f blue:102.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [btn setFrame:CGRectMake(0, 0, btn.frame.size.width, 21)];
        btn.center = CGPointMake(btn.center.x, btn.center.y-3);
        btn.userData = user;
        [btn addTarget:self action:@selector(onHeaderUsernameClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn sizeToFit];
        btn.x = nextX;
        [scrollView addSubview:btn];
        
        [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width+btn.width+5, scrollView.height)];
        
        nextX = nextX+btn.width+5;
    }];
}

- (void)onHeaderUsernameClick:(CNButton*)sender
{
    User *user = sender.userData;
    [CNNavigationHelper openProfileViewWithUser:user];
}

- (void)beginRefresh
{
    [self refreshContent];
}

- (void)refreshContent
{
    noMoreContent = NO;
    loadingContent = NO;
    contentOffset = 0;
    [self getEmailMessages];
}

- (void)onLoadMoreComments
{
    if (loadingContent == NO && noMoreContent == NO) {
        contentOffset = contentOffset+contentLimit;
        [self getEmailMessages];
    }
}

- (void)getEmailMessages
{
    loadingContent = YES;
    [EmailStore getEmailWithRepliesByParentId:self.parentId limit:contentLimit offset:contentOffset block:^(EmailMessage *parentMessageObj, NSArray *repliesArrResponse, NSString *error) {
        
        NSMutableArray *repliesArr = [NSMutableArray arrayWithArray:repliesArrResponse];
        
        loadingContent = NO;
        if (!error) {
            [tableViewLoadingFooter stopLoading];
            [self.refreshControl endRefreshing];
            if (!error) {
                
                if (!parentMessage) {
                    parentMessage = parentMessageObj;
                    [self setupHeaderView];
                }
                
                if ([repliesArr count] < contentLimit) {
                    noMoreContent = YES;
                    [repliesArr addObject:parentMessage];
                    [self.tableView reloadData];
                }
                if (contentOffset == 0) {
                    messages = [repliesArr mutableCopy];
                    [self.tableView reloadData];
                    
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    messageTextView.submitBtn.enabled = YES;
                    self.tableView.hidden = NO;
                } else {
                    NSMutableArray *rowsToInsert = [NSMutableArray new];
                    
                    [repliesArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [rowsToInsert addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
                    }];
                    
                    [messages addObjectsFromArray:repliesArr];
                    
                    [UIView animateWithDuration:0.3
                                     animations:^(){
                                         [self.tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationFade];
                                     }
                                     completion:^(BOOL finished) {
                                         [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:repliesArr.count inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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

- (void)focusMessageTextView
{
    scrollToBottomOnLoad = YES;
    [messageTextView.hpTextView becomeFirstResponder];
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
    if ([[NSString trimWhiteSpace:text] isEqualToString:@""]) return;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [EmailStore createReplyToParentMessage:parentMessage text:text block:^(EmailMessage *message, NSString *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!error) {
            [TSMessage showNotificationInViewController:self
                                                  title:@"Sent Reply!"
                                               subtitle:nil
                                                   type:TSMessageNotificationTypeSuccess];
            
            messageTextView.hpTextView.text = @"";
            
            [messages insertObject:message atIndex:0];
            NSIndexPath *indexPath;
            if (noMoreContent) {
                indexPath = [NSIndexPath indexPathForItem:messages.count-1 inSection:0];
            } else {
                indexPath = [NSIndexPath indexPathForItem:messages.count inSection:0];
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
                                                  title:@"Failed to sent reply."
                                               subtitle:nil
                                                   type:TSMessageNotificationTypeError];
        }
        
    }];
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    [self scrollToBottomOfTableView];
}

#pragma mark -
#pragma mark UITableView Delegates

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [NSString stringWithFormat:@"%i %@", self.post.count.comments, self.post.count.comments == 1 ? @"Reflection" : @"Reflections"];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!noMoreContent) return [messages count]+1;
    return [messages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!noMoreContent && indexPath.row == 0) return 40;
    
    NSInteger index = noMoreContent ? indexPath.row : indexPath.row-1;
    
    EmailMessage *message = [messages objectAtIndex:[messages count] - index - 1];
    CGFloat height = [EmailDetailsViewCell heightOfCellWithEmailMessage:message];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!noMoreContent && indexPath.row == 0) {
        static NSString *cellIdentifier = @"ShowPreviousMessagesCell";
        ShowPreviousMessagesCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
        cell.showMesssagesLabel.hidden = NO;
        return cell;
    }
    
    static NSString *cellIdentifier = @"EmailDetailsViewCell";
    EmailDetailsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    NSInteger index = noMoreContent ? indexPath.row : indexPath.row-1;
    
    EmailMessage *message = [messages objectAtIndex:[messages count] - index - 1];
    cell.delegate = self;
    [cell setupViewForEmailMessage:message];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!noMoreContent && indexPath.row == 0) {
        ShowPreviousMessagesCell *cell = (ShowPreviousMessagesCell*)[tableView cellForRowAtIndexPath:indexPath];
        [cell startLoading];
        [self onLoadMoreComments];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

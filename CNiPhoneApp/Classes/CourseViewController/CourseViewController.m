//
//  CourseViewController.m
//  CNApp
//
//  Created by Manpreet Singh on 7/2/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "CourseViewController.h"
#import "PostViewCell.h"
#import "UserListCell.h"
#import "TasksScrollView.h"
#import "WebViewController.h"
#import "CourseGraph.h"
#import "CourseStore.h"
#import "HMSegmentedControl.h"
#import "AboutCourseCell.h"

#define TASK_SCROLL_VIEW_HEIGHT 47
#define GRAPH_VIEW_HEIGHT 135

typedef enum {
    AboutCourseTab,
    TasksTab,
    PostsTab,
    RosterTab
} Tab;

@interface CourseViewController () <UIWebViewDelegate,PostViewCellDelegate,TasksScrollViewDelegate,CourseGraphDelegate>
{
    Tab currentTab;
    
    CourseTask *currentTask;
    CGFloat currentTaskWebViewHeight;
    BOOL reloadWebViewDone;
    
    NSMutableArray *posts;
    NSMutableArray *members;
    
    int contentLimit;
    int contentOffset;
    BOOL loadingContent;
    BOOL noMoreContent;
    BOOL initialLoadDone;
    
    BOOL hideGraph;
    BOOL hideTaskScrollView;
    UITableViewLoadingFooter *tableViewLoadingFooter;
    HMSegmentedControl *segmentedControl;
}

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UILabel *courseTitleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *courseLogoView;
@property (nonatomic, strong) IBOutlet UILabel *courseNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *courseSchoolLabel;

@property (nonatomic, strong) IBOutlet CourseGraph *courseGraph;
@property (nonatomic, strong) IBOutlet UIView *segmentContainer;
@property (nonatomic, strong) IBOutlet TasksScrollView *tasksScrollView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *courseGraphHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tasksScrollViewHeight;

@end

@implementation CourseViewController

@synthesize course;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Course";
    
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
    
    self.tableView.tableHeaderView.hidden = YES;
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    
    [CourseStore getCourseDetails:course.courseId block:^(Course *courseObj, NSString *error) {
        if (!error) {
            course = courseObj;
            
            if (course.mostCourseScoreUsers.count > 0 && course.leastCourseScoreUsers.count > 0) {
                int hightestScore = ((CourseUser*)[course.mostCourseScoreUsers objectAtIndex:0]).userScore.subTotal;
                if (!(course.count.all > 1 && hightestScore > 10)) {
                    hideGraph = YES;
                }
            } else {
                hideGraph = YES;
            }
            
            if (hideGraph) {
                self.courseGraphHeight.constant = 0.0f;
                self.tableView.tableHeaderView.height = self.tableView.tableHeaderView.height-GRAPH_VIEW_HEIGHT;
            }
            
            if (course.tasks.count > 0) {
                currentTab = TasksTab;
            } else {
                currentTab = PostsTab;
            }
            
            [self setupView];
            self.tableView.tableHeaderView.hidden = NO;
            [self.refreshControl endRefreshing];
        }
    }];
}

- (void)setupView
{
    // Logo
    [self.courseLogoView setClipsToBounds:YES];
    [self.courseLogoView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", course.logoURL]]
                        placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
    
    // Title
    self.courseTitleLabel.text = course.name;
    
    // Course Number
    self.courseNumberLabel.text = course.courseNumber;
    
    // School Name
    NSString *schoolString = (course.school.schoolName == NULL) ? @" " : course.school.schoolName;
    self.courseSchoolLabel.text = schoolString;
    
    NSArray *segmentItems = @[@"About Course", @"Tasks", @"Posts", @"Roster"];
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
    
    self.tasksScrollView.taskScrollViewDelegate = self;
    [course.tasks enumerateObjectsUsingBlock:^(CourseTask *task, NSUInteger idx, BOOL *stop) {
        [self.tasksScrollView addTaskTab:task];
    }];
    
    if (course.tasks.count > 0) {
        NSInteger indexTask = -1;
        for (CourseTask *task in [course.tasks reverseObjectEnumerator]) {
            if (task.startTimeUnixStamp) {
                if (indexTask < 0) indexTask = [course.tasks indexOfObject:task];
                if (task.startTimeUnixStamp > [[NSDate date] timeIntervalSince1970]) {
                    indexTask = [course.tasks indexOfObject:task];
                    break;
                }
            }
        }
        if (indexTask < 0) indexTask = 0;
        currentTask = [course.tasks objectAtIndex:indexTask];
        [self.tasksScrollView setSelectedItemAtIndex:indexTask selected:YES force:YES];
    } else {
        hideTaskScrollView = YES;
    }
    
    if (!hideGraph) {
        self.courseGraph.course = course;
        self.courseGraph.delegate = self;
        [self.courseGraph setupGraph];
    }
    
    [self resizeTableHeader];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)control
{
    switch ([control selectedSegmentIndex]) {
        case AboutCourseTab:
            currentTab = AboutCourseTab;
            break;
        case TasksTab:
            currentTab = TasksTab;
            break;
        case PostsTab:
            currentTab = PostsTab;
            break;
        case RosterTab:
            currentTab = RosterTab;
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

- (void)resizeTableHeader
{
    BOOL previousState = hideTaskScrollView;
    if (currentTab != TasksTab || course.tasks.count <= 0) {
        hideTaskScrollView = YES;
    } else {
        hideTaskScrollView = NO;
    }
    if (previousState != hideTaskScrollView) {
        if (hideTaskScrollView) {
            self.tasksScrollViewHeight.constant = 0.0f;
            self.tableView.tableHeaderView.height = self.tableView.tableHeaderView.height-TASK_SCROLL_VIEW_HEIGHT;
        } else {
            self.tasksScrollViewHeight.constant = TASK_SCROLL_VIEW_HEIGHT;
            self.tableView.tableHeaderView.height = self.tableView.tableHeaderView.height+TASK_SCROLL_VIEW_HEIGHT;
        }
    }
    [self.tableView setTableHeaderView:self.tableView.tableHeaderView];
}

- (void)refreshContent
{
    noMoreContent = NO;
    loadingContent = NO;
    reloadWebViewDone = NO;
    contentOffset = 0;
    [self resizeTableHeader];
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
    if (currentTab == TasksTab) {
        
        [self.refreshControl endRefreshing];
        [tableViewLoadingFooter stopLoading];
        initialLoadDone = YES;
        if (currentTab == TasksTab) [self.tableView reloadData];
        
    } else if (currentTab == PostsTab) {
        
        if (loadingContent == NO && noMoreContent == NO) {
            loadingContent = YES;
            [CourseStore getCoursePosts:course.courseId limit:contentLimit offset:contentOffset block:^(NSArray *contentsArr, NSString *error) {
                [tableViewLoadingFooter stopLoading];
                [self.refreshControl endRefreshing];
                if (!error) {
                    if ([contentsArr count] == 0) {
                        noMoreContent = YES;
                    } else {
                        if (contentOffset == 0) {
                            initialLoadDone = YES;
                            posts = [contentsArr mutableCopy];
                            if (currentTab == PostsTab) [self.tableView reloadData];
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
        
    } else if (currentTab == AboutCourseTab) {
        
        [self.refreshControl endRefreshing];
        [tableViewLoadingFooter stopLoading];
        
    } else if (currentTab == RosterTab) {
        
        if (loadingContent == NO && noMoreContent == NO) {
            loadingContent = YES;
            [CourseStore getCourseRoster:course.courseId limit:contentLimit offset:contentOffset block:^(NSArray *contentsArr, NSString *error) {
                [tableViewLoadingFooter stopLoading];
                [self.refreshControl endRefreshing];
                if (!error) {
                    if ([contentsArr count] == 0) {
                        noMoreContent = YES;
                    } else {
                        if (contentOffset == 0) {
                            initialLoadDone = YES;
                            members = [contentsArr mutableCopy];
                            if (currentTab == RosterTab) [self.tableView reloadData];
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
#pragma mark TasksScrollView Delegates

- (void)onTaskItemClick:(CourseTask *)task
{
    [CourseStore getCourseTaskDetails:task.taskId block:^(CourseTask *taskObj, NSString *error) {
        
        currentTask = taskObj;
        reloadWebViewDone = NO;
        [self.tableView reloadData];
        
    }];
}

#pragma mark -
#pragma mark UITableView Delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!initialLoadDone) return 0;
    if (currentTab == TasksTab) return 1;
    else if (currentTab == AboutCourseTab) return 6;
    else if (currentTab == PostsTab) return [posts count];
    else if (currentTab == RosterTab) return [members count];
    else return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (currentTab == PostsTab) {
        Post *post = [posts objectAtIndex:indexPath.row];
        return [PostViewCell heightOfCellWithPost:post withFullText:NO];
        
    } else if (currentTab == TasksTab) {
        if (hideTaskScrollView) {
            return 100;
        } else {
            if (currentTaskWebViewHeight == 0) return 700;
            return currentTaskWebViewHeight+5;
        }
    } else if (currentTab == AboutCourseTab) {
        return [AboutCourseCell heightOfCellWithCourse:course atIndex:(int)indexPath.row];
        
    } else if (currentTab == RosterTab) {
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
        
    } else if (currentTab == TasksTab) {
        
        static NSString *cellIdentifier;
        if (currentTask) {
            cellIdentifier = nil;
        } else {
            cellIdentifier = @"EmptyTasksTabViewCell";
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (currentTask) {
                UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10, 300, 100)];
                webView.tag = 1001;
                webView.userInteractionEnabled = YES;
                webView.backgroundColor = [UIColor clearColor];
                webView.scrollView.bounces = NO;
                webView.scrollView.scrollEnabled = NO;
                webView.opaque = NO;
                
                [cell addSubview:webView];
            }
        }
        
        if (currentTask) {
            
            UIWebView *webView = (UIWebView*)[cell viewWithTag:1001];
            webView.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
            webView.delegate = self;
            
            NSString *script = @"<script type='text/javascript'>"
                    "window.onload = function() {"
                        "var anchors = document.getElementsByTagName('a');"
                        "for (var i = 0; i < anchors.length ; i++) {"
                            "anchors[i].addEventListener('click',clicked,false);"
                        "}"
                        "function clicked(e) {"
                            "if (e.currentTarget.tagName.toLowerCase() == 'a') {"
                                "var elem = e.currentTarget;"
                                "e.preventDefault();"
                                "var attributes = {};"
                                "for (var i = 0; i < elem.attributes.length; i++) {"
                                    "var name = elem.attributes.item(i).nodeName;"
                                    "var value = elem.attributes.item(i).nodeValue;"
                                    "attributes[ name ] = value;"
                                "}"
                                "var link;"
                                "if (attributes['data-type'] == 'taskactionlink') {"
                                    "link = 'cnapp://?';"
                                    "for (var key in attributes) {"
                                        "link = link+key+'='+attributes[key]+'&';"
                                    "}"
                                    "link = link.replace('#', '');"
                                "} else {"
                                    "link = elem.href;"
                                "}"
                                "window.location.href = link;"
                                "return false;"
                            "}"
                        "}"
                    "}"
                    "</script>";
            
            NSString *html = [NSString stringWithFormat: @"<html><head><title></title></head><body style=\"background:transparent; margin:0px; \"><b>%@</b><br /><br /> <b>%@</b><br /> %@ %@</body></html>", currentTask.title, currentTask.description, currentTask.text, script];
            
            [webView loadHTMLString:html baseURL:nil];
            
        } else {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 70)];
            
            label.backgroundColor = [UIColor colorWithRed:176.0f/255.0f green:207.0f/255.0f blue:246.0f/255.0f alpha:1.0f];
            label.textColor = [UIColor colorWithRed:21.0f/255.0f green:106.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
            label.layer.borderColor = [UIColor colorWithRed:101.0f/255.0f green:164.0f/255.0f blue:242.0f/255.0f alpha:1.0f].CGColor;
            label.layer.borderWidth = 1.0f;
            label.layer.cornerRadius = 5;
            label.layer.masksToBounds = YES;
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 2;
            label.text = @"No tasks available.";
            
            [cell addSubview:label];
        }
        
        return cell;
        
    } else if (currentTab == AboutCourseTab) {
        
        static NSString *cellIdentifier = @"AboutCourseCell";
        AboutCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
        
        [cell setupViewForCourse:course atIndex:(int)indexPath.row];
        
        return cell;
        
    } else if (currentTab == RosterTab) {
        
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
        
    } else if (currentTab == RosterTab) {
        
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
        if (currentTab == PostsTab || currentTab == RosterTab)
            [self onLoadMoreContent];
    }
}

- (void)processTaskLinkClick:(NSDictionary*)parameters
{
    NSLog(@"%@", [parameters objectForKey:@"data-taskactionlink-type"]);
    if ([[parameters objectForKey:@"data-taskactionlink-type"] isEqualToString:@"view_post"]) {
        
        Post *post = [[Post alloc] init];
        post.postId = [parameters objectForKey:@"data-taskactionlink-data-id"];
        [CNNavigationHelper openPostDetailsViewWithPost:post];
        return;
        
    } else if ([[parameters objectForKey:@"data-taskactionlink-type"] isEqualToString:@"view_sharelink"]) {
        
        Post *post = [[Post alloc] init];
        post.postId = [parameters objectForKey:@"data-taskactionlink-data-id"];
        [CNNavigationHelper openPostDetailsViewWithPost:post];
        return;
        
    } else if ([[parameters objectForKey:@"data-taskactionlink-type"] isEqualToString:@"view_survey"]) {
        
        Post *post = [[Post alloc] init];
        post.postId = [parameters objectForKey:@"data-taskactionlink-data-id"];
        [CNNavigationHelper openPostDetailsViewWithPost:post];
        return;
        
    } else if ([[parameters objectForKey:@"data-taskactionlink-type"] isEqualToString:@"view_quiz"]) {
        
        Post *post = [[Post alloc] init];
        post.postId = [parameters objectForKey:@"data-taskactionlink-data-id"];
        [CNNavigationHelper openPostDetailsViewWithPost:post];
        return;
        
    } else if ([[parameters objectForKey:@"data-taskactionlink-type"] isEqualToString:@"download_attachment"]) {
        
        NSString *urlStr = [NSString stringWithFormat:@"%@/program/attachment/download/%@?task_action_id=%@", BASE_URL, [parameters objectForKey:@"data-taskactionlink-data-id"], [parameters objectForKey:@"data-taskactionlink-id"]];
        WebViewController *webViewController = [[WebViewController alloc] initWithPath:urlStr];
        [self.navigationController pushViewController:webViewController animated:YES];
        return;
        
    } else if ([[parameters objectForKey:@"data-taskactionlink-type"] isEqualToString:@"upload_attachment"]) {
        
    } else if ([[parameters objectForKey:@"data-taskactionlink-type"] isEqualToString:@"create_post"]) {
        
    } else if ([[parameters objectForKey:@"data-taskactionlink-type"] isEqualToString:@"create_survey"]) {
        
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"This link is not supported yet." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}

#pragma mark -
#pragma mark CourseGraph Delegate methods

- (void)onUserPointerClick:(User *)user
{
    [CNNavigationHelper openProfileViewWithUser:user];
}

#pragma mark -
#pragma mark UIWebView Delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqualToString:@"about"]) return YES; // inital blank page load
    
    else if ([request.URL.scheme isEqualToString:@"cnapp"]) {
        NSArray *components = [request.URL.query componentsSeparatedByString:@"&"];
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        for (NSString *component in components) {
            if (![component isEqualToString:@""]) {
                NSArray *subcomponents = [component componentsSeparatedByString:@"="];
                if (subcomponents.count > 0) {
                    [parameters setObject:[[subcomponents objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                   forKey:[[subcomponents objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
            }
        }
        
        [self processTaskLinkClick:parameters];
    } else if ([request.URL.scheme isEqualToString:@"tel"]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Call"
                                                        message:@"Do you want to call this number?"
                                               cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel" action:nil]
                                               otherButtonItems:[RIButtonItem itemWithLabel:@"Call" action:^{
                                                    [[UIApplication sharedApplication] openURL:request.URL];
                                                }], nil];
        [alert show];
    
    } else if ([request.URL.scheme isEqualToString:@"mailto"]) {
        
        [[UIApplication sharedApplication] openURL:request.URL];
        
    } else {
        
        if ([request.URL.host isEqualToString:@"connect.iu.edu"]) {
            
            UIApplication *ourApplication = [UIApplication sharedApplication];
            NSString *URLEncodedText = [request.URL.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *ourPath = [@"connectpro://" stringByAppendingString:URLEncodedText];
            NSURL *ourURL = [NSURL URLWithString:ourPath];
            if ([ourApplication canOpenURL:ourURL]) {
                [ourApplication openURL:ourURL];
            } else {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Adobe Connect"
                                      message:@"Need to install Adobe Connect Mobile app for this link to work.\n Note: Some Adobe Connect links may not work."
                                      cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel" action:nil]
                                      otherButtonItems:[RIButtonItem itemWithLabel:@"Install" action:^{
                    
                                        NSString *appUrl = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%i", ADOBE_CONNECT_APP_STORE_ID];
                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appUrl]];
                    
                                    }], nil];
                [alert show];
            }
            
        } else {
            WebViewController *webViewController = [[WebViewController alloc] initWithURL:request.URL];
            [self.navigationController pushViewController:webViewController animated:YES];
        }
        
    }
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!reloadWebViewDone) {
        reloadWebViewDone = YES;
        currentTaskWebViewHeight = webView.scrollView.contentSize.height;
        [self.tableView reloadData];
    } else {
        webView.height = currentTaskWebViewHeight;
        currentTaskWebViewHeight = 0;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

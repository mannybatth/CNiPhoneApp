//
//  YoutubeSearchViewController.m
//  CNiPhoneApp
//
//  Created by Manny on 3/12/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "YoutubeSearchViewController.h"
#import "GTLYouTube.h"
#import "Video.h"
#import "SearchYoutubeVideoViewCell.h"
#import "UITableViewLoadingFooter.h"

@interface YoutubeSearchViewController () <UISearchBarDelegate>
{
    CGRect keyboardFrame;
    GTLServiceYouTube *service;
    NSMutableArray *items;
    UITableViewLoadingFooter *tableViewLoadingFooter;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@end

@implementation YoutubeSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Add Youtube Video";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [self.tableView setScrollsToTop:YES];
    tableViewLoadingFooter = (UITableViewLoadingFooter*)self.tableView.tableFooterView;
    [tableViewLoadingFooter.view setBackgroundColor:[UIColor whiteColor]];
    
    items = [[NSMutableArray alloc] init];
    service = [[GTLServiceYouTube alloc] init];
    service.APIKey = @"AIzaSyDPX-cJ5_oIpN9zO41Z-0egTvUzrtPSk3o";
    service.shouldFetchInBackground = YES;
    
    [self.tableView setContentInset:UIEdgeInsetsMake(self.searchBar.frame.size.height+self.navigationController.navigationBar.frame.size.height+STATUS_BAR_HEIGHT, 0, 0, 0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(self.searchBar.frame.size.height+self.navigationController.navigationBar.frame.size.height+STATUS_BAR_HEIGHT, 0, 0, 0)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(onCancelBtnClick:)];
    [self.navigationItem setLeftBarButtonItem:cancelBtn animated:YES];
}

- (void)onCancelBtnClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchForVideos:(NSString*)keyword
{
    [items removeAllObjects];
    [self.tableView reloadData];
    
    GTLQueryYouTube *query = [GTLQueryYouTube queryForSearchListWithPart:@"id,snippet"];
    query.q = keyword;
    query.type = @"video";
    query.maxResults = 18;
    query.fields = @"items(id/kind,id/videoId,snippet/title)";
    query.order = kGTLYouTubeOrderRelevance;
    
    [tableViewLoadingFooter startLoading];
    [service executeQuery:query completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
        
        if (error == nil) {
            
            GTLYouTubeSearchListResponse *products = object;
            for (GTLYouTubeSearchResult *item in products) {
                
                NSMutableDictionary *dictionary = [item JSONValueForKey:@"id"];
                
                Video *video = [[Video alloc] init];
                video.title = item.snippet.title;
                video.youtubeId = [dictionary objectForKey:@"videoId"];
                video.viewUrl = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", video.youtubeId];
                [items addObject:video];
                
            }
            
        } else {
            NSLog(@"error: %@", error);
        }
        
        [tableViewLoadingFooter stopLoading];
        [self.tableView reloadData];
        
    }];
}

#pragma mark -
#pragma mark UIKeyboard Delegates

- (void)keyboardWillHide:(NSNotification *)notification
{
    float duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    keyboardFrame = CGRectZero;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.searchBar.frame.size.height+STATUS_BAR_HEIGHT+self.navigationController.navigationBar.frame.size.height, 0.0, 0.0, 0.0);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)
                     animations:^{
                         self.tableView.contentInset = contentInsets;
                         self.tableView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)keyboardWillChange:(NSNotification *)notification
{
    float duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    keyboardFrame = [self.tableView.superview convertRect:keyboardFrame fromView:nil];
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.searchBar.frame.size.height+STATUS_BAR_HEIGHT+self.navigationController.navigationBar.frame.size.height, 0.0, keyboardFrame.size.height, 0.0);
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)
                     animations:^{
                         self.tableView.contentInset = contentInsets;
                         self.tableView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark -
#pragma mark UISearchBar Delegates

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self.view endEditing:YES];
    [self searchForVideos:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        [items removeAllObjects];
        [self.tableView reloadData];
    }
}

#pragma mark -
#pragma mark UITableView Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SearchYoutubeVideoViewCell";
    SearchYoutubeVideoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    Video *video = [items objectAtIndex:indexPath.row];
    
    [cell setUpViewForVideo:video];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Video *video = [items objectAtIndex:indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(didSelectYoutubeVideo:)]) {
        [self.delegate didSelectYoutubeVideo:video];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
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

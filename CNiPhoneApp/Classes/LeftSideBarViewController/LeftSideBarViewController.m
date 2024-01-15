//
//  LeftSideBarViewController.m
//  CNApp
//
//  Created by Manpreet Singh on 6/28/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "LeftSideBarViewController.h"
#import "PKRevealController.h"
#import "CNNavigationController.h"
#import "CNNavigationHelper.h"
#import "LogoutViewController.h"
#import "EndedCoursesViewController.h"
#import "ItemListCell.h"
#import "Session.h"
#import "Course.h"
#import "Conexus.h"

@interface LeftSideBarViewController () <UITableViewDelegate>
{
    NSArray *courses;
    NSArray *conexuses;
}

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation LeftSideBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:38.0f/255.0f green:44.0f/255.0f blue:58.0f/255.0f alpha:1.0f];
    
    UIView *statusBarBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, STATUS_BAR_HEIGHT)];
    [statusBarBg setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:statusBarBg];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTableView)
                                                 name:NOTF_REFRESH_LEFT_BAR
                                               object:nil];
    [self refreshTableView];
}

- (void)refreshTableView
{
    courses = [Session shared].currentUserCourses;
    conexuses = [Session shared].currentUserConexus;
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return 0;
    return 23;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 23)];
    UIView *sideBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, sectionHeader.height)];
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 230, 23)];
    
    sectionHeader.backgroundColor = [UIColor colorWithRed:18.0f/255.0f green:25.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
    sideBar.backgroundColor = [UIColor colorWithRed:18.0f/255.0f green:25.0f/255.0f blue:35.0f/255.0f alpha:1.0f];
    
    NSString *title;
    if (section == 1) {
        title = @"MY COURSES";
        sideBar.backgroundColor = [UIColor colorWithRed:97.0f/255.0f green:146.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        sectionLabel.textColor = [UIColor colorWithRed:97.0f/255.0f green:146.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    } else if (section == 2) {
        title = @"MY CONEXUS";
        sideBar.backgroundColor = [UIColor colorWithRed:192.0f/255.0f green:141.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        sectionLabel.textColor = [UIColor colorWithRed:192.0f/255.0f green:141.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    } else if (section == 3) {
        title = @" ";   //logout
    } else {
        return nil; //Home,profile
    }
    
    sectionLabel.text = title;
    sectionLabel.backgroundColor = [UIColor clearColor];
    sectionLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    
    //[sectionHeader addSubview:sideBar];
    [sectionHeader addSubview:sectionLabel];
    
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return [courses count]+1;
    } else if (section == 2) {
        return [conexuses count];
    } else if (section == 3) {
        return 1;
    }
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor colorWithRed:38.0f/255.0f green:44.0f/255.0f blue:58.0f/255.0f alpha:1.0f];
}

- (ItemListCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LeftSideBarViewCell";
    
    ItemListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[ItemListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.imageViewFrame = CGRectMake(10, 5, 30, 30);
        cell.textLabelFrame = CGRectMake(45, 5, 175, 30);
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
        
        UIView *selectionBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        [selectionBgView setBackgroundColor:[UIColor blackColor]];
        cell.selectedBackgroundView = selectionBgView;
        
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_white_disclosure_arrow.png"]];
        cell.accessoryView = arrowView;
    } else {
        [cell.imageView cancelImageRequestOperation];
    }
    
    [cell.imageView setImage:nil];
    cell.sideBarColor = [UIColor colorWithRed:60.0f/255.0f green:67.0f/255.0f blue:82.0f/255.0f alpha:1.0f];
    
    if ([indexPath section] == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Home";
            cell.imageView.contentMode = UIViewContentModeCenter;
            cell.transparentImageViewBackground = YES;
            [cell.imageView setImage:[UIImage imageNamed:@"left_bar_home_icon.png"]];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = [Session shared].currentUser.displayName;
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            cell.transparentImageViewBackground = NO;
            [cell.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", [Session shared].currentUser.avatar]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
        }
    } else if ([indexPath section] == 1) {
        
        if (indexPath.row == courses.count) {
            
            cell.textLabel.text = @"Ended Courses";
            [cell.textLabel setFont:[UIFont systemFontOfSize:15.0f]];
            
        } else {
            Course *course = [courses objectAtIndex:indexPath.row];
            cell.textLabel.text = course.name;
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            cell.transparentImageViewBackground = NO;
            [cell.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", course.logoURL]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
            cell.sideBarColor = [UIColor colorWithRed:66.0f/255.0f green:115.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        }
        
    } else if ([indexPath section] == 2) {
        
        Conexus *conexus = [conexuses objectAtIndex:indexPath.row];
        cell.textLabel.text = conexus.name;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.transparentImageViewBackground = NO;
        [cell.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", conexus.logoURL]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
        cell.sideBarColor = [UIColor colorWithRed:200.0f/255.0f green:149.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        
    } else if ([indexPath section] == 3) {
        cell.textLabel.text = @"Logout";
        cell.imageView.contentMode = UIViewContentModeCenter;
        cell.transparentImageViewBackground = YES;
        [cell.imageView setImage:[UIImage imageNamed:@"left_bar_logout_icon.png"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        if (indexPath.row == 0) {
            
            [CNNavigationHelper openHomeViewWithRefresh:YES];
            [self.revealController showViewController:self.revealController.frontViewController];
            
        } else if (indexPath.row == 1) {
            
            [CNNavigationHelper openProfileViewWithUser:[Session shared].currentUser];
            [self.revealController showViewController:self.revealController.frontViewController];
            
        }
    } else if ([indexPath section] == 1) {
        
        if (indexPath.row == courses.count) {
            
            EndedCoursesViewController *endedCoursesViewController = [[EndedCoursesViewController alloc] init];
            [(CNNavigationController*)self.revealController.frontViewController pushViewController:endedCoursesViewController animated:NO];
            [self.revealController showViewController:self.revealController.frontViewController];
            
        } else {
            Course *course = [courses objectAtIndex:indexPath.row];
            [CNNavigationHelper openCourseViewWithCourse:course];
            [self.revealController showViewController:self.revealController.frontViewController];
        }
        
    } else if ([indexPath section] == 2) {
        
        Conexus *conexus = [conexuses objectAtIndex:indexPath.row];
        [CNNavigationHelper openConexusViewWithConexus:conexus];
        [self.revealController showViewController:self.revealController.frontViewController];
        
    } else if ([indexPath section] == 3) {
        [self onLogoutBtnClick];
    }
}

- (void)onLogoutBtnClick
{
    [self.revealController showViewController:self.revealController.frontViewController animated:NO completion:nil];
    
    LogoutViewController *logoutViewController = [[LogoutViewController alloc] init];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [((CNNavigationController*)self.revealController.frontViewController).view.layer addAnimation:transition forKey:nil];
    [(CNNavigationController*)self.revealController.frontViewController pushViewController:logoutViewController animated:NO];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

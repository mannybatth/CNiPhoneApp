//
//  EndedCoursesViewController.m
//  CNiPhoneApp
//
//  Created by Manny on 4/9/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "EndedCoursesViewController.h"
#import "CourseStore.h"
#import "UserListCell.h"

@interface EndedCoursesViewController ()
{
    NSMutableArray *courses;
    UITableViewLoadingFooter *tableViewLoadingFooter;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation EndedCoursesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Ended Courses";
    
    courses = [[NSMutableArray alloc] init];
    
    [self.tableView setScrollsToTop:YES];
    tableViewLoadingFooter = (UITableViewLoadingFooter*)self.tableView.tableFooterView;
    [tableViewLoadingFooter.view setBackgroundColor:[UIColor whiteColor]];
    
    [tableViewLoadingFooter startLoading];
    [self getCourses];
}

- (void)getCourses
{
    [CourseStore getAllUserCourses:^(NSArray *coursesArr, NSString *error) {
        
        [coursesArr enumerateObjectsUsingBlock:^(Course *course, NSUInteger idx, BOOL *stop) {
            
            if (course.isEnd == YES) {
                [courses addObject:course];
            }
            
        }];
        [tableViewLoadingFooter stopLoading];
        [self.tableView reloadData];
        
    } allowCache:NO];
}

#pragma mark -
#pragma mark UITableView Delegates

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%lu Ended Courses", (unsigned long)courses.count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [courses count];
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
    
    Course *course = [courses objectAtIndex:indexPath.row];
    
    cell.userAvatar.contentMode = UIViewContentModeScaleAspectFill;
    [cell.userAvatar setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", course.logoURL]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
    [cell.userFlag setImage:nil];
    cell.userName.text = course.name;
    
    cell.userScoreLabel.hidden = YES;
    cell.anarSeedsImageView.hidden = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Course *course = [courses objectAtIndex:indexPath.row];
    [CNNavigationHelper openCourseViewWithCourse:course];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

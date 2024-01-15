//
//  VisibilitySettingsViewController.m
//  CNiPhoneApp
//
//  Created by Manny on 3/7/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "VisibilitySettingsViewController.h"
#import "VisibilitySettingsCell.h"
#import "Session.h"
#import "Course.h"
#import "Conexus.h"

@interface VisibilitySettingsViewController ()
{
    NSArray *userCourses;
    NSArray *userConexus;
    
    NSMutableArray *courseSelections;
    NSMutableArray *conexusSelections;
    
    NSMutableArray *visibilitySettingsSelections;
    NSArray *visibilitySettingsTitles;
    NSArray *visibilitySettingsIcons;
    NSArray *visibilitySettingsValues;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation VisibilitySettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Visible To";
    
    userCourses = [Session shared].currentUserCourses;
    userConexus = [Session shared].currentUserConexus;
    
    courseSelections = [[NSMutableArray alloc] initWithCapacity:userCourses.count];
    [userCourses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [courseSelections insertObject:@NO atIndex:idx];
    }];
    
    conexusSelections = [[NSMutableArray alloc] initWithCapacity:userConexus.count];
    [userConexus enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [conexusSelections insertObject:@NO atIndex:idx];
    }];
    
    visibilitySettingsSelections = [NSMutableArray arrayWithArray:@[@NO, @NO, @NO, @NO]];
    visibilitySettingsTitles = @[@"Public", @"My Colleagues", @"My Followers", @"Only Me"];
    visibilitySettingsIcons = @[@"group_icon", @"group_icon", @"group_icon", @"group_icon"];
    visibilitySettingsValues = @[@"public", @"my_colleague", @"my_follower", @"only_me"];
    
    [visibilitySettingsValues enumerateObjectsUsingBlock:^(NSString *value, NSUInteger idx, BOOL *stop) {
        if ([self.visibilitySettings containsObject:value]) {
            [visibilitySettingsSelections replaceObjectAtIndex:idx withObject:@YES];
        }
    }];
    [self.coursesRelations enumerateObjectsUsingBlock:^(Course *course, NSUInteger idx, BOOL *stop) {
        NSUInteger index = [userCourses indexOfObject:course];
        [courseSelections replaceObjectAtIndex:index withObject:@YES];
    }];
    [self.conexusRelations enumerateObjectsUsingBlock:^(Conexus *conexus, NSUInteger idx, BOOL *stop) {
        NSUInteger index = [userConexus indexOfObject:conexus];
        [conexusSelections replaceObjectAtIndex:index withObject:@YES];
    }];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(onCancelBtnClick:)];
    [self.navigationItem setLeftBarButtonItem:cancelBtn animated:YES];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(onDoneBtnClick:)];
    [self.navigationItem setRightBarButtonItem:doneBtn animated:YES];
}

- (void)onCancelBtnClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onDoneBtnClick:(id)sender
{
    [self.visibilitySettings removeAllObjects];
    [self.coursesRelations removeAllObjects];
    [self.conexusRelations removeAllObjects];
    [visibilitySettingsSelections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj boolValue] == YES) {
            [self.visibilitySettings addObject:[visibilitySettingsValues objectAtIndex:idx]];
        }
    }];
    [courseSelections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj boolValue] == YES) {
            Course *course = [userCourses objectAtIndex:idx];
            [self.coursesRelations addObject:course];
        }
    }];
    [conexusSelections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj boolValue] == YES) {
            Conexus *conexus = [userConexus objectAtIndex:idx];
            [self.conexusRelations addObject:conexus];
        }
    }];
    if (self.visibilitySettings.count == 0 && self.coursesRelations.count == 0 && self.conexusRelations.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select at least one visibility setting." message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(onVisibilitySettingsUpdated:courses:conexus:)]) {
        [self.delegate onVisibilitySettingsUpdated:self.visibilitySettings courses:self.coursesRelations conexus:self.conexusRelations];
    }
}

#pragma mark -
#pragma mark UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int numOfSections = 1;
    if (userCourses.count > 0) numOfSections++;
    if (userConexus.count > 0) numOfSections++;
    return numOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) return userCourses.count;
    else if (section == 2) return userConexus.count;
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) return @"Courses";
    else if (section == 2) return @"Conexus";
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"VisibilitySettingsCell";
    VisibilitySettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [self.tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    } else {
        [cell.iconImageView cancelImageRequestOperation];
    }
    
    [cell.iconImageView setImage:nil];
    if (indexPath.section == 0) {
        if ([[visibilitySettingsSelections objectAtIndex:indexPath.row] boolValue] == NO) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        cell.titleLabel.text = [visibilitySettingsTitles objectAtIndex:indexPath.row];
        cell.iconImageView.contentMode = UIViewContentModeCenter;
        [cell.iconImageView setImage:[UIImage imageNamed:[visibilitySettingsIcons objectAtIndex:indexPath.row]]];
        
    } else if (indexPath.section == 1) {
        if ([[courseSelections objectAtIndex:indexPath.row] boolValue] == NO) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        Course *course = [userCourses objectAtIndex:indexPath.row];
        cell.titleLabel.text = course.name;
        cell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.iconImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", course.logoURL]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
        
    } else if (indexPath.section == 2) {
        if ([[conexusSelections objectAtIndex:indexPath.row] boolValue] == NO) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        Conexus *conexus = [userConexus objectAtIndex:indexPath.row];
        cell.titleLabel.text = conexus.name;
        cell.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.iconImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", conexus.logoURL]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [visibilitySettingsSelections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [visibilitySettingsSelections replaceObjectAtIndex:idx withObject:@NO];
            if (indexPath.row != idx) [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [courseSelections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [courseSelections replaceObjectAtIndex:idx withObject:@NO];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [conexusSelections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [conexusSelections replaceObjectAtIndex:idx withObject:@NO];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        
    } else if (indexPath.section == 1) {
        [visibilitySettingsSelections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [visibilitySettingsSelections replaceObjectAtIndex:idx withObject:@NO];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [conexusSelections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [conexusSelections replaceObjectAtIndex:idx withObject:@NO];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        
    } else if (indexPath.section == 2) {
        [visibilitySettingsSelections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [visibilitySettingsSelections replaceObjectAtIndex:idx withObject:@NO];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [courseSelections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [courseSelections replaceObjectAtIndex:idx withObject:@NO];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        
    }
    
    VisibilitySettingsCell *cell = (VisibilitySettingsCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        if ([[visibilitySettingsSelections objectAtIndex:indexPath.row] boolValue] == NO) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [visibilitySettingsSelections replaceObjectAtIndex:indexPath.row withObject:@YES];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [visibilitySettingsSelections replaceObjectAtIndex:indexPath.row withObject:@NO];
        }
        
    } else if (indexPath.section == 1) {
        if ([[courseSelections objectAtIndex:indexPath.row] boolValue] == NO) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [courseSelections replaceObjectAtIndex:indexPath.row withObject:@YES];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [courseSelections replaceObjectAtIndex:indexPath.row withObject:@NO];
        }
        
    } else if (indexPath.section == 2) {
        if ([[conexusSelections objectAtIndex:indexPath.row] boolValue] == NO) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [conexusSelections replaceObjectAtIndex:indexPath.row withObject:@YES];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [conexusSelections replaceObjectAtIndex:indexPath.row withObject:@NO];
        }
        
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

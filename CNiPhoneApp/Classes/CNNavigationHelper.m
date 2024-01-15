//
//  CNNavigationHelper.m
//  CNiPhoneApp
//
//  Created by Manny on 2/27/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "CNNavigationHelper.h"
#import "PKRevealController.h"
#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "PostDetailsViewController.h"
#import "CourseViewController.h"
#import "ConexusViewController.h"
#import "EmailDetailsViewController.h"
#import "CNNavigationController.h"

@implementation CNNavigationHelper

static CNNavigationHelper *shared = nil;
+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[CNNavigationHelper alloc] init];
    });
    return shared;
}

+ (void)openHomeView
{
    [self openHomeViewWithRefresh:NO];
}

+ (void)openHomeViewWithRefresh:(BOOL)refreshFeed
{
    NSArray *viewControllers = [[CNNavigationHelper shared].navigationController viewControllers];
    for (int i = 0; i < [viewControllers count]; i++){
        id obj = [viewControllers objectAtIndex:i];
        if ([obj isKindOfClass:[HomeViewController class]]) {
            HomeViewController *controller = (HomeViewController*)obj;
            [[CNNavigationHelper shared].navigationController popToViewController:controller animated:NO];
            if (refreshFeed) [[NSNotificationCenter defaultCenter] postNotificationName:NOTF_REFRESH_HOME_FEED object:nil];
            return;
        }
    }
    
    HomeViewController *homeViewController = [[HomeViewController alloc] init];
    [[CNNavigationHelper shared].navigationController pushViewController:homeViewController animated:NO];
    if (refreshFeed) [[NSNotificationCenter defaultCenter] postNotificationName:NOTF_REFRESH_HOME_FEED object:nil];
}

+ (void)openProfileViewWithUser:(User*)user
{
    [self openProfileViewWithUser:user navigationController:[CNNavigationHelper shared].navigationController];
}

+ (void)openProfileViewWithUser:(User*)user navigationController:(UINavigationController*)navigationController
{
    NSArray *viewControllers = [navigationController viewControllers];
    for (int i = 0; i < [viewControllers count]; i++) {
        id obj = [viewControllers objectAtIndex:i];
        if ([obj isKindOfClass:[ProfileViewController class]]) {
            ProfileViewController *controller = (ProfileViewController*)obj;
            if ([user.userId isEqualToString:controller.user.userId]) {
                [navigationController popToViewController:controller animated:YES];
                return;
            }
        }
    }
    
    ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
    profileViewController.user = user;
    [navigationController pushViewController:profileViewController animated:YES];
}

+ (void)openPostDetailsViewWithPost:(Post*)post
{
    [self openPostDetailsViewWithPost:post navigationController:[CNNavigationHelper shared].navigationController focusTextBox:NO];
}

+ (void)openPostDetailsViewWithPost:(Post*)post focusTextBox:(BOOL)focusTextBox
{
    [self openPostDetailsViewWithPost:post navigationController:[CNNavigationHelper shared].navigationController focusTextBox:focusTextBox];
}

+ (void)openPostDetailsViewWithPost:(Post *)post navigationController:(UINavigationController *)navigationController
{
    [self openPostDetailsViewWithPost:post navigationController:[CNNavigationHelper shared].navigationController focusTextBox:NO];
}

+ (void)openPostDetailsViewWithPost:(Post*)post navigationController:(UINavigationController*)navigationController focusTextBox:(BOOL)focusTextBox
{
    NSArray *viewControllers = [navigationController viewControllers];
    for (int i = 0; i < [viewControllers count]; i++) {
        id obj = [viewControllers objectAtIndex:i];
        if ([obj isKindOfClass:[PostDetailsViewController class]]) {
            PostDetailsViewController *controller = (PostDetailsViewController*)obj;
            if ([post.postId isEqualToString:controller.post.postId]) {
                controller.focusReflectionTextViewOnLoad = focusTextBox;
                if (focusTextBox) [controller focusReflectionTextView];
                [navigationController popToViewController:controller animated:YES];
                return;
            }
        }
    }
    
    PostDetailsViewController *postDetailsViewController = [[PostDetailsViewController alloc] init];
    postDetailsViewController.post = post;
    postDetailsViewController.focusReflectionTextViewOnLoad = focusTextBox;
    [navigationController pushViewController:postDetailsViewController animated:YES];
}

+ (void)openCourseViewWithCourse:(Course *)course
{
    [self openCourseViewWithCourse:course navigationController:[CNNavigationHelper shared].navigationController];
}

+ (void)openCourseViewWithCourse:(Course*)course navigationController:(UINavigationController*)navigationController
{
    NSArray *viewControllers = [navigationController viewControllers];
    for (int i = 0; i < [viewControllers count]; i++) {
        id obj = [viewControllers objectAtIndex:i];
        if ([obj isKindOfClass:[CourseViewController class]]) {
            CourseViewController *controller = (CourseViewController*)obj;
            if ([course.courseId isEqualToString:controller.course.courseId]) {
                [navigationController popToViewController:controller animated:YES];
                return;
            }
        }
    }

    CourseViewController *courseViewController = [[CourseViewController alloc] init];
    courseViewController.course = course;
    [navigationController pushViewController:courseViewController animated:YES];
}

+ (void)openConexusViewWithConexus:(Conexus *)conexus
{
    [self openConexusViewWithConexus:conexus navigationController:[CNNavigationHelper shared].navigationController];
}

+ (void)openConexusViewWithConexus:(Conexus*)conexus navigationController:(UINavigationController*)navigationController
{
    NSArray *viewControllers = [navigationController viewControllers];
    for (int i = 0; i < [viewControllers count]; i++) {
        id obj = [viewControllers objectAtIndex:i];
        if ([obj isKindOfClass:[ConexusViewController class]]) {
            ConexusViewController *controller = (ConexusViewController*)obj;
            if ([conexus.conexusId isEqualToString:controller.conexus.conexusId]) {
                [navigationController popToViewController:controller animated:YES];
                return;
            }
        }
    }

    ConexusViewController *conexusViewController = [[ConexusViewController alloc] init];
    conexusViewController.conexus = conexus;
    [navigationController pushViewController:conexusViewController animated:YES];
}

+ (void)openEmailDetailsViewWithMessage:(EmailMessage *)message
{
    [self openEmailDetailsViewWithMessage:message navigationController:[CNNavigationHelper shared].navigationController];
}

+ (void)openEmailDetailsViewWithMessage:(EmailMessage *)message navigationController:(UINavigationController*)navigationController
{
    NSString *parentId = ([message.parentEmailId isEqualToString:@""]) ? message.emailId : message.parentEmailId;

    NSArray *viewControllers = [navigationController viewControllers];
    for (int i = 0; i < [viewControllers count]; i++) {
        id obj = [viewControllers objectAtIndex:i];
        if ([obj isKindOfClass:[EmailDetailsViewController class]]) {
            EmailDetailsViewController *controller = (EmailDetailsViewController*)obj;
            if ([parentId isEqualToString:controller.parentId]) {
                //if (message.isUnread) [controller refreshContent];
                [navigationController popToViewController:controller animated:NO];
                return;
            }
        }
    }

    EmailDetailsViewController *emailDetailsViewController = [[EmailDetailsViewController alloc] init];
    emailDetailsViewController.parentId = parentId;
    [navigationController pushViewController:emailDetailsViewController animated:NO];
}

@end

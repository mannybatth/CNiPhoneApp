//
//  CNNavigationHelper.h
//  CNiPhoneApp
//
//  Created by Manny on 2/27/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "User.h"
#import "Post.h"
#import "Course.h"
#import "Conexus.h"
#import "Conexus.h"
#import "EmailMessage.h"

@class CNNavigationController;

@interface CNNavigationHelper : NSObject

@property (nonatomic, strong) CNNavigationController *navigationController;

+ (instancetype)shared;

+ (void)openHomeView;
+ (void)openHomeViewWithRefresh:(BOOL)refreshFeed;
+ (void)openProfileViewWithUser:(User*)user;
+ (void)openProfileViewWithUser:(User*)user navigationController:(UINavigationController*)navigationController;
+ (void)openPostDetailsViewWithPost:(Post*)post;
+ (void)openPostDetailsViewWithPost:(Post*)post focusTextBox:(BOOL)focusTextBox;
+ (void)openPostDetailsViewWithPost:(Post*)post navigationController:(UINavigationController*)navigationController;
+ (void)openPostDetailsViewWithPost:(Post*)post navigationController:(UINavigationController*)navigationController focusTextBox:(BOOL)focusTextBox;
+ (void)openCourseViewWithCourse:(Course*)course;
+ (void)openCourseViewWithCourse:(Course*)course navigationController:(UINavigationController*)navigationController;
+ (void)openConexusViewWithConexus:(Conexus*)conexus;
+ (void)openConexusViewWithConexus:(Conexus*)conexus navigationController:(UINavigationController*)navigationController;
+ (void)openEmailDetailsViewWithMessage:(EmailMessage*)message;
+ (void)openEmailDetailsViewWithMessage:(EmailMessage*)message navigationController:(UINavigationController*)navigationController;

@end

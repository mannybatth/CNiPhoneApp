//
//  CourseGraph.h
//  CNApp
//
//  Created by Manpreet Singh on 8/5/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "UserPointer.h"

@protocol CourseGraphDelegate <NSObject>

@optional
- (void)onUserPointerClick:(User*)user;

@end

@interface CourseGraph : UIView

@property (nonatomic, strong) Course *course;

@property (nonatomic,weak) UIViewController<CourseGraphDelegate> *delegate;

- (void)resetGraph;
- (void)setupGraph;

@end

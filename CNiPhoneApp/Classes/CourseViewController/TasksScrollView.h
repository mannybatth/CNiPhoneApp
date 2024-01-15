//
//  TasksScrollView.h
//  CNApp
//
//  Created by Manpreet Singh on 7/24/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "TasksScrollViewItem.h"

@protocol TasksScrollViewDelegate <NSObject>

@optional
- (void)onTaskItemClick:(CourseTask*)task;

@end

@interface TasksScrollView : UIView

@property (nonatomic, weak) UIViewController<TasksScrollViewDelegate> *taskScrollViewDelegate;
@property (nonatomic, strong) UIScrollView *scrollView;

- (void)addTaskTab:(CourseTask *)task;
- (TasksScrollViewItem*)getItemAtIndex:(int)index;
- (void)setSelectedItemAtIndex:(NSInteger)index selected:(BOOL)selected;
- (void)setSelectedItemAtIndex:(NSInteger)index selected:(BOOL)selected force:(BOOL)force;

@end

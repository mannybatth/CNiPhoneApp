//
//  TasksScrollViewItem.h
//  CNApp
//
//  Created by Manpreet Singh on 7/24/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "CourseTask.h"

@interface TasksScrollViewItem : UIView

@property (nonatomic, strong) CourseTask *task;
@property (nonatomic, strong) UIButton *btn;
@property (nonatomic, copy) void (^tapBlock)(TasksScrollViewItem *item);
@property (nonatomic) NSInteger index;

- (id)initWithTask:(CourseTask*)task frame:(CGRect)frame color:(UIColor *)color block:(void(^)(TasksScrollViewItem *item))block;
- (void)setSelected:(BOOL)selected;
- (void)performBlockAction;

@end

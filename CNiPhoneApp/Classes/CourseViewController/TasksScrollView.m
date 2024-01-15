//
//  TasksScrollView.m
//  CNApp
//
//  Created by Manpreet Singh on 7/24/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "TasksScrollView.h"

@interface TasksScrollView () <UIScrollViewDelegate>
{
    NSMutableArray *items;
    NSArray *taskColors;
    NSInteger currentIndex;
    
    BOOL isScrolling;
}

@end

@implementation TasksScrollView

@synthesize scrollView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setupView];
}

- (void)setupView
{
    items = [[NSMutableArray alloc] init];
    currentIndex = 0;
    
    self.clipsToBounds = YES;
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, self.frame.size.height)];
    scrollView.pagingEnabled = YES;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    scrollView.clipsToBounds = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    scrollView.center = CGPointMake(self.frame.size.width/2, scrollView.center.y);
    [self addSubview:scrollView];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    singleTapGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:singleTapGesture];
    
    //[self setBackgroundColor:[UIColor colorWithRed:162.0f/255.0f green:162.0f/255.0f blue:162.0f/255.0f alpha:1.0f]];
    [self setBackgroundColor:[UIColor colorWithWhite:0.5f alpha:1.0f]];
    
    taskColors = [NSArray arrayWithObjects:
                  [UIColor clearColor],
                  [UIColor colorWithRed: 39.0f/255.0f green:128.0f/255.0f blue:  0.0f/255.0f alpha:1.0f],   // green
                  [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:  0.0f/255.0f alpha:1.0f],   // yellow
                  [UIColor colorWithRed:246.0f/255.0f green: 25.0f/255.0f blue:  0.0f/255.0f alpha:1.0f],   // red
                  [UIColor colorWithRed:250.0f/255.0f green:167.0f/255.0f blue:  0.0f/255.0f alpha:1.0f],   // orange
                  [UIColor colorWithRed:122.0f/255.0f green:  0.0f/255.0f blue:133.0f/255.0f alpha:1.0f],   // purple
                  nil];
}

- (void)addTaskTab:(CourseTask *)task
{
    UIColor *color;
    if (taskColors.count > task.titleColor) {
        [taskColors objectAtIndex:task.titleColor];
    } else {
        color = [UIColor clearColor];
    }
    CGRect itemFrame = CGRectMake(0, 0, 200, scrollView.frame.size.height);
    TasksScrollViewItem *item = [[TasksScrollViewItem alloc] initWithTask:task frame:itemFrame color:color block:^(TasksScrollViewItem *item) {
        
        [items enumerateObjectsUsingBlock:^(TasksScrollViewItem *obj, NSUInteger idx, BOOL *stop) {
            [obj setSelected:NO];
        }];
        [item setSelected:YES];
        
        if ([self.taskScrollViewDelegate respondsToSelector:@selector(onTaskItemClick:)]) {
            [self.taskScrollViewDelegate onTaskItemClick:item.task];
        }
    }];
    item.index = items.count;
    
    [scrollView addSubview:item];
    [items addObject:item];
    [self updateSubViewPositions];
}

- (void)updateSubViewPositions
{
    [items enumerateObjectsUsingBlock:^(TasksScrollViewItem *item, NSUInteger idx, BOOL *stop) {
        
        item.center = CGPointMake(200*idx + scrollView.frame.size.width/2,
                                  scrollView.frame.size.height/2);
        
    }];
    scrollView.contentSize = CGSizeMake(200*items.count, scrollView.frame.size.height);
}

- (TasksScrollViewItem*)getItemAtIndex:(int)index
{
    if (items.count > index)
        return [items objectAtIndex:index];
    return nil;
}

- (void)setSelectedItemAtIndex:(NSInteger)index selected:(BOOL)selected
{
    [self setSelectedItemAtIndex:index selected:selected force:NO];
}

- (void)setSelectedItemAtIndex:(NSInteger)index selected:(BOOL)selected force:(BOOL)force
{
    if (currentIndex == index && !force) return;
    currentIndex = index;
    [items enumerateObjectsUsingBlock:^(TasksScrollViewItem *item, NSUInteger idx, BOOL *stop) {
        if (idx == index) {
            [item setSelected:selected];
            if (selected) {
                [item performBlockAction];
                [scrollView scrollRectToVisible:item.frame animated:YES];
            }
        } else {
            [item setSelected:NO];
            /*if (idx == index-1) {
                item.btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            } else if (idx == index+1) {
                item.btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            }*/
        }
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isScrolling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    isScrolling = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    isScrolling = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    int page = scrollView.contentOffset.x/scrollView.frame.size.width;
    [self setSelectedItemAtIndex:page selected:YES];
}

- (TasksScrollViewItem *) itemAtLocation:(CGPoint) touchLocation {
    for (TasksScrollViewItem *subView in scrollView.subviews)
        if (CGRectContainsPoint(subView.frame, touchLocation))
            return subView;
    return nil;
}

#pragma mark - Handle Tap To Change Page

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    if (!isScrolling) {
        TasksScrollViewItem *selectedItem = [self itemAtLocation:[gesture locationInView:scrollView]];
        if (selectedItem) {
            NSInteger index = [items indexOfObject:selectedItem];
            if (index != currentIndex) {
                isScrolling = YES;
                [self setSelectedItemAtIndex:index selected:YES];
            }
        }
    }
}

@end

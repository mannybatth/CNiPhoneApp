//
//  TasksScrollViewItem.m
//  CNApp
//
//  Created by Manpreet Singh on 7/24/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "TasksScrollViewItem.h"

@interface TasksScrollViewItem ()
{
    CALayer *rightBorder;
    CALayer *leftBorder;
    CALayer *bottomBorder;
}

@end
@implementation TasksScrollViewItem

@synthesize btn;

- (id)initWithTask:(CourseTask*)task frame:(CGRect)frame color:(UIColor *)color block:(void(^)(TasksScrollViewItem *item))block
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.tapBlock = block;
        self.task = task;
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:14.0f]];
        [btn setTitle:task.title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [btn setContentEdgeInsets:UIEdgeInsetsMake(15, 10, 10, 10)];
        [btn addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, btn.frame.size.width-10, 4)];
        colorView.center = CGPointMake(btn.center.x, btn.frame.size.height);
        colorView.backgroundColor = color;
        
        [self addSubview:btn];
        [self addSubview:colorView];
        
        [self setSelected:NO];
        
        rightBorder = [CALayer layer];
        rightBorder.borderColor = [UIColor darkGrayColor].CGColor;
        rightBorder.borderWidth = 1;
        
        leftBorder = [CALayer layer];
        leftBorder.borderColor = [UIColor darkGrayColor].CGColor;
        leftBorder.borderWidth = 1;
        
        bottomBorder = [CALayer layer];
        bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
        bottomBorder.borderWidth = 1;
        
    }
    return self;
}

- (void)onBtnClick:(UIButton*)sender
{
    //[self performBlockAction];
}

- (void)performBlockAction
{
    if (self.tapBlock) {
        self.tapBlock(self);
    }
}

- (void)setSelected:(BOOL)selected
{
    [rightBorder removeFromSuperlayer];
    [leftBorder removeFromSuperlayer];
    [bottomBorder removeFromSuperlayer];
    
    rightBorder.frame = CGRectMake(self.frame.size.width-1, 1, 1, self.frame.size.height-1);
    leftBorder.frame = CGRectMake(0, 1, 1, self.frame.size.height-1);
    bottomBorder.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
    
    if (selected) {
        [self.layer addSublayer:rightBorder];
        if (self.index == 0) [self.layer addSublayer:leftBorder];
        [UIView animateWithDuration:0.2f animations:^{
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [self setBackgroundColor:[UIColor colorWithRed:217.0f/255.0f green:217.0f/255.0f blue:217.0f/255.0f alpha:1.0f]];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }];
        
    } else {
        [self setBackgroundColor:[UIColor colorWithRed:185.0f/255.0f green:185.0f/255.0f blue:185.0f/255.0f alpha:1.0f]];
        //[self setBackgroundColor:[UIColor colorWithRed:36.0f/255.0f green:105.0f/255.0f blue:187.0f/255.0f alpha:1.0f]];
        //[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self.layer addSublayer:rightBorder];
        [self.layer addSublayer:bottomBorder];
        if (self.index == 0) [self.layer addSublayer:leftBorder];
    }
    
}


@end

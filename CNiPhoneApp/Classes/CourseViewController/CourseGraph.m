//
//  CourseGraph.m
//  CNApp
//
//  Created by Manpreet Singh on 8/5/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "CourseGraph.h"

@interface CourseGraph()
{
    UIColor *redBarColor;
    UIColor *lightRedBarColor;
    UIColor *greenBarColor;
    UIColor *lightGreenBarColor;
    UIColor *orangeBarColor;
    UIColor *lightOrangeBarColor;
    UIColor *blueBarColor;
    UIColor *lightBlueBarColor;
    
    UIView *graphBarContainer;
    UIView *graphBar;
    UIView *graphGoalBar;
    
    float userScore;
    float goalScore;
    UserPointer *userPointer;
    CADisplayLink *displayLink;
    CFTimeInterval startTime;
    float duration;
}

@end
@implementation CourseGraph

@synthesize course;

- (void)awakeFromNib
{
    redBarColor = [UIColor colorWithRed:205.0f/255.0f green:19.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    lightRedBarColor = [UIColor colorWithRed:245.0f/255.0f green:208.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
    
    blueBarColor = [UIColor colorWithRed:50.0f/255.0f green:127.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    lightBlueBarColor = [UIColor colorWithRed:214.0f/255.0f green:229.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    
    greenBarColor = [UIColor colorWithRed:100.0f/255.0f green:170.0f/255.0f blue:38.0f/255.0f alpha:1.0f];
    lightGreenBarColor = [UIColor colorWithRed:224.0f/255.0f green:238.0f/255.0f blue:212.0f/255.0f alpha:1.0f];
    
    orangeBarColor = [UIColor colorWithRed:249.0f/255.0f green:174.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    lightOrangeBarColor = [UIColor colorWithRed:254.0f/255.0f green:239.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
}

- (void)resetGraph
{
    userPointer.x = 0;
    
    CGMutablePathRef initalPath = CGPathCreateMutable();
    CGPathMoveToPoint(initalPath, NULL, 0, 0);
    CGPathAddLineToPoint(initalPath, NULL, 0, 0);
    CGPathAddLineToPoint(initalPath, NULL, 0, graphBarContainer.height);
    CGPathAddLineToPoint(initalPath, NULL, 0, graphBarContainer.height);
    CGPathCloseSubpath(initalPath);
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = graphBar.layer.bounds;
    maskLayer.fillColor = [[UIColor blackColor] CGColor];
    maskLayer.path = initalPath;
    graphBar.layer.mask = maskLayer;
    
    [userPointer setScore:0.0f];
}

- (void)setupGraph
{
    for (UIImageView *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
    
    UIColor *barLightColor;
    UIColor *barDarkColor;
    graphBarContainer = [[UIView alloc] initWithFrame:CGRectMake(12, 60, 260, 15)];
    
    User *highScoreUser = ((CourseUser*)[course.mostCourseScoreUsers objectAtIndex:0]).user;
    float averageScore = course.courseScore.averageScore;
    userScore = course.userScore.subTotal;
    float hightestScore = ((CourseUser*)[course.mostCourseScoreUsers objectAtIndex:0]).userScore.subTotal;
    float lowestScore = ((CourseUser*)[course.leastCourseScoreUsers objectAtIndex:0]).userScore.subTotal;
    goalScore = course.courseScoreSetting.requiredNumber;
    
    if (userScore < lowestScore) userScore = lowestScore;
    BOOL showGoalBar = YES;
    if (goalScore > hightestScore || goalScore <= 0) {
        showGoalBar = NO;
    }
    barDarkColor = orangeBarColor;
    barLightColor = lightOrangeBarColor;
    
    BOOL showUserPointer = YES;
    if ([highScoreUser.userId isEqualToString:[Session shared].currentUser.userId]) {
        showUserPointer = NO;
    }
    
    float userPercent = userScore/hightestScore;
    float goalPercent = goalScore/hightestScore;
    float averagePercent = averageScore/hightestScore;
    float userBarWidth = ceilf(graphBarContainer.width*userPercent);
    float goalBarWidth = ceilf(graphBarContainer.width*goalPercent);
    float averageArrowX = ceilf(graphBarContainer.width*averagePercent);
    
    NSLog(@"userPercent: %f", userPercent);
    NSLog(@"userBarWidth: %f", userBarWidth);
    NSLog(@"goalBarWidth: %f", goalBarWidth);
    NSLog(@"averageArrowX: %f", averageArrowX);
    NSLog(@"My score: %f", userScore);
    NSLog(@"highest score: %f", hightestScore);
    NSLog(@"lowest score: %f", lowestScore);
    NSLog(@"average score: %f", averageScore);
    NSLog(@"goal score: %f", goalScore);
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setGroupingSeparator:@","];
    NSString *anarSeedsLabelStr;
    if (goalScore > 0) {
        anarSeedsLabelStr = [NSString stringWithFormat:@"%@ of %@ Anar Seeds", [numberFormatter stringForObjectValue:[NSNumber numberWithInt:userScore]],
                             [numberFormatter stringForObjectValue:[NSNumber numberWithInt:goalScore]]];
    } else {
        anarSeedsLabelStr = [NSString stringWithFormat:@"%@ Anar Seeds", [numberFormatter stringForObjectValue:[NSNumber numberWithInt:userScore]]];
    }
    UILabel *anarSeedsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 0)];
    anarSeedsLabel.font = [UIFont systemFontOfSize:22];
    anarSeedsLabel.backgroundColor = [UIColor whiteColor];
    anarSeedsLabel.textColor = [UIColor blackColor];
    anarSeedsLabel.text = anarSeedsLabelStr;
    [anarSeedsLabel sizeToFit];
    [self addSubview:anarSeedsLabel];
    
    anarSeedsLabel.center = CGPointMake(self.superview.bounds.size.width/2+10, 20);
    
    UIImageView *anarSeedsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"anar.png"]];
    anarSeedsImageView.frame = CGRectMake(0, 0, 28, 28);
    anarSeedsImageView.layer.position = CGPointMake(anarSeedsLabel.layer.position.x-(anarSeedsLabel.width/2)-anarSeedsImageView.width+10, anarSeedsLabel.layer.position.y);
    [self addSubview:anarSeedsImageView];
    
    
    UIView *graphRoundContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, graphBarContainer.width, graphBarContainer.height)];
    graphBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, graphBarContainer.width, graphBarContainer.height)];
    graphGoalBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, goalBarWidth, graphBarContainer.height)];
    UIView *graphGoalWhiteMark = [[UIView alloc] initWithFrame:CGRectMake(goalBarWidth, 0, 1, graphBarContainer.height)];
    UIView *graphGoalBlackMark = [[UIView alloc] initWithFrame:CGRectMake(goalBarWidth, 0, 1, graphBarContainer.height)];
    UIImageView *graphGoalIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"course_graph_goal_icon.png"]];
    UILabel *lowestScoreNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 21)];
    
    UIView *graphAveragePointer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 39, 19)];
    UIImageView *graphAverageArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"course_graph_mean_arrow.png"]];
    UILabel *graphAverageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 39, 13)];
    UIView *graphAverageWhiteMark = [[UIView alloc] initWithFrame:CGRectMake(averageArrowX, 0, 1, graphBarContainer.height)];
    UIView *graphAverageBlackMark = [[UIView alloc] initWithFrame:CGRectMake(averageArrowX, 0, 1, graphBarContainer.height)];
    
    userPointer = [[UserPointer alloc] initWithFrame:CGRectMake(0, 0, 28, 33) imageURL:[Session shared].currentUser.avatar direction:Up];
    userPointer.user = [Session shared].currentUser;
    [userPointer setScore:userScore];
    
    UIImage *graphBgImage = [[UIImage imageNamed:@"course_graph_bg.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:12];
    UIImageView *graphBgImageView = [[UIImageView alloc] initWithImage:graphBgImage];
    
    graphBgImageView.frame = CGRectMake(0, 0, graphBarContainer.width, graphBarContainer.height);
    
    graphRoundContainer.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
    graphGoalWhiteMark.backgroundColor = [UIColor whiteColor];
    graphGoalBlackMark.backgroundColor = [UIColor grayColor];
    graphGoalBar.backgroundColor = barLightColor;
    graphBar.backgroundColor = barDarkColor;
    
    graphRoundContainer.layer.borderWidth = 1.0f;
    graphRoundContainer.layer.borderColor = [[UIColor colorWithRed:180.0f/255.0f green:180.0f/255.0f blue:180.0f/255.0f alpha:1.0f] CGColor];
    graphRoundContainer.layer.cornerRadius = 6;
    graphRoundContainer.clipsToBounds = YES;
    
    lowestScoreNumLabel.text = [NSString stringWithFormat:@"%.0f", lowestScore];
    lowestScoreNumLabel.backgroundColor = [UIColor clearColor];
    lowestScoreNumLabel.textColor = [UIColor colorWithRed:161.0f/255.0f green:161.0f/255.0f blue:161.0f/255.0f alpha:1.0f];
    lowestScoreNumLabel.textAlignment = NSTextAlignmentCenter;
    lowestScoreNumLabel.font = [UIFont boldSystemFontOfSize:13];
    lowestScoreNumLabel.center = CGPointMake(graphBarContainer.x+6, graphBarContainer.y-9);
    
    graphAverageLabel.text = @"Average";
    graphAverageLabel.backgroundColor = [UIColor clearColor];
    graphAverageLabel.textColor = [UIColor blackColor];
    graphAverageLabel.font = [UIFont systemFontOfSize:10];
    
    graphAverageArrow.layer.anchorPoint = CGPointMake(0.5, 1.0);
    graphAverageArrow.layer.position = CGPointMake(graphAveragePointer.width/2, 0);
    
    graphAverageWhiteMark.backgroundColor = [UIColor whiteColor];
    graphAverageBlackMark.backgroundColor = [UIColor grayColor];
    
    graphAveragePointer.backgroundColor = [UIColor colorWithRed:251.0f/255.0f green:251.0f/255.0f blue:251.0f/255.0f alpha:1.0f];
    graphAveragePointer.layer.anchorPoint = CGPointMake(0.5, 0.0);
    graphAveragePointer.center = CGPointMake(graphBarContainer.x+graphBar.x+averageArrowX, graphBarContainer.y+graphBarContainer.height+9);
    
    userPointer.layer.anchorPoint = CGPointMake(0.5, 0.0);
    userPointer.center = CGPointMake(12, graphBarContainer.y+graphBarContainer.height+3);
    [userPointer addTarget:self action:@selector(onUserPointerClick:) forControlEvents:UIControlEventTouchUpInside];
    
    graphGoalIcon.layer.anchorPoint = CGPointMake(0.0, 0.5);
    graphGoalIcon.center = CGPointMake(graphBarContainer.x+goalBarWidth-4, graphBarContainer.y-9);
    
    if (highScoreUser.userId) {
        UserPointer *highUserPointer = [[UserPointer alloc] initWithFrame:CGRectMake(0, 0, 28, 33) imageURL:highScoreUser.avatar  direction:Left];
        highUserPointer.user = highScoreUser;
        [highUserPointer setScore:hightestScore];
        [highUserPointer addTarget:self action:@selector(onUserPointerClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:highUserPointer];
        highUserPointer.layer.anchorPoint = CGPointMake(0.0, 0.5);
        highUserPointer.center = CGPointMake(graphBarContainer.x+graphBarContainer.width+2, graphBarContainer.y+graphBarContainer.height/2+2);
    }
    
    [self addSubview:lowestScoreNumLabel];
    if (showGoalBar) [self addSubview:graphGoalIcon];
    if (showGoalBar) [graphGoalBar addSubview:graphGoalBlackMark];
    if (showGoalBar) [graphBar addSubview:graphGoalWhiteMark];
    if (showGoalBar) [graphRoundContainer addSubview:graphGoalBar];
    if (averageScore) [graphRoundContainer addSubview:graphAverageBlackMark];
    if (averageScore) [graphBar addSubview:graphAverageWhiteMark];
    if (averageScore) [graphAveragePointer addSubview:graphAverageLabel];
    if (averageScore) [graphAveragePointer addSubview:graphAverageArrow];
    if (averageScore) [self addSubview:graphAveragePointer];
    [graphRoundContainer addSubview:graphBar];
    [graphBarContainer addSubview:graphRoundContainer];
    [self addSubview:graphBarContainer];
    if (showUserPointer) [self addSubview:userPointer];
    
    // Add Goal
    /*int goalX = (gp > 0.16) ? -40 : 10;
     UILabel *goalBlackLabel = [[UILabel alloc] initWithFrame:CGRectMake(g+goalX, 0, 36, graphBarContainer.height)];
     goalBlackLabel.text = @"GOAL";
     goalBlackLabel.font = [UIFont boldSystemFontOfSize:12];
     goalBlackLabel.textColor = [UIColor blackColor];
     goalBlackLabel.backgroundColor = [UIColor clearColor];
     [graphGoalBar addSubview:goalBlackLabel];
     
     UILabel *goalWhiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(g+goalX, 0, 100, graphBarContainer.height)];
     goalWhiteLabel.text = @"GOAL";
     goalWhiteLabel.font = [UIFont boldSystemFontOfSize:12];
     goalWhiteLabel.textColor = [UIColor whiteColor];
     goalWhiteLabel.backgroundColor = [UIColor clearColor];
     [graphBar addSubview:goalWhiteLabel];*/
    
    // Animate Bar
    CGMutablePathRef initalPath = CGPathCreateMutable();
    CGPathMoveToPoint(initalPath, NULL, 0, 0);
    CGPathAddLineToPoint(initalPath, NULL, 0, 0);
    CGPathAddLineToPoint(initalPath, NULL, 0, graphBarContainer.height);
    CGPathAddLineToPoint(initalPath, NULL, 0, graphBarContainer.height);
    CGPathCloseSubpath(initalPath);
    
    CGMutablePathRef newPath = CGPathCreateMutable();
    CGPathMoveToPoint(newPath, NULL, 0, 0);
    CGPathAddLineToPoint(newPath, NULL, userBarWidth, 0);
    CGPathAddLineToPoint(newPath, NULL, userBarWidth, graphBarContainer.height);
    CGPathAddLineToPoint(newPath, NULL, 0, graphBarContainer.height);
    CGPathCloseSubpath(newPath);
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = graphBar.layer.bounds;
    maskLayer.fillColor = [[UIColor blackColor] CGColor];
    maskLayer.path = initalPath;
    graphBar.layer.mask = maskLayer;
    
    if (showUserPointer) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
        [anim setFromValue:(__bridge id)initalPath];
        [anim setToValue:(__bridge id)(newPath)];
        [anim setDelegate:self];
        [anim setDuration:userPercent*5.0f];
        [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        maskLayer.path = newPath;
        [maskLayer addAnimation:anim forKey:@"path"];
    } else {
        maskLayer.path = newPath;
        if (userScore > goalScore && goalScore > 0) {
            graphGoalBar.backgroundColor = lightGreenBarColor;
            graphBar.backgroundColor = greenBarColor;
        }
    }
    
    CGPathRelease(initalPath);
    CGPathRelease(newPath);
    
    [displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes]; // just in case
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateFrame:)];
    startTime = CACurrentMediaTime();
    duration = userPercent*5.0f;
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [UIView animateWithDuration:userPercent*5.0f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        userPointer.center = CGPointMake(graphBarContainer.x+graphBar.x+userBarWidth, userPointer.y);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)animateFrame:(CADisplayLink *)link
{
    CGFloat dt = ([link timestamp] - startTime) / duration;
    
    if (userScore*dt > goalScore && goalScore > 0) {
        graphGoalBar.backgroundColor = lightGreenBarColor;
        graphBar.backgroundColor = greenBarColor;
    }
    
    if (dt >= 1.0) {
        [userPointer setScore:userScore];
        [displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        displayLink = nil;
        return;
    }
    
    [userPointer setScore:userScore*dt];
}

- (void)onUserPointerClick:(UserPointer*)pointer
{
    if ([self.delegate respondsToSelector:@selector(onUserPointerClick:)]) {
        [self.delegate onUserPointerClick:pointer.user];
    }
}

@end

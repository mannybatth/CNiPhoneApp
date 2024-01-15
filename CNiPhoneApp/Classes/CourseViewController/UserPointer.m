//
//  UserPointer.m
//  CNApp
//
//  Created by Manpreet Singh on 8/5/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "UserPointer.h"

@interface UserPointer()
{
    UIImageView *userPointerBg;
    UIImageView *userPointerAvatar;
    UILabel *userPointerNumLabel;
    UserPointerDirection pointerDirection;
}

@end

@implementation UserPointer

@synthesize score;

- (id)initWithFrame:(CGRect)frame imageURL:(NSString*)imageURL direction:(UserPointerDirection)direction
{
    self = [super initWithFrame:frame];
    if (self) {
        
        pointerDirection = direction;
        
        if (direction == Down) {
            userPointerBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"course_graph_user_pointer_down.png"]];
            userPointerAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(2, 7, 24, 24)];
        } else if (direction == Left) {
            userPointerBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"course_graph_user_pointer_left.png"]];
            userPointerAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(7, 2, 24, 24)];
        } else {
            userPointerBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"course_graph_user_pointer_up.png"]];
            userPointerAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(2, 7, 24, 24)];
        }
        
        userPointerNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 18)];
        
        [userPointerAvatar setContentMode:UIViewContentModeScaleAspectFill];
        [userPointerAvatar setClipsToBounds:YES];
        [userPointerAvatar setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", imageURL]]placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
        
        userPointerNumLabel.backgroundColor = [UIColor clearColor];
        userPointerNumLabel.textColor = [UIColor blackColor];
        userPointerNumLabel.textAlignment = NSTextAlignmentCenter;
        userPointerNumLabel.font = [UIFont fontWithName:@"Heiti SC" size:13];
        userPointerNumLabel.minimumScaleFactor = 0.75;
        userPointerNumLabel.adjustsFontSizeToFitWidth = YES;
        
        [self addSubview:userPointerBg];
        [self addSubview:userPointerAvatar];
        [self addSubview:userPointerNumLabel];
        
    }
    return self;
}

- (void)setScore:(float)pointerScore
{
    score = pointerScore;
    userPointerNumLabel.text = [self formatNumber:score];
    if (pointerDirection == Left) {
        userPointerNumLabel.center = CGPointMake(self.width/2+5, userPointerBg.height+8);
    } else {
        userPointerNumLabel.center = CGPointMake(self.width/2, userPointerBg.height+8);
    }
}

- (NSString*)formatNumber:(float)x
{
    if (x >= 1000000000) return [NSString stringWithFormat:@"%.0fB", x/1000000000];
    else if (x >= 1000000) return [NSString stringWithFormat:@"%.0fM", x/1000000];
    else if (x >= 10000) return [NSString stringWithFormat:@"%.0fk", x/1000];
    else return [NSString stringWithFormat:@"%.0f", x];
}

@end

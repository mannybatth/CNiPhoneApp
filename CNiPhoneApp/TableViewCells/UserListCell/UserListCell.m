//
//  UserListCell.m
//  CNiPhoneApp
//
//  Created by Manny on 2/26/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "UserListCell.h"

@implementation UserListCell

- (void)awakeFromNib
{
    self.userAvatar.layer.masksToBounds = YES;
    self.userAvatar.layer.cornerRadius = 5;
    
    self.anarSeedsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"anar.png"]];
    self.userScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 5, 200, 20)];
    
    self.userScoreLabel.backgroundColor = [UIColor clearColor];
    self.userScoreLabel.textColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.userScoreLabel.highlightedTextColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    self.userScoreLabel.tag = 5;
    self.anarSeedsImageView.frame = CGRectMake(0, 5, 20, 20);
    
    [self.extraContentView addSubview:self.anarSeedsImageView];
    [self.extraContentView addSubview:self.userScoreLabel];
}

- (void)setupViewForUser:(User*)user
{
    self.user = user;
    [self.userAvatar setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@.w160.jpg", self.user.avatar]]
                    placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
    [self.userFlag setImageWithURL:[NSURL URLWithString:self.user.flagURL]];
    self.userName.text = self.user.displayName;
}

@end

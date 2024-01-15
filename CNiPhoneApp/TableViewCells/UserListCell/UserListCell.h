//
//  UserListCell.h
//  CNiPhoneApp
//
//  Created by Manny on 2/26/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "User.h"

@interface UserListCell : UITableViewCell

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) IBOutlet UIImageView *userAvatar;
@property (nonatomic, strong) IBOutlet UILabel *userName;
@property (nonatomic, strong) IBOutlet UIImageView *userFlag;
@property (nonatomic, strong) IBOutlet UIView *extraContentView;

@property (nonatomic, strong) UIImageView *anarSeedsImageView;
@property (nonatomic, strong) UILabel *userScoreLabel;

- (void)setupViewForUser:(User*)user;

@end

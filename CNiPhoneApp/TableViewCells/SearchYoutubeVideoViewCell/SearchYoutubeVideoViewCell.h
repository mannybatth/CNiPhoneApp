//
//  SearchYoutubeVideoViewCell.h
//  CNiPhoneApp
//
//  Created by Manny on 3/13/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "Video.h"

@interface SearchYoutubeVideoViewCell : UITableViewCell

@property (nonatomic, strong) Video *video;

@property (nonatomic, strong) IBOutlet UIImageView *videoThumbnail;
@property (nonatomic, strong) IBOutlet UILabel *videoTitle;
@property (nonatomic, strong) IBOutlet UIButton *addVideoBtn;

- (void)setUpViewForVideo:(Video*)video;

@end

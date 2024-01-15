//
//  SearchYoutubeVideoViewCell.m
//  CNiPhoneApp
//
//  Created by Manny on 3/13/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "SearchYoutubeVideoViewCell.h"

@implementation SearchYoutubeVideoViewCell

- (void)awakeFromNib
{
    self.addVideoBtn.layer.masksToBounds = YES;
    self.addVideoBtn.layer.cornerRadius = 3.0f;
}

- (void)setUpViewForVideo:(Video*)video
{
    self.video = video;
    
    self.videoTitle.text = video.title;
    NSString *thumbnail = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/default.jpg", video.youtubeId];
    [self.videoThumbnail setImageWithURL:[NSURL URLWithString:thumbnail]
                        placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMG]];
    
}

@end

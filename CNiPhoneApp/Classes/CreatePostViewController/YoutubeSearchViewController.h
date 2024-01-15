//
//  YoutubeSearchViewController.h
//  CNiPhoneApp
//
//  Created by Manny on 3/12/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

@class Video;
@protocol YoutubeSearchDelegate <NSObject>

@optional
- (void)didSelectYoutubeVideo:(Video *)video;

@end

@interface YoutubeSearchViewController : UIViewController

@property (nonatomic, weak) UIViewController<YoutubeSearchDelegate> *delegate;

@end

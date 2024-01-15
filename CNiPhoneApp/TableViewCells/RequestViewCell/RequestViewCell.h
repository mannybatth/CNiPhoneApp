//
//  RequestViewCell.h
//  CNiPhoneApp
//
//  Created by Manny on 3/19/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "ColleagueRequest.h"
#import "BButton.h"

@protocol RequestViewCellDelegate <NSObject>

@optional
- (void)onRequestAccepted:(ColleagueRequest *)request;
- (void)onRequestRejected:(ColleagueRequest *)request;

@end

@interface RequestViewCell : UITableViewCell

@property (nonatomic, weak) UIViewController<RequestViewCellDelegate> *delegate;

@property (nonatomic, strong) ColleagueRequest *request;

@property (nonatomic, strong) IBOutlet UIImageView *requestAvatarView;
@property (nonatomic, strong) IBOutlet UILabel *requestUserNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *requestDisplayDateLabel;

@property (nonatomic, strong) IBOutlet BButton *acceptBtn;
@property (nonatomic, strong) IBOutlet BButton *rejectBtn;

+ (CGFloat)heightOfCellWithColleageRequest:(ColleagueRequest *)request;
- (void)setupViewForColleageRequest:(ColleagueRequest *)request;

@end

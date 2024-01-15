//
//  NotificationViewCell.h
//  CNiPhoneApp
//
//  Created by Manny on 3/19/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "Notification.h"

@protocol NotificationViewCellDelegate <NSObject>
@end

@interface NotificationViewCell : UITableViewCell

@property (nonatomic, weak) UIViewController<NotificationViewCellDelegate> *delegate;

@property (nonatomic, strong) Notification *notification;

@property (nonatomic, strong) IBOutlet UIImageView *notificationAvatarView;
@property (nonatomic, strong) IBOutlet UILabel *notificationTextLabel;

+ (CGFloat)heightOfCellWithNotification:(Notification *)notification;
- (void)setupViewForNotification:(Notification *)notification;

@end

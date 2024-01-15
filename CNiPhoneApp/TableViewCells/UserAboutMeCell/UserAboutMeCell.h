//
//  UserAboutMeCell.h
//  CNiPhoneApp
//
//  Created by Manny on 2/26/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "User.h"

@interface AboutMeBlock : NSObject
@property (nonatomic, strong) NSString *blockTitle;
@property (nonatomic, strong) NSString *blockContent;
@end

@interface UserAboutMeCell : UITableViewCell

@property (nonatomic, strong) User *user;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *contentLabel;

+ (CGFloat)heightOfCellWithUser:(User*)user atIndex:(int)index;
+ (AboutMeBlock*)getAboutMeBlockForUser:(User*)user atIndex:(int)index;
- (void)setupViewForUser:(User*)user atIndex:(int)index;

@end

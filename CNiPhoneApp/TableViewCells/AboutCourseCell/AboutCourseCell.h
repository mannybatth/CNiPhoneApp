//
//  AboutCourseCell.h
//  CNiPhoneApp
//
//  Created by Manny on 2/28/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "Course.h"

@interface AboutCourseBlock : NSObject
@property (nonatomic, strong) NSString *blockTitle;
@property (nonatomic, strong) NSString *blockContent;
@end

@interface AboutCourseCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *contentLabel;

+ (CGFloat)heightOfCellWithCourse:(Course*)course atIndex:(int)index;
+ (AboutCourseBlock*)getAboutCourseBlockForCourse:(Course*)course atIndex:(int)index;
- (void)setupViewForCourse:(Course*)course atIndex:(int)index;

@end

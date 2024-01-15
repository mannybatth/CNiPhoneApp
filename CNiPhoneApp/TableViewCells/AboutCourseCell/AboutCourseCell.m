//
//  AboutCourseCell.m
//  CNiPhoneApp
//
//  Created by Manny on 2/28/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "AboutCourseCell.h"

#define CONTENT_LABEL_WIDTH 297

@implementation AboutCourseBlock
@end

@implementation AboutCourseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (CGFloat)heightOfCellWithCourse:(Course *)course atIndex:(int)index
{
    AboutCourseBlock *block = [AboutCourseCell getAboutCourseBlockForCourse:course atIndex:index];
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:@"Verdana" size:12.0f]};
    CGRect rect = [block.blockContent boundingRectWithSize:CGSizeMake(CONTENT_LABEL_WIDTH, MAXFLOAT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:attributes
                                                   context:nil];
    return rect.size.height + 50;
}

+ (AboutCourseBlock *)getAboutCourseBlockForCourse:(Course *)course atIndex:(int)index
{
    AboutCourseBlock *block = [[AboutCourseBlock alloc] init];
    
    if (index == 0) {
        
        block.blockTitle = @"Name";
        block.blockContent = course.name;
        
    } else if (index == 1) {
        
        block.blockTitle = @"Course Number";
        block.blockContent = course.courseNumber;
        
    } else if (index == 2) {
        
        block.blockTitle = @"Status";
        NSString *status;
        if (course.isStart && !course.isEnd) {
            status = @"Active";
        } else if (course.isEnd) {
            status = @"Ended";
        } else {
            status = @"Unavailable";
        }
        block.blockContent = status;
        
    } else if (index == 3) {
        
        block.blockTitle = @"School";
        block.blockContent = course.school.schoolName ? course.school.schoolName : @"N/A";
        
    } else if (index == 4) {
        
        block.blockTitle = @"Instructor(s)";
        __block NSString *instructorsString = @"";
        if (course.instructors.count > 0) {
            [course.instructors enumerateObjectsUsingBlock:^(User *user, NSUInteger idx, BOOL *stop) {
                instructorsString = [instructorsString stringByAppendingString:user.displayName];
                if (idx != course.instructors.count-1) instructorsString = [instructorsString stringByAppendingString:@", "];
            }];
        } else {
            instructorsString = @"N/A";
        }
        block.blockContent = instructorsString;
        
    } else if (index == 5) {
        
        block.blockTitle = @"About";
        block.blockContent = course.about;
        
    }
    
    return block;
}

- (void)setupViewForCourse:(Course *)course atIndex:(int)index
{
    AboutCourseBlock *block = [AboutCourseCell getAboutCourseBlockForCourse:course atIndex:index];
    
    self.titleLabel.text = block.blockTitle;
    self.contentLabel.text = block.blockContent;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

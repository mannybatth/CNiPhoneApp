//
//  UserAboutMeCell.m
//  CNiPhoneApp
//
//  Created by Manny on 2/26/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "UserAboutMeCell.h"

#define CONTENT_LABEL_WIDTH 297

@implementation AboutMeBlock
@end

@implementation UserAboutMeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (CGFloat)heightOfCellWithUser:(User*)user atIndex:(int)index
{
    AboutMeBlock *block = [UserAboutMeCell getAboutMeBlockForUser:user atIndex:index];
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:@"Verdana" size:12.0f]};
    CGRect rect = [block.blockContent boundingRectWithSize:CGSizeMake(CONTENT_LABEL_WIDTH, MAXFLOAT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:attributes
                                                   context:nil];
    return rect.size.height + 50;
}

+ (AboutMeBlock*)getAboutMeBlockForUser:(User*)user atIndex:(int)index
{
    AboutMeBlock *block = [[AboutMeBlock alloc] init];
    UserProfile *profile = user.profile;
    
    if (index == 0) {
        
        block.blockTitle = @"About";
        block.blockContent = profile.about;
        
    } else if (index == 1) {
        
        block.blockTitle = @"Gender";
        block.blockContent = profile.gender ? profile.gender : @"N/A";
        
    } else if (index == 2) {
        
        block.blockTitle = @"Currently";
        if ([[user.profile.currentPosition.positionName lowercaseString] isEqualToString:@"other"]) {
            block.blockContent = user.profile.currentPosition.positionType;
        } else if (![user.profile.currentPosition.positionName isEqualToString:@""] && ![user.profile.currentPosition.positionSchoolName isEqualToString:@""] && (user.profile.currentPosition.positionName != nil) && (user.profile.currentPosition.positionSchoolName != nil)) {
            block.blockContent = [NSString stringWithFormat:@"%@ at %@", user.profile.currentPosition.positionName, user.profile.currentPosition.positionSchoolName];
        } else if (![user.profile.currentPosition.positionName isEqualToString:@""] && (user.profile.currentPosition.positionName != nil)) {
            block.blockContent = user.profile.currentPosition.positionName;
        } else {
            block.blockContent = @"N/A";
        }
        
    } else if (index == 3) {
        
        block.blockTitle = @"Current Work";
        block.blockContent = profile.currentWork.workPosition ?
            [NSString stringWithFormat:@"%@ at %@", profile.currentWork.workPosition, profile.currentWork.workCompany] : @"N/A";
        
    } else if (index == 4) {
        
        block.blockTitle = @"Primary Language";
        block.blockContent = profile.primaryLanguage ? profile.primaryLanguage : @"N/A";
        
    } else if (index == 5) {
        
        block.blockTitle = @"Country";
        block.blockContent = profile.country ? profile.country : @"N/A";
        
    } else if (index == 6) {
        
        block.blockTitle = @"Time Zone";
        block.blockContent = profile.timeZone ? profile.timeZone : @"N/A";
        
    }
    
    return block;
}

- (void)setupViewForUser:(User*)user atIndex:(int)index
{
    AboutMeBlock *block = [UserAboutMeCell getAboutMeBlockForUser:user atIndex:index];
    
    self.titleLabel.text = block.blockTitle;
    self.contentLabel.text = block.blockContent;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

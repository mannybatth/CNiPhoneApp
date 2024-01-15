//
//  AboutConexusCell.m
//  CNiPhoneApp
//
//  Created by Manny on 3/4/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "AboutConexusCell.h"

#define CONTENT_LABEL_WIDTH 297

@implementation AboutConexusBlock
@end

@implementation AboutConexusCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (CGFloat)heightOfCellWithConexus:(Conexus *)conexus atIndex:(int)index
{
    AboutConexusBlock *block = [AboutConexusCell getAboutConexusBlockForConexus:conexus atIndex:index];
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:@"Verdana" size:12.0f]};
    CGRect rect = [block.blockContent boundingRectWithSize:CGSizeMake(CONTENT_LABEL_WIDTH, MAXFLOAT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:attributes
                                                   context:nil];
    return rect.size.height + 50;
}

+ (AboutConexusBlock *)getAboutConexusBlockForConexus:(Conexus *)conexus atIndex:(int)index
{
    AboutConexusBlock *block = [[AboutConexusBlock alloc] init];
    
    if (index == 0) {
        
        block.blockTitle = @"Name";
        block.blockContent = conexus.name;
        
    } else if (index == 1) {
        
        block.blockTitle = @"Conexus Number";
        block.blockContent = conexus.conexusNumber;
        
    } else if (index == 2) {
        
        block.blockTitle = @"About";
        block.blockContent = conexus.about;
        
    }
    
    return block;
}

- (void)setupViewForConexus:(Conexus *)conexus atIndex:(int)index
{
    AboutConexusBlock *block = [AboutConexusCell getAboutConexusBlockForConexus:conexus atIndex:index];
    
    self.titleLabel.text = block.blockTitle;
    self.contentLabel.text = block.blockContent;
}

@end

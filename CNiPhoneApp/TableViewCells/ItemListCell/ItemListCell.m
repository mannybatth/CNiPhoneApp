//
//  ItemListCell.m
//  CNApp
//
//  Created by Manpreet Singh on 8/8/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "ItemListCell.h"

@interface ItemListCell()
{
    UIView *sideBar;
}

@end
@implementation ItemListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.imageView.clipsToBounds = YES;
        self.imageViewFrame = CGRectMake(0, 0, 40, 40);
        self.textLabelFrame = CGRectMake(45, 0, 275, 40);
    
        sideBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, 40)];
        [sideBar setBackgroundColor:[UIColor clearColor]];
        [self addSubview:sideBar];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.imageViewFrame;
    self.textLabel.frame = self.textLabelFrame;
    self.detailTextLabel.frame = self.detailTextLabelFrame;
    self.imageView.backgroundColor = self.transparentImageViewBackground ? [UIColor clearColor] : [UIColor whiteColor];
    if (self.sideBarColor) [sideBar setBackgroundColor:self.sideBarColor];
    
}

@end

//
//  ItemListCell.h
//  CNApp
//
//  Created by Manpreet Singh on 8/8/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+GCLibrary.h"

@interface ItemListCell : UITableViewCell

@property (nonatomic) CGRect imageViewFrame;
@property (nonatomic) CGRect textLabelFrame;
@property (nonatomic) CGRect detailTextLabelFrame;
@property (nonatomic) UIColor *sideBarColor;
@property (nonatomic) BOOL transparentImageViewBackground;

@end

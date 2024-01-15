//
//  AboutConexusCell.h
//  CNiPhoneApp
//
//  Created by Manny on 3/4/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

#import "Conexus.h"

@interface AboutConexusBlock : NSObject
@property (nonatomic, strong) NSString *blockTitle;
@property (nonatomic, strong) NSString *blockContent;
@end

@interface AboutConexusCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *contentLabel;

+ (CGFloat)heightOfCellWithConexus:(Conexus*)conexus atIndex:(int)index;
+ (AboutConexusBlock*)getAboutConexusBlockForConexus:(Conexus*)conexus atIndex:(int)index;
- (void)setupViewForConexus:(Conexus*)conexus atIndex:(int)index;

@end

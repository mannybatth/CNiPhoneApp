//
//  VisibilitySettingsViewController.h
//  CNiPhoneApp
//
//  Created by Manny on 3/7/14.
//  Copyright (c) 2014 CourseNetworking. All rights reserved.
//

@protocol VisibilitySettingsDelegate <NSObject>

@required
- (void)onVisibilitySettingsUpdated:(NSMutableArray *)newVisibilitySettings
                            courses:(NSMutableArray *)newCoursesRelations
                            conexus:(NSMutableArray *)newConexusRelations;

@end

@interface VisibilitySettingsViewController : UIViewController

@property (nonatomic, weak) UIViewController<VisibilitySettingsDelegate> *delegate;

@property (nonatomic, strong) NSMutableArray *visibilitySettings;
@property (nonatomic, strong) NSMutableArray *coursesRelations;
@property (nonatomic, strong) NSMutableArray *conexusRelations;

@end

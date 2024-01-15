//
//  UserPointer.h
//  CNApp
//
//  Created by Manpreet Singh on 8/5/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

#import "UIView+GCLibrary.h"
#import "CourseStore.h"

typedef enum {
    Down,
    Up,
    Left
} UserPointerDirection;

@interface UserPointer : UIButton

@property (nonatomic) float score;
@property (nonatomic, strong) User *user;

- (id)initWithFrame:(CGRect)frame imageURL:(NSString*)imageURL direction:(UserPointerDirection)direction;
- (void)setScore:(float)score;

@end

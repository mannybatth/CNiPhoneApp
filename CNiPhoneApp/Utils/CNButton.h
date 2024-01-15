//
//  CNButton.h
//  CNApp
//
//  Created by Manpreet Singh on 7/28/13.
//  Copyright (c) 2013 Manpreet Singh. All rights reserved.
//

@interface CNButton : UIButton
{
    UIView *grayView;
    BOOL isButtonTouching;
}

@property (nonatomic, readwrite, retain) id userData;

@end

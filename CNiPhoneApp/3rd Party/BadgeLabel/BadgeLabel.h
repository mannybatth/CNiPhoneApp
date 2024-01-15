//
//  BadgeLabel.h
//  Badge
//
//  Created by Yonat Sharon on 11/1/11.
//

typedef enum BadgeLabelStyle {
    BadgeLabelStyleAppIcon, // red background, white border, gloss and shadow
    BadgeLabelStyleMail     // gray background, minWidth
} BadgeLabelStyle;

@interface BadgeLabel : UILabel

@property (nonatomic) BOOL hasBorder;
@property (nonatomic) BOOL hasShadow;
@property (nonatomic) BOOL hasGloss;
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) BOOL hideWhenZero;
@property (nonatomic) CGPoint point;

- (void)setStyle:(BadgeLabelStyle)style;

@end

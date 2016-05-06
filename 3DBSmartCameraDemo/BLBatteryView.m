//
//  BLBatteryView.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/31.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "BLBatteryView.h"
#define kFrameCornerRadius 2.5f
#define kFrameBorderWidth 1.0f
#define kFrameColor [UIColor grayColor]
#define kLevelViewColor [UIColor greenColor];
#define kLowLevelViewColor [UIColor redColor];

#define kLowPowerWarming 0.25
@implementation BLBatteryView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        self.batteryFrame = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 4, frame.size.height - 2)];
        self.batteryFrame.layer.masksToBounds = YES;
        self.batteryFrame.layer.cornerRadius = kFrameCornerRadius;
        self.batteryFrame.layer.borderWidth = kFrameBorderWidth;
        self.batteryFrame.layer.borderColor = kFrameColor.CGColor;
        self.batteryFrame.center = self.center;
        [self addSubview:self.batteryFrame];
        
        self.batteryHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, self.batteryFrame.frame.size.height / 3)];
        self.batteryHead.layer.masksToBounds = YES;
        self.batteryHead.layer.cornerRadius = 1;
        self.batteryHead.backgroundColor = kFrameColor;
        self.batteryHead.center = CGPointMake(frame.size.width - 2, frame.size.height / 2);
        [self addSubview:self.batteryHead];
    }
    return self;
}

- (void)setBatteryLevelWithValue:(float)value
{
    if (value <= 1 / 3.0) {
        [self setBatteryPowerWithLevel:BLBatteryLevelLow];
    }
    else if (2 / 3.0 > value && value > 1 / 3.0) {
        [self setBatteryPowerWithLevel:BLBatteryLevelMiddle];
    }
    else if (3 / 3.0 >= value && value > 2 / 3.0) {
        [self setBatteryPowerWithLevel:BLBatteryLeveleHigh];
    }
}

- (void)setBatteryPowerProcessing:(float)value
{
    for ( UIView *view in self.batteryFrame.subviews) {
        [view removeFromSuperview];
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kFrameBorderWidth + 1,
                                                            kFrameBorderWidth + 1,
                                                            (self.batteryFrame.frame.size.width - 2 - kFrameBorderWidth * 2) * value,
                                                            self.batteryFrame.frame.size.height - 2 - kFrameBorderWidth * 2)];
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 1.5;
    if (value < kLowPowerWarming) {
        view.backgroundColor = kLowLevelViewColor;
    }
    else view.backgroundColor = kLevelViewColor;
    [self.batteryFrame addSubview:view];
}

- (void)setBatteryPowerWithLevel:(BLBatteryLevel)level
{
    for ( UIView *view in self.batteryFrame.subviews) {
        [view removeFromSuperview];
    }
    if (level == BLBatteryLevelLow) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(kFrameBorderWidth + 1,
                                                                kFrameBorderWidth + 1,
                                                                (self.batteryFrame.frame.size.width - 4 - kFrameBorderWidth * 2) / 3,
                                                                self.batteryFrame.frame.size.height - 2 - kFrameBorderWidth * 2)];
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 2;
        view.backgroundColor = kLowLevelViewColor;
        [self.batteryFrame addSubview:view];
    }
    else if (level == BLBatteryLevelMiddle) {
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(kFrameBorderWidth + 1,
                                                                kFrameBorderWidth + 1,
                                                                (self.batteryFrame.frame.size.width - 4 - kFrameBorderWidth * 2) / 3,
                                                                self.batteryFrame.frame.size.height - 2 - kFrameBorderWidth * 2)];
        view1.layer.masksToBounds = YES;
        view1.layer.cornerRadius = 2;
        view1.backgroundColor = kLevelViewColor;
        [self.batteryFrame addSubview:view1];
        
        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(kFrameBorderWidth + 1 + view1.frame.size.width + 1,
                                                                 kFrameBorderWidth + 1,
                                                                 (self.batteryFrame.frame.size.width - 4 - kFrameBorderWidth * 2) / 3,
                                                                 self.batteryFrame.frame.size.height - 2 - kFrameBorderWidth * 2)];
        view2.layer.masksToBounds = YES;
        view2.layer.cornerRadius = 2;
        view2.backgroundColor = kLevelViewColor;
        [self.batteryFrame addSubview:view2];
        
    }
    else if (level == BLBatteryLeveleHigh) {
        
        UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(kFrameBorderWidth + 1,
                                                                 kFrameBorderWidth + 1,
                                                                 (self.batteryFrame.frame.size.width - 4 - kFrameBorderWidth * 2) / 3,
                                                                 self.batteryFrame.frame.size.height - 2 - kFrameBorderWidth * 2)];
        view1.layer.masksToBounds = YES;
        view1.layer.cornerRadius = 2;
        view1.backgroundColor = kLevelViewColor;
        [self.batteryFrame addSubview:view1];
        
        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(kFrameBorderWidth + 1 +view1.frame.size.width + 1,
                                                                 kFrameBorderWidth + 1,
                                                                 (self.batteryFrame.frame.size.width - 4 - kFrameBorderWidth * 2) / 3,
                                                                 self.batteryFrame.frame.size.height - 2 - kFrameBorderWidth * 2)];
        view2.layer.masksToBounds = YES;
        view2.layer.cornerRadius = 2;
        view2.backgroundColor = kLevelViewColor;
        [self.batteryFrame addSubview:view2];
        
        UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(kFrameBorderWidth + 1 + view1.frame.size.width + 1 + view2.frame.size.width + 1,
                                                                 kFrameBorderWidth + 1,
                                                                 (self.batteryFrame.frame.size.width - 4 - kFrameBorderWidth * 2) / 3,
                                                                 self.batteryFrame.frame.size.height - 2 - kFrameBorderWidth * 2)];
        view3.layer.masksToBounds = YES;
        view3.layer.cornerRadius = 2;
        view3.backgroundColor = kLevelViewColor;
        [self.batteryFrame addSubview:view3];
    }
}
@end

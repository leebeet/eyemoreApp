//
//  BLBatteryView.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/31.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BLBatteryLevel) {
    BLBatteryLeveleHigh = 0,
    BLBatteryLevelMiddle,
    BLBatteryLevelLow,
};

@interface BLBatteryView : UIView

@property (nonatomic, strong) UIView *batteryHead;
@property (nonatomic, strong) UIView *batteryFrame;
@property (nonatomic, strong) UIView *capcityA;
@property (nonatomic, strong) UIView *capcityB;
@property (nonatomic, strong) UIView *capcityC;

- (void)setBatteryLevelWithValue:(float)value;
- (void)setBatteryPowerProcessing:(float)value;
- (void)setBatteryPowerWithLevel:(BLBatteryLevel)level;

@end

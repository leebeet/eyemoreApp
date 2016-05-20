//
//  ConnectionStatusView.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/5/16.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionProgressView.h"
#import "BLBatteryView.h"

typedef void (^SettingButtonTappedHandler)(BOOL isTapped);

@interface ConnectionStatusView : UIView

//@property (strong, nonatomic) UIImageView *deviceIcon;
//@property (strong, nonatomic) UIImageView *iPhoneIcon;
//@property (strong, nonatomic) ConnectionProgressView *forwardProgress;
//@property (strong, nonatomic) ConnectionProgressView *backwardProgress;
@property (strong, nonatomic) UIImageView *connectState;
//@property (strong, nonatomic) BLBatteryView *battIndicator;
//@property (strong, nonatomic) UIButton *settingsButton;
//@property (strong, nonatomic) SettingButtonTappedHandler settingButtonTappedHandler;
@property (strong, nonatomic) UIImageView *connectionChartView;

- (void)setConnection:(BOOL)isConnected;

@end

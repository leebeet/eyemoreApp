//
//  DeviceViewController.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/17.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "RootViewController.h"
#import "BLBatteryView.h"

@interface DeviceViewController : RootViewController
@property (weak, nonatomic) IBOutlet UILabel *connectHintLabel;
@property (weak, nonatomic) IBOutlet UILabel *DeviceNameLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *DeviceImageView;
@property (strong, nonatomic) UIImageView *DeviceImageView;
@end

//
//  UserSettingConfig.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/7/28.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "UserSettingConfig.h"

@implementation UserSettingConfig

+ (void)SetWaterMarkEnabled:(BOOL)isEnable
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isEnable forKey:@"WaterMarkConfig"];
}

+ (BOOL)waterMarkIsEnabled
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults valueForKey:@"WaterMarkConfig"]) {
        return [defaults boolForKey:@"WaterMarkConfig"];
    }
    else return YES;
}

+ (void)setExposure:(int)value
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:value forKey:@"ExposureConfig"];
}

- (int)getExposureConfig
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (int)[defaults integerForKey:@"ExposureConfig"];
}

+ (void)setShutter:(int)value
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:value forKey:@"ShutterConfig"];
}

- (int)getShutterConfig
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (int)[defaults integerForKey:@"ShutterConfig"];
}
+ (void)setIRIS:(int)value
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:value forKey:@"IRISConfig"];
}

- (int)getIRISConfig
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (int)[defaults integerForKey:@"IRISConfig"];
}


@end

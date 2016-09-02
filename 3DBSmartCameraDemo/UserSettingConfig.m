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
    return [defaults boolForKey:@"WaterMarkConfig"];
}
@end

//
//  CameraConfiguration.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 16/3/8.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "CameraConfiguration.h"

@implementation CameraConfiguration

+ (void)saveSmartBurstConfig:(BOOL)isSmartBurst
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isSmartBurst forKey:@"SmartBurstConfig"];
}

+ (BOOL)loadSmartBurstConfig
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"SmartBurstConfig"];
}
@end

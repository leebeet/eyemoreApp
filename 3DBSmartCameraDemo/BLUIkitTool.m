//
//  BLUIkitTool.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/5/11.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "BLUIkitTool.h"

@implementation BLUIkitTool

+ (UIViewController *)currentRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

@end

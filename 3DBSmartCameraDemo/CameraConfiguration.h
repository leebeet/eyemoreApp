//
//  CameraConfiguration.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 16/3/8.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CameraConfiguration : NSObject

+ (void)saveSmartBurstConfig:(BOOL)isSmartBurst;
+ (BOOL)loadSmartBurstConfig;

@end

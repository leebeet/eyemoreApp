//
//  WIFIDetector.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/10.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WIFIDetector : NSObject

+ (WIFIDetector *)sharedWIFIDetector;
- (NSString *)getDeviceSSID;
- (void)openWIFISetting;
- (BOOL)isConnecting3dbCamera;

@end

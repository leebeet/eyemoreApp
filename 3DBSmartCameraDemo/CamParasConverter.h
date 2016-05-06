//
//  CamParasConverter.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/29.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPSocketManager.h"

@interface CamParasConverter : NSObject

+ (LENS_EXPOSURE_VALUE)recodeLensExposureValueWith:(NSString *)string;
+ (LENS_EXPOSURE_MODE)recodeLensExposureModeWith:(NSString *)string;
+ (LENS_SHUTTER_VALUE)recodeLensShutterValue:(NSString *)string;
+ (LENS_IRIS_VALE)recodeLensValueWith:(NSString *)string;
+ (NSInteger)recodePowerOffTimeValueWith:(NSString *)string;
+ (NSString *)decodeLensTypeWith:(int)lensType;
+ (NSString *)decodeLensFocusStateWith:(unsigned char)lensFocusState;
+ (NSString *)decodeLensShutterValueWith:(int)shutter;
+ (NSString *)decodeLensExposureValueWith:(int)exposure;
+ (NSString *)decodeLensValueWith:(int)iris;
+ (NSString *)decodePowerOffTimeValueWith:(int)value;

@end

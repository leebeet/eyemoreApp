//
//  CamParasConverter.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/29.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "CamParasConverter.h"


@implementation CamParasConverter

#pragma mark - recode value

+ (LENS_EXPOSURE_VALUE)recodeLensExposureValueWith:(NSString *)string
{
    if ([string isEqualToString:@"EV -10.0"]) return 0;
    
    if ([string isEqualToString:@"EV -9.0"]) return 1;
    
    if ([string isEqualToString:@"EV -8.0"]) return 2;
    
    if ([string isEqualToString:@"EV -7.0"]) return 3;
    
    if ([string isEqualToString:@"EV -6.0"]) return 4;
    
    if ([string isEqualToString:@"EV -5.0"]) return 5;
    
    if ([string isEqualToString:@"EV -4.0"]) return 6;
    
    if ([string isEqualToString:@"EV -3.0"]) return 7;
    
    if ([string isEqualToString:@"EV -2.0"]) return 8;
    
    if ([string isEqualToString:@"EV -1.0"]) return 9;
    
    if ([string isEqualToString:@"EV 0.0"]) return 10;
    
    if ([string isEqualToString:@"EV 1.0"]) return 11;
    
    if ([string isEqualToString:@"EV 2.0"]) return 12;
    
    if ([string isEqualToString:@"EV 3.0"]) return 13;
    
    if ([string isEqualToString:@"EV 4.0"]) return 14;
    
    if ([string isEqualToString:@"EV 5.0"]) return 15;
    
    if ([string isEqualToString:@"EV 6.0"]) return 16;
    
    if ([string isEqualToString:@"EV 7.0"]) return 17;
    
    if ([string isEqualToString:@"EV 8.0"]) return 18;
    
    if ([string isEqualToString:@"EV 9.0"]) return 19;
    
    if ([string isEqualToString:@"EV 10.0"]) return 20;
    
    else return 21;
    
}

+ (LENS_EXPOSURE_MODE)recodeLensExposureModeWith:(NSString *)string
{
    if ([string isEqualToString:@"P"]) return 1;
    
    if ([string isEqualToString:@"S"]) return 2;
    
    if ([string isEqualToString:@"A"]) return 3;
    
    if ([string isEqualToString:@"M"]) return 4;
    
    else return 0;
}

+ (LENS_SHUTTER_VALUE)recodeLensShutterValue:(NSString *)string
{
    if ([string isEqualToString:@"1/25"]) return 1;
    
    if ([string isEqualToString:@"1/50"]) return 2;
    
    if ([string isEqualToString:@"1/75"]) return 3;
    
    if ([string isEqualToString:@"1/100"]) return 4;
    
    if ([string isEqualToString:@"1/125"]) return 5;
    
    if ([string isEqualToString:@"1/150"]) return 6;
    
    if ([string isEqualToString:@"1/200"]) return 7;
    
    if ([string isEqualToString:@"1/500"]) return 8;
    
    if ([string isEqualToString:@"1/1000"]) return 9;
    
    if ([string isEqualToString:@"1/2000"]) return 10;
    
    if ([string isEqualToString:@"1/4000"]) return 11;
    
    if ([string isEqualToString:@"1/8000"]) return 12;
    
    else return 0;
}

+ (LENS_IRIS_VALE)recodeLensValueWith:(NSString *)string
{
    if ([string isEqualToString:@"F1.2"])   return 0;
    
    if ([string isEqualToString:@"F1.4"])   return 1;
    
    if ([string isEqualToString:@"F1.7"])   return 2;
    
    if ([string isEqualToString:@"F1.8"])   return 3;
    
    if ([string isEqualToString:@"F2.0"])   return 4;
    
    if ([string isEqualToString:@"F2.2"])   return 5;
    
    if ([string isEqualToString:@"F2.5"])   return 6;
    
    if ([string isEqualToString:@"F2.8"])   return 7;
    
    if ([string isEqualToString:@"F3.2"])   return 8;
    
    if ([string isEqualToString:@"F3.5"])   return 9;
    
    if ([string isEqualToString:@"F4.0"])   return 10;
    
    if ([string isEqualToString:@"F4.5"])   return 11;
    
    if ([string isEqualToString:@"F5.0"])   return 12;
    
    if ([string isEqualToString:@"F5.6"])   return 13;
    
    if ([string isEqualToString:@"F6.3"])   return 14;
    
    if ([string isEqualToString:@"F7.1"])   return 15;
    
    if ([string isEqualToString:@"F8.0"])   return 16;
    
    if ([string isEqualToString:@"F9.0"])   return 17;
    
    if ([string isEqualToString:@"F10.0"])  return 18;
    
    if ([string isEqualToString:@"F11.0"])  return 19;
    
    if ([string isEqualToString:@"F13.0"])  return 20;
    
    if ([string isEqualToString:@"F14.0"])  return 21;
    
    if ([string isEqualToString:@"F16.0"])  return 22;
    
    if ([string isEqualToString:@"F18.0"])  return 23;
    
    if ([string isEqualToString:@"F20.0"])  return 24;
    
    if ([string isEqualToString:@"F22.0"])  return 25;
    
    else return 26;
    
}

+ (NSInteger)recodePowerOffTimeValueWith:(NSString *)string
{
    if ([string isEqualToString:@"不自动关机"]) return 0;
    
    if ([string isEqualToString:@"1 min"])    return 1;
    
    if ([string isEqualToString:@"2 mins"])   return 2;
    
    if ([string isEqualToString:@"3 mins"])   return 3;
    
    if ([string isEqualToString:@"4 mins"])   return 4;
    
    if ([string isEqualToString:@"5 mins"])   return 5;
    
    if ([string isEqualToString:@"10 mins"])  return 10;
    
    if ([string isEqualToString:@"30 mins"])  return 30;
    
    if ([string isEqualToString:@"60 mins"])  return 60;
    
    if ([string isEqualToString:@"90 mins"])  return 90;
    
    if ([string isEqualToString:@"120 mins"]) return 120;
    
    else return 0;
    
    
}

+ (NSString *)decodeLensTypeWith:(int)lensType
{
    switch (lensType) {
        case 0:
            return @"手动";
            break;
        case 1:
            return @"自动";
            break;
        default:
            return @"unknown";
            break;
    }
}

+ (NSString *)decodeLensFocusStateWith:(unsigned char)lensFocusState
{
    switch (lensFocusState) {
            
        case 1:
            return @"AF";
            break;
        case 2:
            return @"MF";
            break;
            
        default:
            return @"AF";
            break;
    }
}

+ (NSString *)decodeLensShutterValueWith:(int)shutter
{
    switch (shutter) {
        case 1:
            return @"1/25";
            break;
        case 2:
            return @"1/50";
            break;
        case 3:
            return @"1/75";
            break;
        case 4:
            return @"1/100";
            break;
        case 5:
            return @"1/125";
            break;
        case 6:
            return @"1/150";
            break;
        case 7:
            return @"1/200";
            break;
        case 8:
            return @"1/500";
            break;
        case 9:
            return @"1/1000";
            break;
        case 10:
            return @"1/2000";
            break;
        case 11:
            return @"1/4000";
            break;
        case 12:
            return @"1/8000";
            break;
            
        default:
            return @"unknow";
            break;
    }
}

+ (NSString *)decodeLensExposureValueWith:(int)exposure
{
    switch (exposure) {
        case 0:
            return @"EV -10.0";
            break;
        case 1:
            return @"EV -9.0";
            break;
        case 2:
            return @"EV -8.0";
            break;
        case 3:
            return @"EV -7.0";
            break;
        case 4:
            return @"EV -6.0";
            break;
        case 5:
            return @"EV -5.0";
            break;
        case 6:
            return @"EV -4.0";
            break;
        case 7:
            return @"EV -3.0";
            break;
        case 8:
            return @"EV -2.0";
            break;
        case 9:
            return @"EV -1.0";
            break;
        case 10:
            return @"EV 0.0";
            break;
        case 11:
            return @"EV 1.0";
            break;
        case 12:
            return @"EV 2.0";
            break;
        case 13:
            return @"EV 3.0";
            break;
        case 14:
            return @"EV 4.0";
            break;
        case 15:
            return @"EV 5.0";
            break;
        case 16:
            return @"EV 6.0";
            break;
        case 17:
            return @"EV 7.0";
            break;
        case 18:
            return @"EV 8.0";
            break;
        case 19:
            return @"EV 9.0";
            break;
        case 20:
            return @"EV 10.0";
            break;
            
        default:
            return @"unknown";
            break;
    }
}

+ (NSString *)decodeLensValueWith:(int)iris
{
    switch (iris) {
            
        case 0:
            return @"F1.2";
            break;
        case 1:
            return @"F1.4";
            break;
        case 2:
            return @"F1.7";
            break;
        case 3:
            return @"F1.8";
            break;
        case 4:
            return @"F2.0";
            break;
        case 5:
            return @"F2.2";
            break;
        case 6:
            return @"F2.5";
            break;
        case 7:
            return @"F2.8";
            break;
        case 8:
            return @"F3.2";
            break;
        case 9:
            return @"F3.5";
            break;
        case 10:
            return @"F4.0";
            break;
        case 11:
            return @"F4.5";
            break;
        case 12:
            return @"F5.0";
            break;
        case 13:
            return @"F5.6";
            break;
        case 14:
            return @"F6.3";
            break;
        case 15:
            return @"F7.1";
            break;
        case 16:
            return @"F8.0";
            break;
        case 17:
            return @"F9.0";
            break;
        case 18:
            return @"F10.0";
            break;
        case 19:
            return @"F11.0";
            break;
        case 20:
            return @"F13.0";
            break;
        case 21:
            return @"F14.0";
            break;
        case 22:
            return @"F16.0";
            break;
        case 23:
            return @"F18.0";
            break;
        case 24:
            return @"F20.0";
            break;
        case 25:
            return @"F22.0";
            break;
            
        default:
            return @"unknown";
            break;
    }
}

+ (NSString *)decodePowerOffTimeValueWith:(int)value
{
    switch (value) {
        case 0:
            return @"不自动关机";
            break;
            
        case 5:
            return @"5 mins";
            break;
            
        case 10:
            return @"10 mins";
            break;
            
        case 30:
            return @"30 mins";
            break;
            
        case 60:
            return @"60 mins";
            break;
            
        case 90:
            return @"90 mins";
            break;
            
        case 120:
            return @"120 mins";
            break;
            
        default:
            return @"不自动关机";
            break;
    }
}


@end

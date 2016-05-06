//
//  BLPCMToWAV.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/12/10.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <stdio.h>
#include <string.h>



typedef unsigned long       DWORD;
typedef unsigned char       BYTE;
typedef unsigned short      WORD;

@interface BLPCMToWAV : NSObject

+ (NSMutableData *)convertPCMToWavWith:(NSData *)data withSample:(int)sample channel:(int)channel bps:(int)bps;

@end

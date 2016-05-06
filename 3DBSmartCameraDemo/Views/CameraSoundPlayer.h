//
//  CameraSoundPlayer.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/6/15.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface CameraSoundPlayer : NSObject

+ (void)playSound;
+ (void)playSelfieSound;
+ (void)playSwipeSoundWithVibrate:(BOOL)isVibrate;
+ (void)playFocusSound;

@end

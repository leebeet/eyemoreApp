//
//  CameraSoundPlayer.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/6/15.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "CameraSoundPlayer.h"

@implementation CameraSoundPlayer

//static SystemSoundID cameraSound_id = 1016;
static SystemSoundID cameraSound_id = 1108;
static SystemSoundID selfieSound_id = 1004;
static SystemSoundID swipeSound_id  = 1104;

static SystemSoundID focusSound_id  = 1104;

+ (void)playSound

{
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"一声枪声特效" ofType:@"wav"];
//    if (path) {
//        //注册声音到系统
//        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&cameraSound_id);
//        AudioServicesPlaySystemSound(cameraSound_id);
//        //        AudioServicesPlaySystemSound(shake_sound_male_id);//如果无法再下面播放，可以尝试在此播放
//    }
    
    AudioServicesPlaySystemSound(cameraSound_id);   //播放注册的声音，（此句代码，可以在本类中的任意位置调用，不限于本方法中）
    
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);   //让手机震动
    

}
+ (void)playSelfieSound

{
    
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"一声枪声特效" ofType:@"wav"];
    //    if (path) {
    //        //注册声音到系统
    //        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&cameraSound_id);
    //        AudioServicesPlaySystemSound(cameraSound_id);
    //        //        AudioServicesPlaySystemSound(shake_sound_male_id);//如果无法再下面播放，可以尝试在此播放
    //    }
    
    AudioServicesPlaySystemSound(selfieSound_id);   //播放注册的声音，（此句代码，可以在本类中的任意位置调用，不限于本方法中）
    
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);   //让手机震动
    
}

+ (void)playSwipeSoundWithVibrate:(BOOL)isVibrate

{
    
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"一声枪声特效" ofType:@"wav"];
    //    if (path) {
    //        //注册声音到系统
    //        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&cameraSound_id);
    //        AudioServicesPlaySystemSound(cameraSound_id);
    //        //        AudioServicesPlaySystemSound(shake_sound_male_id);//如果无法再下面播放，可以尝试在此播放
    //    }
    
    AudioServicesPlaySystemSound(swipeSound_id);   //播放注册的声音，（此句代码，可以在本类中的任意位置调用，不限于本方法中）
    
    if (isVibrate) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);   //让手机震动
    }
    
    
}

+ (void)playFocusSound
{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"focus_classic" ofType:@"wav"];
        if (path) {
            //注册声音到系统
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &focusSound_id);
            AudioServicesPlaySystemSound(focusSound_id);
            //        AudioServicesPlaySystemSound(shake_sound_male_id);//如果无法再下面播放，可以尝试在此播放
        }
    
    AudioServicesPlaySystemSound(focusSound_id);   //播放注册的声音，（此句代码，可以在本类中的任意位置调用，不限于本方法中）
}

@end

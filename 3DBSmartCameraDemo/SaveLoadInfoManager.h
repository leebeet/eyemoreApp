//
//  SaveLoadInfoManager.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/6/17.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageClient.h"
#import "VideoClient.h"
@interface SaveLoadInfoManager : NSObject

+ (void)saveAppInfoWithClient:(ImageClient *)client;
+ (ImageClient *)loadInfoWithClient;
+ (int)imagePathIndex;

+ (void)saveAppInfoWithVideoClient:(VideoClient *)client;
+ (VideoClient *)loadAppInfoWithVideoClient;

@end

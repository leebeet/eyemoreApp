//
//  VideoConfig.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/5.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EyemoreVideo.h"

@interface VideoConfig : NSObject

@property (strong, nonatomic) NSMutableArray *videoList;

+ (VideoConfig *)sharedVideoConfig;
- (void)addEyemoreVideos:(EyemoreVideo *)video;
- (void)removeEyemoreVideo:(EyemoreVideo *)video;
- (void)removeEyemoreVideoAtIndex:(NSInteger)index;
- (void)synchonizeEyemoreVideos;
- (EyemoreVideo *)myEyemoreVideoAtIndex:(NSInteger)index;
- (EyemoreVideo *)myLastEyemoreVideo;
- (NSMutableArray*)myEyemoreVideos;

@end

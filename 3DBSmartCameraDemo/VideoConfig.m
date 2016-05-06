//
//  VideoConfig.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/5.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "VideoConfig.h"

@implementation VideoConfig

- (id)init
{
    self = [super init];
    if (self) {
        self.videoList = [NSMutableArray new];
    }
    return self;
}

+ (VideoConfig *)sharedVideoConfig
{
    static VideoConfig *instance;
    if (instance == nil) {
        instance = [[VideoConfig alloc] init];
        [instance myEyemoreVideos];
    }
    return instance;
}

- (void)addEyemoreVideos:(EyemoreVideo *)video
{
    NSData *videoData = [NSKeyedArchiver archivedDataWithRootObject:video];
    [self.videoList addObject:videoData];
}

- (void)removeEyemoreVideo:(EyemoreVideo *)video
{
    NSData *videoData = [NSKeyedArchiver archivedDataWithRootObject:video];
    BOOL couldRemove = NO;
    for (int i = 0; i < self.videoList.count; i ++) {
        if ([videoData isEqualToData:self.videoList[i]]) {
            NSLog(@" video data is in video list");
            couldRemove = YES;
        }
    }
    if (couldRemove) {
        [self.videoList removeObject:videoData];
    }
    else {
        NSLog(@"could not remove videData, different data from video list!");
    }
}

- (void)removeEyemoreVideoAtIndex:(NSInteger)index
{
    [self.videoList removeObjectAtIndex:index];
    NSLog(@"did remove eyemore video, %lu", (unsigned long)self.videoList.count);
}

- (void)synchonizeEyemoreVideos
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.videoList copy] forKey:@"videoList"];
    [defaults synchronize];
}

- (EyemoreVideo *)myEyemoreVideoAtIndex:(NSInteger)index
{
    EyemoreVideo *video = [NSKeyedUnarchiver unarchiveObjectWithData:self.videoList[index]];
    return video;
}

- (EyemoreVideo *)myLastEyemoreVideo
{
    EyemoreVideo *video = [NSKeyedUnarchiver unarchiveObjectWithData:[self.videoList lastObject]];
    return video;
}

- (NSMutableArray*)myEyemoreVideos
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [defaults objectForKey:@"videoList"];
    if (array == nil) {
        return nil;
    }
    else {
        self.videoList = [array mutableCopy];
        return self.videoList;
    }
}

@end

//
//  eyemoreVideos.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/5.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "EyemoreVideo.h"

@implementation EyemoreVideo

- (instancetype)initWithProfileDict:(NSArray *)VideoInfo
{
    self = [super init];
    if (self) {
        self.uid        = [VideoInfo[0] integerValue];
        self.fileSize   = [VideoInfo[1] integerValue];
        self.frameCount = [VideoInfo[2] integerValue];
        self.resolution = CGSizeMake([VideoInfo[3] floatValue], [VideoInfo[4] floatValue]);
        self.FPS        = [VideoInfo[5] floatValue];
        self.FS         = [VideoInfo[6] floatValue];
        self.audioWidth = [VideoInfo[7] floatValue];
        self.channel    = [VideoInfo[8] integerValue];
        self.videoMaterial = [NSMutableDictionary new];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.uid        = [aDecoder decodeIntegerForKey:@"uid"];
        self.fileSize   = [aDecoder decodeIntegerForKey:@"fileSize"];
        self.frameCount = [aDecoder decodeIntegerForKey:@"frameCount"];
        self.resolution = [aDecoder decodeCGSizeForKey: @"resolution"];
        self.FPS        = [aDecoder decodeFloatForKey:  @"FPS"];
        self.FS         = [aDecoder decodeFloatForKey:  @"FS"];
        self.audioWidth = [aDecoder decodeFloatForKey:  @"audioWidth"];
        self.channel    = [aDecoder decodeIntegerForKey:@"channel"];
        self.videoType  = [aDecoder decodeObjectForKey:@"videoType"];
        self.filePath   = [aDecoder decodeObjectForKey:@"filePath"];
        self.createdDate= [aDecoder decodeObjectForKey:@"createdDate"];
        self.videoMaterial = [[aDecoder decodeObjectForKey:@"videoMaterial"] mutableCopy];
        self.timeScale  = [aDecoder decodeIntegerForKey:@"timeScale"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:self.uid        forKey:@"uid"];
    [aCoder encodeInteger:self.fileSize   forKey:@"fileSize"];
    [aCoder encodeInteger:self.frameCount forKey:@"frameCount"];
    [aCoder encodeCGSize: self.resolution forKey:@"resolution"];
    [aCoder encodeFloat:  self.FPS        forKey:@"FPS"];
    [aCoder encodeFloat:  self.FS         forKey:@"FS"];
    [aCoder encodeFloat:  self.audioWidth forKey:@"audioWidth"];
    [aCoder encodeInteger:self.channel    forKey:@"channel"];
    [aCoder encodeObject: self.videoType  forKey:@"videoType"];
    [aCoder encodeObject: self.filePath   forKey:@"filePath"];
    [aCoder encodeObject: self.createdDate forKey:@"createdDate"];
    [aCoder encodeObject: [self.videoMaterial copy] forKey:@"videoMaterial"];
    [aCoder encodeInteger:self.timeScale forKey:@"timeScale"];
}

@end

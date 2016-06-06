//
//  VideoClient.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/2.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import "VideoClient.h"
#import "HJImagesToVideo.h"
#import "SaveLoadInfoManager.h"
#import "BLPCMToWAV.h"
#import "BLMovieEncoder.h"

#define k10SecondFrameCount 750
#define kHDRecordingFrameCount 750
#define kFPS 25
#define kHDFPS 25 //scale = 2, actual fps = (2, 25) = 12.5fps


@implementation VideoClient

+ (VideoClient *)sharedVideoClient
{
    static VideoClient* instance = nil;
    if (instance == nil) {
        instance = [[VideoClient alloc] init];
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.videoDict = [[NSMutableDictionary alloc] init];
        self.dataCache = [CMDataStorage sharedCacheStorage];
        self.videoList = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Video / Frames Info Record operation

//- (void)setVideoHeadInfoWithHeadData:(NSData *)headData withVideoDict:(NSMutableDictionary *)videoDict
//{
////    videoInfo headInfo;
////    [headData  getBytes: &headData length:sizeof(headData)];
//    NSString *videoInfo = [[NSString alloc] initWithData:headData encoding:NSUTF8StringEncoding];
//    [videoDict setObject:videoInfo forKey:@"VideoInfo"];
//    
//    NSArray *infoArray= [videoInfo componentsSeparatedByString:@","];
//    //[videoDict setObject:infoArray[0] forKey:@"Name"];
//    [videoDict setObject:infoArray[1] forKey:@"Filesize"];
//    [videoDict setObject:infoArray[2] forKey:@"Framecount"];
//    [videoDict setObject:infoArray[3] forKey:@"ResolutionW"];
//    [videoDict setObject:infoArray[4] forKey:@"ResolutionL"];
//    [videoDict setObject:infoArray[5] forKey:@"FPS"];
//    [videoDict setObject:infoArray[6] forKey:@"FS"];
//    [videoDict setObject:infoArray[7] forKey:@"Audiowidth"];
//    [videoDict setObject:infoArray[8] forKey:@"Channel"];
//    self.eyemoreVideo = [[EyemoreVideo alloc] initWithProfileDict:infoArray];
//    //return videoDict;
//}
- (EyemoreVideo *)setEyemoreVideonfoWithHeadData:(NSData *)headData
{
    //    videoInfo headInfo;
    //    [headData  getBytes: &headData length:sizeof(headData)];
    NSString *videoInfo = [[NSString alloc] initWithData:headData encoding:NSUTF8StringEncoding];
    NSArray *infoArray= [videoInfo componentsSeparatedByString:@","];
    return [[EyemoreVideo alloc] initWithProfileDict:infoArray];
}
- (EyemoreVideo *)setEyemoreVideonfoWithString:(NSString *)headString
{
    //    videoInfo headInfo;
    //    [headData  getBytes: &headData length:sizeof(headData)];
    NSArray *infoArray= [headString componentsSeparatedByString:@","];
    return [[EyemoreVideo alloc] initWithProfileDict:infoArray];
}
//- (void)setFrameIndexArrayWithVideoDict:(NSMutableDictionary *)videoDict
//{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    [videoDict setObject:array forKey:@"FrameIndexs"];
//}
- (void)setFrameIndexArrayWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [eyemoreVideo.videoMaterial setObject:array forKey:@"FrameIndexs"];
}



//- (void)insertFrameImageIntoVideo:(NSMutableDictionary *)videoDict WithPath:(NSString *)path withIndex:(NSString *)index
//{
//    [videoDict setObject:path forKey:[NSString stringWithFormat:@"FrameNo.%@",index]];
//}
- (void)insertFrameImageIntoEyemoreVideo:(EyemoreVideo *)eyemoreVideo WithPath:(NSString *)path withIndex:(NSString *)index
{
    [eyemoreVideo.videoMaterial setObject:path forKey:[NSString stringWithFormat:@"FrameNo.%@",index]];
}




//- (void)insertFrameAudioIntoVideo:(NSMutableDictionary *)videoDict WithPath:(NSString *)path withIndex:(NSString *)index
//{
//    [videoDict setObject:path forKey:[NSString stringWithFormat:@"AudioNo.%@",index]];
//}
- (void)insertFrameAudioIntoEyemoreVideo:(EyemoreVideo *)eyemoreVideo WithPath:(NSString *)path withIndex:(NSString *)index
{
    [eyemoreVideo.videoMaterial setObject:path forKey:[NSString stringWithFormat:@"AudioNo.%@",index]];
}



//- (void)insertFrameIndexIntoVideo:(NSMutableDictionary *)videoDict withFrameIndex:(NSString *)frameindex withIndex:(NSString *)index
//{
//    if ([videoDict objectForKey:@"FrameIndexs"] == nil) {
//        [self setFrameIndexArrayWithVideoDict:videoDict];
//        [[videoDict objectForKey:@"FrameIndexs"] addObject:frameindex];
//    }
//    else [[videoDict objectForKey:@"FrameIndexs"] addObject:frameindex];
//}
- (void)insertFrameIndexIntoEyemoreVideo:(EyemoreVideo *)eyemoreVideo withFrameIndex:(NSString *)frameindex withIndex:(NSString *)index
{
    if ([eyemoreVideo.videoMaterial objectForKey:@"FrameIndexs"] == nil) {
        [self setFrameIndexArrayWithEyemoreVideo:eyemoreVideo];
        [[eyemoreVideo.videoMaterial objectForKey:@"FrameIndexs"] addObject:frameindex];
    }
    else [[eyemoreVideo.videoMaterial objectForKey:@"FrameIndexs"] addObject:frameindex];
}




//- (NSArray *)checkingDroppedFramesWithVideoDict:(NSMutableDictionary *)videoDict
//{
//    NSMutableArray *frames        = [videoDict objectForKey:@"FrameIndexs"];
//    NSMutableArray *droppedFrames = [[NSMutableArray alloc] init];
//    long int firstframe           = [frames[0] intValue];
//    int framesCount = 0;
//    for (long int i = firstframe; i < firstframe + k10SecondFrameCount; i ++) {
////        if ([frames[i - firstframe] intValue] > i) {
////            [droppedFrames addObject:[NSString stringWithFormat:@"%ld", i]];
////        }
//        if ([frames[framesCount] intValue] != i) {
//            [droppedFrames addObject:[NSString stringWithFormat:@"%ld", i]];
//        }
//        else {
//            framesCount++;
//        }
//    }
//    if (droppedFrames.count != 0) {
//        return droppedFrames;
//    }
//    else return nil;
//}
- (NSArray *)checkingDroppedFramesWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    NSMutableArray *frames        = [eyemoreVideo.videoMaterial objectForKey:@"FrameIndexs"];
    NSMutableArray *droppedFrames = [[NSMutableArray alloc] init];
    long int firstframe           = [frames[0] intValue];
    int framesCount = 0;
    for (long int i = firstframe; i < firstframe + k10SecondFrameCount; i ++) {
        //        if ([frames[i - firstframe] intValue] > i) {
        //            [droppedFrames addObject:[NSString stringWithFormat:@"%ld", i]];
        //        }
        if ([frames[framesCount] intValue] != i) {
            [droppedFrames addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        else {
            framesCount++;
        }
    }
    if (droppedFrames.count != 0) {
        return droppedFrames;
    }
    else return nil;
}




#pragma mark - Frame Date Analysis & store & get

- (void)storeVideoFrameWithData:(NSData *)frameData WithPath:(NSString *)string
{
    NSLog(@"开始写入帧");
    [self.dataCache writeData:frameData key:string];
}

- (void)storeVideoAudioPieceWithData:(NSData *)audioPieceData withPath:(NSString *)string
{
    [self.dataCache writeData:audioPieceData key:string];
}



//- (void)recordFrameContentWithFrameImage:(NSData *)imageData withFrameAudio:(NSData *)audioData withFrameIndex:(NSString *)frameIndex withIndex:(int)index  withVideoDict:(NSMutableDictionary *)videoDict
//{
//    //帧存放的keypath
//    
//    NSString *imagePath = [NSString stringWithFormat:@"video%@FrameNo.%@",[videoDict objectForKey:@"Name"], frameIndex];
//    NSString *audioPath = [NSString stringWithFormat:@"video%@AudioNo.%@",[videoDict objectForKey:@"Name"], frameIndex];
//    NSLog(@"image path :%@", imagePath);
//    if (frameIndex != nil) {
//        [self insertFrameIndexIntoVideo:videoDict withFrameIndex:frameIndex withIndex:nil];
//    }
//    
//    if (imageData != nil) {
//        [self insertFrameImageIntoVideo:videoDict WithPath:imagePath withIndex:frameIndex];
//        [self storeVideoFrameWithData:imageData WithPath:imagePath];
//
//    }
//    
//    if (audioData != nil) {
//        [self insertFrameAudioIntoVideo:videoDict WithPath:audioPath withIndex:frameIndex];
//        [self storeVideoAudioPieceWithData:audioData withPath:audioPath];
//    }
//}
- (void)recordFrameContentWithFrameImage:(NSData *)imageData withFrameAudio:(NSData *)audioData withFrameIndex:(NSString *)frameIndex withIndex:(int)index  withEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    //帧存放的keypath
    
    NSString *imagePath = [NSString stringWithFormat:@"video%ldFrameNo.%@",(long)eyemoreVideo.uid, frameIndex];
    NSString *audioPath = [NSString stringWithFormat:@"video%ldAudioNo.%@",(long)eyemoreVideo.uid, frameIndex];
    NSLog(@"image path :%@", imagePath);
    if (frameIndex != nil) {
        [self insertFrameIndexIntoEyemoreVideo:eyemoreVideo withFrameIndex:frameIndex withIndex:nil];
    }
    
    if (imageData != nil) {
        [self insertFrameImageIntoEyemoreVideo:eyemoreVideo WithPath:imagePath withIndex:frameIndex];
        [self storeVideoFrameWithData:imageData WithPath:imagePath];
        
    }
    
    if (audioData != nil) {
        [self insertFrameAudioIntoEyemoreVideo:eyemoreVideo WithPath:audioPath withIndex:frameIndex];
        [self storeVideoAudioPieceWithData:audioData withPath:audioPath];
    }
}




//- (void)recordMultiFramesContentWithDataArray:(NSArray *)dataArray withStartFrame:(int)startIndex withFrameCount:(int)frameCount withVideoDict:(NSMutableDictionary *)videoDict
//{
//    for (int i = 0; i < dataArray.count; i ++) {
//        if (i % 3 == 0) {
//            
//        }
//        if (i % 3 == 1) {
////            [self recordFrameContentWithFrameImage:dataArray[i - 1] withFrameAudio:dataArray[i] withIndex:startIndex withVideoDict:videoDict];
////            startIndex ++;
//        }
//        if (i % 3 == 2) {
//            [self recordFrameContentWithFrameImage:dataArray[i - 1] withFrameAudio:dataArray[i] withFrameIndex:dataArray[i - 2] withIndex:startIndex withVideoDict:videoDict];
//            startIndex ++;
//        }
//    }
//}
- (void)recordMultiFramesContentWithDataArray:(NSArray *)dataArray withStartFrame:(int)startIndex withFrameCount:(int)frameCount withEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    for (int i = 0; i < dataArray.count; i ++) {
        if (i % 3 == 0) {
            
        }
        if (i % 3 == 1) {
            //            [self recordFrameContentWithFrameImage:dataArray[i - 1] withFrameAudio:dataArray[i] withIndex:startIndex withVideoDict:videoDict];
            //            startIndex ++;
        }
        if (i % 3 == 2) {
            [self recordFrameContentWithFrameImage:dataArray[i - 1] withFrameAudio:dataArray[i] withFrameIndex:dataArray[i - 2] withIndex:startIndex withEyemoreVideo:eyemoreVideo];
            startIndex ++;
        }
    }
}





- (NSMutableArray *)decodeFrameData:(NSData *)frameData withStartFrame:(int)startIndex withFrameCount:(int)frameCount
{
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    //NSMutableArray *audioArray = [[NSMutableArray alloc] init];
    
    NSData *jpgSizeData   = [[NSData alloc] init];
    NSData *audioSizeData = [[NSData alloc] init];
    NSData *frameIndexData = [[NSData alloc] init];
    int jpgSize;
    int audioSize;
    unsigned int frameIndex;
    NSData *imageData = [[NSData alloc] init];
    NSData *audioData = [[NSData alloc] init];


    long int t = 0;
    
    for (int i = 0; i < frameCount; i++) {
        if (i == 0) {
            
            frameIndexData = [frameData subdataWithRange:NSMakeRange(0, 4)];
            [frameIndexData getBytes:&frameIndex length:4];
            NSLog(@"frame index is :%u",frameIndex);
            
            jpgSizeData    = [frameData subdataWithRange:NSMakeRange(4, 4)];
            [jpgSizeData   getBytes:&jpgSize length:4];
            NSLog(@"jpg size is :%d",jpgSize);
            imageData      = [frameData subdataWithRange:NSMakeRange(8, jpgSize)];
            
            audioSizeData  = [frameData subdataWithRange:NSMakeRange(8 + jpgSize, 4)];
            [audioSizeData getBytes:&audioSize length:4];
            NSLog(@"audio size is :%d",audioSize);
            if (audioSize == 0) {
                audioData = [frameData subdataWithRange:NSMakeRange(4, 4)];
            }
            else audioData      = [frameData subdataWithRange:NSMakeRange(8 + jpgSize + 4, audioSize)];
            
        }
        else {
            NSLog(@"frameCount is :%u",frameCount);
            frameIndexData = [frameData subdataWithRange:NSMakeRange(t, 4)];
            [frameIndexData getBytes:&frameIndex length:4];
            NSLog(@"frame index is :%u",frameIndex);

            jpgSizeData    = [frameData subdataWithRange:NSMakeRange(t + 4, 4)];
            [jpgSizeData   getBytes:&jpgSize length:4];
            NSLog(@"jpg size is :%d",jpgSize);
            imageData      = [frameData subdataWithRange:NSMakeRange(t + 4 + 4, jpgSize)];
            
            audioSizeData  = [frameData subdataWithRange:NSMakeRange(t + 4 + 4 + jpgSize, 4)];
            [audioSizeData getBytes:&audioSize length:4];
            NSLog(@"audio size is :%d",audioSize);
            if (audioSize == 0) {
                //audioData = [frameData subdataWithRange:NSMakeRange(4, 4)];
                audioData = [@"NoData" dataUsingEncoding:NSUTF8StringEncoding];
            }
            else {
                audioData= [frameData subdataWithRange:NSMakeRange(t + 4 + 4 + jpgSize + 4, audioSize)];
                NSLog(@"audio audioData is :%lu",(unsigned long)[audioData length]);
            }
        }
        
        [dataArray addObject:[NSString stringWithFormat:@"%u", frameIndex]];
        [dataArray addObject:imageData];
        [dataArray addObject:audioData];
        t = t + 4 + 4 + jpgSize + 4 + audioSize;
       
    }
    
    frameData = nil;
    jpgSizeData = nil;
    audioSizeData = nil;
    frameIndexData = nil;
    audioData = nil;
    imageData = nil;
    
    return dataArray;
}

//- (NSData *)getFrameImageDataWithVideoDict:(NSMutableDictionary *)videoDict withIndex:(long int)index
//{
//    NSString *imagePath = [videoDict objectForKey:[NSString stringWithFormat:@"FrameNo.%ld",index]];
//    NSData *imageData = [self.dataCache dataForKey:imagePath];
//    return imageData;
//}
- (NSData *)getFrameImageDataWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo withIndex:(long int)index
{
    NSString *imagePath = [eyemoreVideo.videoMaterial objectForKey:[NSString stringWithFormat:@"FrameNo.%ld",index]];
    NSData *imageData = [self.dataCache dataForKey:imagePath];
    return imageData;
}




//- (NSData *)getFrameAudioDataWithVideoDict:(NSMutableDictionary *)videoDict withIndex:(long int)index
//{
//    NSString *audioPath = [videoDict objectForKey:[NSString stringWithFormat:@"AudioNo.%ld",index]];
//    NSData *audioData = [self.dataCache dataForKey:audioPath];
//    return audioData;
//}
- (NSData *)getFrameAudioDataWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo withIndex:(long int)index
{
    NSString *audioPath = [eyemoreVideo.videoMaterial objectForKey:[NSString stringWithFormat:@"AudioNo.%ld",index]];
    NSData *audioData = [self.dataCache dataForKey:audioPath];
    return audioData;
}

#pragma mark - Video Graphic Processing Part

//- (void)encodeMovieFromImagesWithVideoInfo:(NSMutableDictionary *)dict withCallBackBlock:(SuccessBlock)callBackBlock
//{
//    NSString *videoType = [dict objectForKey:@"VideoType"];
//
//    //配置视频保存路径
//    NSString *key = [NSString stringWithFormat:@"movie%@.mp4",[dict objectForKey:@"Name"]];
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", key]];
//    [dict setObject:key forKey:@"MoviePath"];
//    //加载视频帧缓存
//    int framecount = 0;
//    self.arrayOfImages = [[NSMutableArray alloc] init];
//    if ([videoType isEqualToString:@"LD_RECORDING"]) {
//        framecount = k10SecondFrameCount;
//    }
//    if ([videoType isEqualToString:@"HD_RECORDING"]) {
//        //framecount = kHDRecordingFrameCount;
//        framecount = kHDRecordingFrameCount;
//    }
//    //载入帧路径
//    NSMutableArray *array = [dict objectForKey:@"FrameIndexs"];
//    long int firstIndex = [array[0] intValue];
//    
//    for (long int i = firstIndex; i < firstIndex + framecount; i++) {
//        
//        if ([dict objectForKey:[NSString stringWithFormat:@"FrameNo.%ld",i]]) {
//            NSLog(@"开始获取帧并放入内存%ld", i);
//            UIImage *image = [[UIImage alloc] initWithData:[self getFrameImageDataWithVideoDict:dict withIndex:i]];
//            [self.arrayOfImages addObject:image];
//            image = nil;
//        }
//    }
//    
//    NSLog(@"images count: %lu",(unsigned long)self.arrayOfImages.count);
//    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
//    NSURL *furl = [[NSURL alloc] initFileURLWithPath:path];
//    
//    //编码视频
//    //NSDictionary *settings = [[NSDictionary alloc] init];
//    if ([videoType isEqualToString:@"LD_RECORDING"]) {
//        //settings = [CEMovieMaker videoSettingsWithCodec:AVVideoCodecH264 withWidth:480 andHeight:270];
//         BLMovieEncoder *encoder = [[BLMovieEncoder alloc] initWithEncodec:AVVideoCodecH264 FPS:CMTimeMake(1, kFPS) Width:480 Height:270 OutputFileURL:furl];
//        [encoder encodeMovieWithImages:self.arrayOfImages withCompletion:^(NSURL *fileURL){
//            
//                    NSLog(@"file url :%@",fileURL);
//                    [self recordVideoDateInfoWithVideo:dict];
//                    //[self.videoList addObject:dict];
//                    NSLog(@"self.video list :%@， dict:%@",self.videoList,dict);
//            
//                    //[SaveLoadInfoManager  saveAppInfoWithVideoClient:[VideoClient sharedVideoClient]];
//                    [self.arrayOfImages removeAllObjects];
//            
//                    if (fileURL) {
//                        callBackBlock(YES);
//                    }
//                    else {
//                        callBackBlock(NO);
//                    }
//        }];
//
//    }
//         
//    if ([videoType isEqualToString:@"HD_RECORDING"]) {
//        
//         BLMovieEncoder *encoder = [[BLMovieEncoder alloc] initWithEncodec:AVVideoCodecH264 FPS:CMTimeMake(1, kHDFPS) Width:960 Height:540 OutputFileURL:furl];
//        [encoder encodeMovieWithImages:self.arrayOfImages withCompletion:^(NSURL *fileURL){
//            
//            NSLog(@"file url :%@",fileURL);
//            [self recordVideoDateInfoWithVideo:dict];
//            //[self.videoList addObject:dict];
//            NSLog(@"self.video list :%@， dict:%@",self.videoList,dict);
//            
//            //[SaveLoadInfoManager  saveAppInfoWithVideoClient:[VideoClient sharedVideoClient]];
//            [self.arrayOfImages removeAllObjects];
//            
//            if (fileURL) {
//                callBackBlock(YES);
//            }
//            else {
//                callBackBlock(NO);
//            }
//        }];
//    }
//}
- (void)encodeMovieFromImagesWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo withCallBackBlock:(SuccessBlock)callBackBlock
{
    NSString *videoType = eyemoreVideo.videoType;
    
    //配置视频保存路径
    NSString *key = [NSString stringWithFormat:@"movie%ld.mp4",(long)eyemoreVideo.uid];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", key]];
    [eyemoreVideo.videoMaterial setObject:key forKey:@"MoviePath"];
    //加载视频帧缓存
    int framecount = 0;
    self.arrayOfImages = [[NSMutableArray alloc] init];
    if ([videoType isEqualToString:@"LD_RECORDING"]) {
        framecount = k10SecondFrameCount;
    }
    if ([videoType isEqualToString:@"HD_RECORDING"]) {
        //framecount = kHDRecordingFrameCount;
        framecount = kHDRecordingFrameCount;
    }
    //载入帧路径
    NSMutableArray *array = [eyemoreVideo.videoMaterial objectForKey:@"FrameIndexs"];
    long int firstIndex = [array[0] intValue];
    
    for (long int i = firstIndex; i < firstIndex + framecount; i++) {
        
        if ([eyemoreVideo.videoMaterial objectForKey:[NSString stringWithFormat:@"FrameNo.%ld",i]]) {
            NSLog(@"开始获取帧并放入内存%ld", i);
            UIImage *image = [[UIImage alloc] initWithData:[self getFrameImageDataWithEyemoreVideo:eyemoreVideo withIndex:i]];
            [self.arrayOfImages addObject:image];
            image = nil;
        }
    }
    
    NSLog(@"images count: %lu",(unsigned long)self.arrayOfImages.count);
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    NSURL *furl = [[NSURL alloc] initFileURLWithPath:path];
    
    //编码视频
    //NSDictionary *settings = [[NSDictionary alloc] init];
    if ([videoType isEqualToString:@"LD_RECORDING"]) {
        //settings = [CEMovieMaker videoSettingsWithCodec:AVVideoCodecH264 withWidth:480 andHeight:270];
        BLMovieEncoder *encoder = [[BLMovieEncoder alloc] initWithEncodec:AVVideoCodecH264 FPS:CMTimeMake(1, kFPS) Width:480 Height:270 OutputFileURL:furl];
        [encoder encodeMovieWithImages:self.arrayOfImages withCompletion:^(NSURL *fileURL){
            
            NSLog(@"file url :%@",fileURL);
            [self recordVideoDateInfoWithEyemoreVideo:eyemoreVideo];
            //[self.videoList addObject:dict];
            NSLog(@"encoded eyemore video material:%@",eyemoreVideo.videoMaterial);
            
            //[SaveLoadInfoManager  saveAppInfoWithVideoClient:[VideoClient sharedVideoClient]];
            [self.arrayOfImages removeAllObjects];
            
            if (fileURL) {
                callBackBlock(YES);
            }
            else {
                callBackBlock(NO);
            }
        }];
        
    }
    
    if ([videoType isEqualToString:@"HD_RECORDING"]) {
        
        BLMovieEncoder *encoder = [[BLMovieEncoder alloc] initWithEncodec:AVVideoCodecH264 FPS:CMTimeMake(1, kFPS) Width:960 Height:540 OutputFileURL:furl];
        [encoder encodeMovieWithImages:self.arrayOfImages withCompletion:^(NSURL *fileURL){
            
            NSLog(@"file url :%@",fileURL);
            [self recordVideoDateInfoWithEyemoreVideo:eyemoreVideo];
            //[self.videoList addObject:dict];
            NSLog(@"encoded eyemore video material:%@",eyemoreVideo.videoMaterial);
            
            //[SaveLoadInfoManager  saveAppInfoWithVideoClient:[VideoClient sharedVideoClient]];
            [self.arrayOfImages removeAllObjects];
            
            if (fileURL) {
                callBackBlock(YES);
            }
            else {
                callBackBlock(NO);
            }
        }];
    }
}

#pragma mark - Video Operation /saving /loading /removing

- (void)saveVideoToLocalAlbumWithVideoInfo:(NSMutableDictionary *)dict
{
    UISaveVideoAtPathToSavedPhotosAlbum([dict objectForKey:@"MoviePath"], self, nil, nil);
}

- (void)removeVideoFrameIndexWithVideoInfo:(NSMutableDictionary *)dict
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [dict setObject:array forKey:@"FrameIndexs"];
}

//- (void)removeVideoWithVideoInfo:(NSMutableDictionary *)dict
//{
//    //文件名
//    //删除视频画面文件
//    [self removeVideoFrameWithInfo:dict];
//    //删除音频文件
//    [self removeVideoAudioWithInfo:dict];
//    //删除完整带音乐视频文件
//    [self removeCompleteVideoWithInfo:dict];
//    //删除视频帧缓存
//    [self cleanVideoFramesCache];
//    //保存删除
//    [self.videoList removeObject:dict];
//    [SaveLoadInfoManager saveAppInfoWithVideoClient:[VideoClient sharedVideoClient]];
//
//}

- (void)removeVideoWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    //文件名
    //删除视频画面文件
    [self removeVideoFrameWithEyemoreVideo:eyemoreVideo];
    //删除音频文件
    [self removeVideoAudioWithEyemoreVideo:eyemoreVideo];
    //删除完整带音乐视频文件
    [self removeCompleteVideoWithEyemoreVideo:eyemoreVideo];
    //删除视频帧缓存
    [self cleanVideoFramesCache];
    //保存删除
    //[[VideoConfig sharedVideoConfig] removeEyemoreVideo:eyemoreVideo];
    //[[VideoConfig sharedVideoConfig] synchonizeEyemoreVideos];
    
}

//- (void)removeVideoAudioWithInfo:(NSMutableDictionary *)dict
//{
//    //删除音频文件
//    NSString *audioPath = [self getVideoAudioFilePathWithVideoInfo:dict];
//    BOOL audioHave = [[NSFileManager defaultManager] fileExistsAtPath:audioPath];
//    if (!audioHave) {
//        NSLog(@"audio file doesn't exist, no need to remove");
//        return;
//    }
//    else{
//        NSLog(@"audio file already exist, now removing");
//        [[NSFileManager defaultManager] removeItemAtPath:audioPath error:nil];
//    }
//}
- (void)removeVideoAudioWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    //删除音频文件
    NSString *audioPath = [self getVideoAudioFilePathWithEyemoreVideo:eyemoreVideo];
    BOOL audioHave = [[NSFileManager defaultManager] fileExistsAtPath:audioPath];
    if (!audioHave) {
        NSLog(@"audio file doesn't exist, no need to remove");
        return;
    }
    else{
        NSLog(@"audio file already exist, now removing");
        [[NSFileManager defaultManager] removeItemAtPath:audioPath error:nil];
    }
}
//- (void)removeVideoFrameWithInfo:(NSMutableDictionary *)dict
//{
//    //删除视频画面文件
//    NSString *path = [self getVideoFilePathWithVideoInfo:dict];
//    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:path];
//    if (!blHave) {
//        NSLog(@"video file doesn't exist,no need to remove");
//        return ;
//    }
//    else
//    {
//        NSLog(@"video file already exist,now removing");
//        BOOL blDele= [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
//        if (blDele) {
//            //NSLog(@"dele success");
//            //[self.videoList removeObject:dict];
//            //[SaveLoadInfoManager saveAppInfoWithVideoClient:[VideoClient sharedVideoClient]];
//        }else {
//            // NSLog(@"dele fail");
//        }
//    }
//}
- (void)removeVideoFrameWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    //删除视频画面文件
    NSString *path = [self getVideoFilePathWithEyemoreVideo:eyemoreVideo];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:path];
    if (!blHave) {
        NSLog(@"video file doesn't exist,no need to remove");
        return ;
    }
    else
    {
        NSLog(@"video file already exist,now removing");
        BOOL blDele= [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        if (blDele) {
            //NSLog(@"dele success");
            //[self.videoList removeObject:dict];
            //[SaveLoadInfoManager saveAppInfoWithVideoClient:[VideoClient sharedVideoClient]];
        }else {
            // NSLog(@"dele fail");
        }
    }
}
//- (void)removeCompleteVideoWithInfo:(NSMutableDictionary *)dict
//{
//    //删除完整带音乐视频文件
//    NSString *completeMoviePath = [self getCompleteVideoFilePathWithVideoInfo:dict];
//    BOOL completeHave = [[NSFileManager defaultManager] fileExistsAtPath:completeMoviePath];
//    if (!completeHave) {
//        NSLog(@"complete movie file doesn't exist, no need to remove");
//        return;
//    }
//    else{
//        NSLog(@"complete movie file already exist, now removing");
//        [[NSFileManager defaultManager] removeItemAtPath:completeMoviePath error:nil];
//    }
//}
- (void)removeCompleteVideoWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    //删除完整带音乐视频文件
    NSString *completeMoviePath = [self getCompleteVideoFilePathWithEyemoreVideo:eyemoreVideo];
    BOOL completeHave = [[NSFileManager defaultManager] fileExistsAtPath:completeMoviePath];
    if (!completeHave) {
        NSLog(@"complete movie file doesn't exist, no need to remove");
        return;
    }
    else{
        NSLog(@"complete movie file already exist, now removing");
        [[NSFileManager defaultManager] removeItemAtPath:completeMoviePath error:nil];
    }
}

//- (UIImage *)getThumbnailImageWithVideoInfo:(NSMutableDictionary *)dict
//{
////    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", [dict objectForKey:@"MoviePath"]]];
////    NSURL *videoURL = [[NSURL alloc] initFileURLWithPath:path];
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[self getCompleteVideFileURLWithVideoInfo:dict] options:nil];
//    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//    gen.appliesPreferredTrackTransform = YES;
//    CMTime time = CMTimeMakeWithSeconds(0.0, 1);
//    NSError *error = nil;
//    CMTime actualTime;
//    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
//    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
//    CGImageRelease(image);
//    return thumb;
//}
- (UIImage *)getThumbnailImageWithEyemoeVideo:(EyemoreVideo *)eyemoreVideo
{
    //    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", [dict objectForKey:@"MoviePath"]]];
    //    NSURL *videoURL = [[NSURL alloc] initFileURLWithPath:path];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[self getCompleteVideFileURLWithEyemoreVideo:eyemoreVideo] options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 1);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}

//- (void)recordVideoDateInfoWithVideo:(NSMutableDictionary *)dict
//{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//    NSString *currentDate = [formatter stringFromDate:[NSDate date]];
//    [dict setObject:currentDate forKey:@"MovieDate"];
//}
- (void)recordVideoDateInfoWithEyemoreVideo:(EyemoreVideo *)video
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *currentDate = [formatter stringFromDate:[NSDate date]];
    video.createdDate = currentDate;
}



- (void)cleanVideoFramesCache
{
    [self.dataCache removeAllWithBlock:nil];
}

#pragma mark - Video URL & Path

//- (NSURL *)getVideoFileURLWithVideoInfo:(NSMutableDictionary *)dict
//{
//    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", [dict objectForKey:@"MoviePath"]]];
//    NSURL *videoURL = [[NSURL alloc] initFileURLWithPath:path];
//    return videoURL;
//}
- (NSURL *)getVideoFileURLWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", [eyemoreVideo.videoMaterial objectForKey:@"MoviePath"]]];
    NSURL *videoURL = [[NSURL alloc] initFileURLWithPath:path];
    return videoURL;
}

//- (NSString *)getVideoFilePathWithVideoInfo:(NSMutableDictionary *)dict
//{
//    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", [dict objectForKey:@"MoviePath"]]];
//    return path;
//}
- (NSString *)getVideoFilePathWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    NSLog(@"movie path : %@", eyemoreVideo.videoMaterial);
    NSString * path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", [eyemoreVideo.videoMaterial objectForKey:@"MoviePath"]]];
    return path;
}

//- (NSString *)getVideoAudioFilePathWithVideoInfo:(NSMutableDictionary *)dict
//{
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", [dict objectForKey:@"AudioPath"]]];
//    return path;
//}
- (NSString *)getVideoAudioFilePathWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", [eyemoreVideo.videoMaterial objectForKey:@"AudioPath"]]];
    return path;
}

//- (NSURL *)getVideoAudioFileURLWithVideoInfo:(NSMutableDictionary *)dict
//{
//    NSURL *audioURL = [[NSURL alloc] initFileURLWithPath:[self getVideoAudioFilePathWithVideoInfo:dict]];
//    return audioURL;
//}
- (NSURL *)getVideoAudioFileURLWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    NSURL *audioURL = [[NSURL alloc] initFileURLWithPath:[self getVideoAudioFilePathWithEyemoreVideo:eyemoreVideo]];
    return audioURL;
}


//- (NSString *)getCompleteVideoFilePathWithVideoInfo:(NSMutableDictionary *)dict
//{
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", [dict objectForKey:@"FinalMovie"]]];
//    return path;
//}
- (NSString *)getCompleteVideoFilePathWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", eyemoreVideo.filePath]];
    return path;
}

//- (NSURL *)getCompleteVideFileURLWithVideoInfo:(NSMutableDictionary *)dict
//{
//    NSURL *url = [[NSURL alloc] initFileURLWithPath:[self getCompleteVideoFilePathWithVideoInfo:dict]];
//    return url;
//}
- (NSURL *)getCompleteVideFileURLWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    NSURL *url = [[NSURL alloc] initFileURLWithPath:[self getCompleteVideoFilePathWithEyemoreVideo:eyemoreVideo]];
    return url;
}

#pragma mark -  Audio Processing Part

//- (NSMutableData *)appendFrameAudioDataWithVideoInfo:(NSMutableDictionary *)dict
//{
//    NSMutableData *data = [[NSMutableData alloc] init];
//    NSString *videoType = [dict objectForKey:@"VideoType"];
//    int framecount = 0;
//    if ([videoType isEqualToString:@"LD_RECORDING"]) {
//        framecount = k10SecondFrameCount;
//    }
//    if ([videoType isEqualToString:@"HD_RECORDING"]) {
//        framecount = k10SecondFrameCount;
//    }
//    //载入帧路径
//    NSMutableArray *array = [dict objectForKey:@"FrameIndexs"];
//    long int firstIndex = [array[0] intValue];
//    
//    for (long int i = firstIndex; i < firstIndex + framecount; i++) {
//        //NSLog(@"开始载入帧声音入内存: %d", i);
//        if ([dict objectForKey:[NSString stringWithFormat:@"AudioNo.%ld",i]]) {
//            [data appendData:[self getFrameAudioDataWithVideoDict:dict withIndex:i]];
//        }
//    }
//    return data;
//}
- (NSData *)appendFrameAudioDataWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSString *videoType = eyemoreVideo.videoType;
    int framecount = 0;
    if ([videoType isEqualToString:@"LD_RECORDING"]) {
        framecount = k10SecondFrameCount;
    }
    if ([videoType isEqualToString:@"HD_RECORDING"]) {
        framecount = kHDRecordingFrameCount;
    }
    //载入帧路径
    NSMutableArray *array = [eyemoreVideo.videoMaterial objectForKey:@"FrameIndexs"];
    long int firstIndex = [array[0] intValue];
    int count = 0;
    for (long int i = firstIndex; i < firstIndex + framecount; i++) {
        //NSLog(@"开始载入帧声音入内存: %d", i);
        if ([eyemoreVideo.videoMaterial objectForKey:[NSString stringWithFormat:@"AudioNo.%ld",i]]) {
            NSData *audioData = [NSData dataWithData:[self getFrameAudioDataWithEyemoreVideo:eyemoreVideo withIndex:i]];
            //([audioData length] > 4)用于去除产生的4字节多余文件（具体产生原因仍需查询）
            if (![[[NSString alloc] initWithData:audioData encoding:NSUTF8StringEncoding] isEqualToString:@"NoData"] && ([audioData length] > 4)) {
                [data appendData:audioData];
                count++;
                NSLog(@"audio frame data appending count: %d", count);
            }
        }
    }
    //NSLog(@"audio data lenth: %lu, %f", (unsigned long)[data length], (float)[data length] / 96000.0);
    //去除播放开始的渣音
    return [data subdataWithRange:NSMakeRange(40000, [data length] - 40000)];
}

//- (void)storeVideoAudioData:(NSMutableData *)data withVideoDict:(NSMutableDictionary *)dict
//{
//    //配置音频保存路径
//    NSString *key = [NSString stringWithFormat:@"Audio%@.wav",[dict objectForKey:@"Name"]];
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", key]];
//    [dict setObject:key forKey:@"AudioPath"];
//    [data writeToFile:path atomically:YES];
//
//}
- (void)storeVideoAudioData:(NSMutableData *)data withEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    //配置音频保存路径
    NSString *key = [NSString stringWithFormat:@"Audio%ld.wav",(long)eyemoreVideo.uid];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", key]];
    [eyemoreVideo.videoMaterial setObject:key forKey:@"AudioPath"];
    [data writeToFile:path atomically:YES];
    
}

//- (void)generateVideoAudioWithVideoInfo:(NSMutableDictionary *)dict
//{
//    [self storeVideoAudioData:[BLPCMToWAV convertPCMToWavWith:[self appendFrameAudioDataWithVideoInfo:dict]
//                                                   withSample:48000
//                                                      channel:1
//                                                          bps:16] withVideoDict:dict];
//}
- (void)generateVideoAudioWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    [self storeVideoAudioData:[BLPCMToWAV convertPCMToWavWith:[self appendFrameAudioDataWithEyemoreVideo:eyemoreVideo]
                                                   withSample:48000
                                                      channel:1
                                                          bps:16] withEyemoreVideo:eyemoreVideo];
}


//- (void)addAudioTrackIntoMovieWithDict:(NSMutableDictionary *)dict withCallBackBlock:(SuccessBlock)callBackBlock
//{
//    AVMutableComposition* mixComposition = [AVMutableComposition composition];
//    
//    //NSString *bundleDirectory = [[NSBundle mainBundle] bundlePath];
//    // audio input file...
//    NSString *audio_inputFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", [dict objectForKey:@"AudioPath"]]];
//    NSURL    *audio_inputFileUrl = [NSURL fileURLWithPath:audio_inputFilePath];
//    
//    // this is the video file that was just written above, full path to file is in --> videoOutputPath
//    NSString *video_inputFilePath =[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", [dict objectForKey:@"MoviePath"]]];
//    NSURL    *video_inputFileUrl = [NSURL fileURLWithPath:video_inputFilePath];
//    
//    // create the final video output file as MOV file - may need to be MP4, but this works so far...
//    NSString *finalKey = [NSString stringWithFormat:@"FinalMovie%@.mp4",[dict objectForKey:@"Name"]];
//    NSString *outputFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", finalKey]];
//    [dict setObject:finalKey forKey:@"FinalMovie"];
//
//    NSURL    *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
//    
//    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
//        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
//    
//    CMTime nextClipStartTime = kCMTimeZero;
//    
//    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
//    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
//    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
//    
//    //nextClipStartTime = CMTimeAdd(nextClipStartTime, a_timeRange.duration);
//    
//    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
//    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
//    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];
//    
//    
//    
//    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
//    //_assetExport.shouldOptimizeForNetworkUse = YES;
//    //_assetExport.outputFileType = @"com.apple.quicktime-movie";
//    _assetExport.outputFileType = @"public.mpeg-4";
//    //NSLog(@"support file types= %@", [_assetExport supportedFileTypes]);
//    _assetExport.outputURL = outputFileUrl;
//    
//    [_assetExport exportAsynchronouslyWithCompletionHandler:
//     ^(void ) {
//         //[self saveVideoToAlbum:outputFilePath];
//
//        callBackBlock(YES);
//     }
//     ];
//    
//    ///// THAT IS IT DONE... the final video file will be written here...
//    NSLog(@"DONE.....outputFilePath--->%@", outputFilePath);
//
//}
- (void)addAudioTrackIntoMovieWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo withCallBackBlock:(SuccessBlock)callBackBlock
{
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //NSString *bundleDirectory = [[NSBundle mainBundle] bundlePath];
    // audio input file...
    NSString *audio_inputFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", [eyemoreVideo.videoMaterial objectForKey:@"AudioPath"]]];
    NSURL    *audio_inputFileUrl = [NSURL fileURLWithPath:audio_inputFilePath];
    
    // this is the video file that was just written above, full path to file is in --> videoOutputPath
    NSString *video_inputFilePath =[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", [eyemoreVideo.videoMaterial objectForKey:@"MoviePath"]]];
    NSURL    *video_inputFileUrl = [NSURL fileURLWithPath:video_inputFilePath];
    
    // create the final video output file as MOV file - may need to be MP4, but this works so far...
    NSString *finalKey = [NSString stringWithFormat:@"FinalMovie%ld.mp4",(long)eyemoreVideo.uid];
    NSString *outputFilePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", finalKey]];
    eyemoreVideo.filePath = finalKey;
    
    NSURL    *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    eyemoreVideo.timeScale = videoAsset.duration.value;
    //nextClipStartTime = CMTimeAdd(nextClipStartTime, a_timeRange.duration);
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    //_assetExport.shouldOptimizeForNetworkUse = YES;
    //_assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputFileType = @"public.mpeg-4";
    //NSLog(@"support file types= %@", [_assetExport supportedFileTypes]);
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         //[self saveVideoToAlbum:outputFilePath];
         
         callBackBlock(YES);
     }
     ];
    
    ///// THAT IS IT DONE... the final video file will be written here...
    NSLog(@"DONE.....outputFilePath--->%@", outputFilePath);
    
}
#pragma mark - Final Composing

//- (void)composeCompleteMovieFileWithInfo:(NSMutableDictionary *)dict withCallBackBlock:(SuccessBlock)callBackBlock
//{
//    [self encodeMovieFromImagesWithVideoInfo:dict withCallBackBlock:^(BOOL success){
//        if (success) {
//            [self generateVideoAudioWithVideoInfo:dict];
//            [self addAudioTrackIntoMovieWithDict:dict withCallBackBlock:^(BOOL success){
//                if (success) {
//                    [SaveLoadInfoManager  saveAppInfoWithVideoClient:[VideoClient sharedVideoClient]];
//                    callBackBlock(YES);
//                }
//                else NSLog(@"adding audio file error");
//            }];
//        }
//        else NSLog(@"encode images failed");
//    }];
//}
- (void)composeCompleteMovieFileWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo withCallBackBlock:(SuccessBlock)callBackBlock
{
    [self encodeMovieFromImagesWithEyemoreVideo:eyemoreVideo withCallBackBlock:^(BOOL success){
        if (success) {
            [self generateVideoAudioWithEyemoreVideo:eyemoreVideo];
            [self addAudioTrackIntoMovieWithEyemoreVideo:eyemoreVideo withCallBackBlock:^(BOOL success){
                if (success) {
                    [[VideoConfig sharedVideoConfig] addEyemoreVideos:eyemoreVideo];
                    [[VideoConfig sharedVideoConfig] synchonizeEyemoreVideos];
                    callBackBlock(YES);
                }
                else NSLog(@"adding audio file error");
            }];
        }
        else NSLog(@"encode images failed");
    }];
}

@end


//
//  VideoClient.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/2.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMDataStorage.h"
//#import "MSImageMovieEncoder.h"
#import <UIKit/UIKit.h>
#import "EyemoreVideo.h"
#import "VideoConfig.h"

typedef struct {

    unsigned char name[4];
    unsigned char fileSize[4];
    unsigned char frameCount[4];
    unsigned char resolution[4];
    unsigned char FPS[4];
    unsigned char FS[4];
    unsigned char audioWidth[4];
    unsigned char channel[4];
    
}videoInfo;

@interface VideoClient : NSObject

typedef void(^SuccessBlock)(BOOL success);

@property (strong, nonatomic) NSMutableDictionary *videoDict;
@property (nonatomic, strong) CMDataStorage       *dataCache;
@property (nonatomic, strong) NSMutableArray      *videoList;
@property (nonatomic, strong) NSMutableArray      *arrayOfImages;
@property (nonatomic, strong) EyemoreVideo        *eyemoreVideo;


+ (VideoClient *)sharedVideoClient;
//- (void)setVideoHeadInfoWithHeadData:(NSData *)headData withVideoDict:(NSMutableDictionary *)videoDict;
//- (void)insertFrameImageIntoVideo:(NSMutableDictionary *)videoDict WithPath:(NSString *)path withIndex:(NSString *)index;
//- (void)insertFrameAudioIntoVideo:(NSMutableDictionary *)videoDict WithPath:(NSString *)path withIndex:(NSString *)index;
- (void)storeVideoFrameWithData:(NSData *)frameData WithPath:(NSString *)string;
- (void)storeVideoAudioPieceWithData:(NSData *)audioPieceData withPath:(NSString *)string;
//- (void)recordFrameContentWithFrameImage:(NSData *)imageData withFrameAudio:(NSData *)audioData withIndex:(int)index  withVideoDict:(NSMutableDictionary *)videoDict;
//- (void)recordFrameContentWithFrameImage:(NSData *)imageData withFrameAudio:(NSData *)audioData withFrameIndex:(NSString *)frameIndex withIndex:(int)index  withVideoDict:(NSMutableDictionary *)videoDict;
//- (void)recordMultiFramesContentWithDataArray:(NSArray *)dataArray withStartFrame:(int)startIndex withFrameCount:(int)frameCount withVideoDict:(NSMutableDictionary *)videoDict;
- (NSMutableArray *)decodeFrameData:(NSData *)frameData withStartFrame:(int)startIndex withFrameCount:(int)frameCount;
//
//- (NSData *)getFrameImageDataWithVideoDict:(NSMutableDictionary *)videoDict withIndex:(long int)index;
//- (void)encodeMovieFromImagesWithVideoInfo:(NSMutableDictionary *)dict withCallBackBlock:(SuccessBlock)callBackBlock;
//- (void)removeVideoWithVideoInfo:(NSMutableDictionary *)dict;
//- (UIImage *)getThumbnailImageWithVideoInfo:(NSMutableDictionary *)dict;
//
//- (NSURL *)getVideoFileURLWithVideoInfo:(NSMutableDictionary *)dict;
//- (NSString *)getVideoFilePathWithVideoInfo:(NSMutableDictionary *)dict;
//- (NSURL *)getCompleteVideFileURLWithVideoInfo:(NSMutableDictionary *)dict;
//- (NSString *)getCompleteVideoFilePathWithVideoInfo:(NSMutableDictionary *)dict;
//
//- (NSArray *)checkingDroppedFramesWithVideoDict:(NSMutableDictionary *)videoDict;
//
//- (void)generateVideoAudioWithVideoInfo:(NSMutableDictionary *)dict;
//- (void)addAudioTrackIntoMovieWithDict:(NSMutableDictionary *)dict withCallBackBlock:(SuccessBlock)callBackBlock;
//- (void)composeCompleteMovieFileWithInfo:(NSMutableDictionary *)dict withCallBackBlock:(SuccessBlock)callBackBlock;
//
//- (void)removeVideoFrameIndexWithVideoInfo:(NSMutableDictionary *)dict;
- (void)cleanVideoFramesCache;

- (EyemoreVideo *)setEyemoreVideonfoWithHeadData:(NSData *)headData;
- (EyemoreVideo *)setEyemoreVideonfoWithString:(NSString *)headString;

- (void)setFrameIndexArrayWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo;
- (void)insertFrameImageIntoEyemoreVideo:(EyemoreVideo *)eyemoreVideo WithPath:(NSString *)path withIndex:(NSString *)index;
- (void)insertFrameAudioIntoEyemoreVideo:(EyemoreVideo *)eyemoreVideo WithPath:(NSString *)path withIndex:(NSString *)index;
- (void)insertFrameIndexIntoEyemoreVideo:(EyemoreVideo *)eyemoreVideo withFrameIndex:(NSString *)frameindex withIndex:(NSString *)index;
- (NSArray *)checkingDroppedFramesWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo;
- (void)recordFrameContentWithFrameImage:(NSData *)imageData withFrameAudio:(NSData *)audioData withFrameIndex:(NSString *)frameIndex withIndex:(int)index  withEyemoreVideo:(EyemoreVideo *)eyemoreVideo;
- (void)recordMultiFramesContentWithDataArray:(NSArray *)dataArray withStartFrame:(int)startIndex withFrameCount:(int)frameCount withEyemoreVideo:(EyemoreVideo *)eyemoreVideo;
- (NSData *)getFrameImageDataWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo withIndex:(long int)index;
- (NSData *)getFrameAudioDataWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo withIndex:(long int)index;
- (void)encodeMovieFromImagesWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo withCallBackBlock:(SuccessBlock)callBackBlock;
- (void)removeVideoWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo;
- (NSString *)getCompleteVideoFilePathWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo;
- (NSURL *)getCompleteVideFileURLWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo;
- (void)generateVideoAudioWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo;
- (UIImage *)getThumbnailImageWithEyemoeVideo:(EyemoreVideo *)eyemoreVideo;
- (void)composeCompleteMovieFileWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo withCallBackBlock:(SuccessBlock)callBackBlock;

@end

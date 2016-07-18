//
//  VideoRecorder.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/13.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPSocketManager.h"
#import "CMDManager.h"
#import "VideoClient.h"
#import "EyemoreVideo.h"

#define kPIN10SECOND 2
@class VideoRecorder;
@protocol VideoRecorderDelegate <NSObject>

@optional

//有空时把代理全改成block异步回调，以下注解的代理方法是已经改好的
//- (void)videoRecorderDidDownloadProcessing:(float)progress;
- (void)videoRecorderDidDownloadDroppedVideoFramesWithEyemoreVideo:(EyemoreVideo *)recordVideo;
//- (void)videoRecorder:(VideoRecorder *)recorder didDownloadVideoFramesWithEyemoreVideo:(EyemoreVideo *)recordVideo;
- (void)videoRecorder:(VideoRecorder *)recorder didGetVideoDesList:(VideoConfig *)config;
- (void)videoRecorder:(VideoRecorder *)recorder didGetDesData:(NSData *)desData;
- (void)videoRecorder:(VideoRecorder *)recorder didGetTimeLapseNum:(int)number;
//- (void)videoRecorder:(VideoRecorder *)recorder didGetFirstFrame:(NSData *)frameData forEyemoreVideo:(EyemoreVideo *)EyemoreVideo;

@end


typedef void (^FinishFirstFrameBlock)(NSData *imageData);
typedef void (^DownloadProcessingBlock)(float progressing);
typedef void (^FinishEyemoreBlock)(EyemoreVideo *video, BOOL isSuccess);
typedef void (^DeleteRecordHandler)(BOOL isDeleted);

@interface VideoRecorder : NSObject <TCPSocketManagerDelegate>
@property (strong, nonatomic) TCPSocketManager        *socketManager;
@property (weak  , nonatomic) id <VideoRecorderDelegate>  delegate;
@property (strong, nonatomic) EyemoreVideo            *sampleVideo;
@property (strong, nonatomic) FinishFirstFrameBlock   firstFrameBlock;
@property (strong, nonatomic) DownloadProcessingBlock downloadProcessBlock;
@property (strong, nonatomic) FinishEyemoreBlock      finishEyemoreBlock;
@property (strong, nonatomic) DeleteRecordHandler     deleteRecordHandler;

+ (VideoRecorder *)sharedVideoRecorder;
- (void)startLDRecording;
- (void)startHDRecording;
- (void)startLDRecordingWithEyemoreVideo:(EyemoreVideo *)dict;
- (void)startHDRecordingWithEyemoreVideo:(EyemoreVideo *)dict;
- (void)startTimeLapseRecording;
- (void)endRecording;
- (void)getRecordDesWithID:(int)desId;
- (void)getRecordDesList;
- (void)deleteRecordWithID:(int)desID completeHandler:(DeleteRecordHandler)handler;

- (void)downloadFirstFrameWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo;
- (void)downloadFirstFrameWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo completeBlock:(FinishFirstFrameBlock)block;
- (void)downloadFramesWithEyemoreVide:(EyemoreVideo *)eyemoreVideo;
- (void)downloadFramesWithEyemoreVide:(EyemoreVideo *)eyemoreVideo Progress:(DownloadProcessingBlock)progressBlock  completion:(FinishEyemoreBlock)videoBlock;
- (void)downloadDroppedFramesWithEyemoreVideo:(EyemoreVideo *)dict fromIndexs:(NSArray *)indexs;

@end

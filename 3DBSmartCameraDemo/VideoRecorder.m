//
//  VideoRecorder.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/13.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import "VideoRecorder.h"
#import "VideoConfig.h"

#define kDownloadLDFrameCount 40
#define kDownloadHDFrameCount 10
#define kHDFramseCount 125

typedef enum _VideoRecorderMode {
    
    VideoRecorderModeIdle= 1,
    
    VideoRecorderModeDownload = 2,
    
    VideoRecorderModeFetchDrop = 3
    
}VideoRecorderMode;

@interface VideoRecorder ()
{
    NSDate *_finishDate;
    NSDate *_startDate;
    float    downloadprogressing;
}

@property (strong, nonatomic) VideoClient           *videoManager;
@property (assign, nonatomic)          NSInteger     startIndex;
@property (assign, nonatomic)          NSInteger     downloadFrameCount;
@property (assign, nonatomic) BOOL                   getFrameTag;
@property (strong, nonatomic)          NSTimer      *playVideoTimer;
@property (assign, nonatomic)          NSInteger     difference;
@property (assign, nonatomic)          NSInteger     lastFrameCount;
@property (assign, nonatomic)          NSInteger     currentFrameCount;

@property (strong, nonatomic)          NSTimer      *timeOutTimer;
@property (strong, nonatomic)          NSDictionary *timeOutInfo;
@property (assign, nonatomic)          NSInteger     receiveFlag;

@property (assign, nonatomic) BOOL                   isDownloadDroppedFrames;
@property (strong, nonatomic)          NSMutableArray *droppedFrameIndexs;

@property (assign, nonatomic) int desID;
@property (strong, nonatomic) VideoConfig      *VideoConfigInCam;
@property (assign, nonatomic) VideoRecorderMode recoderMode;
@property (assign, nonatomic) NSInteger       kDownloadFrameCount;

@end

@implementation VideoRecorder

+ (VideoRecorder *)sharedVideoRecorder
{
    static VideoRecorder *instance = nil;
    if (instance == nil) {
        instance = [[VideoRecorder alloc] init];
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.socketManager = [TCPSocketManager sharedTCPSocketManager];
        self.socketManager.delegate = self;
        self.startIndex = 0;
        self.videoManager = [VideoClient sharedVideoClient];
        //self.sampleVideo = [[NSMutableDictionary alloc] init];
        //self.isDownloadDroppedFrames = NO;
        self.recoderMode = VideoRecorderModeIdle;
    }
    return self;
}

- (void)startLDRecording
{
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDBeginRecordConifg(RESOLUTION_480_270, 250)];
}

- (void)startHDRecording
{
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDBeginRecordConifg(RESOLUTION_960_540, 250)];
}

- (void)startTimeLapseRecording
{
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDTimeLapseRecordConifg(RESOLUTION_1920_1080, kPIN10SECOND, 0, 700)];
}

- (void)startLDRecordingWithEyemoreVideo:(EyemoreVideo *)dict
{
    self.sampleVideo = dict;
    [self startLDRecording];
}

- (void)startHDRecordingWithEyemoreVideo:(EyemoreVideo *)dict
{
    self.sampleVideo = dict;
    [self startHDRecording];
}

- (void)endRecording
{
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDEndingRecord];
}

- (void)getRecordDesWithID:(int)desId
{
    self.desID = desId;
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetRecordDESWithID(desId)];
    downloadprogressing = 0.0;
}

- (void)getRecordDesList
{
    self.desID = -1;
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetRecordDESWithID(-1)];
}

- (void)checkRecordDes
{
    [self getRecordDesWithID:self.desID];
}

- (void)deleteRecordWithID:(int)desID completeHandler:(DeleteRecordHandler)handler
{
    self.deleteRecordHandler = handler;
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDDeleteVideoWithID(desID)];
}
- (void)downloadFirstFrameWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo
{
    self.sampleVideo = eyemoreVideo;
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFirstFrameWithID((int)self.sampleVideo.uid)];
}

- (void)downloadFramesWithEyemoreVide:(EyemoreVideo *)eyemoreVideo
{
    self.recoderMode = VideoRecorderModeDownload;
    self.sampleVideo = eyemoreVideo;
    NSLog(@"Download frames with video : %@", self.sampleVideo);
    
    //self.currentFrameCount  = self.sampleVideo.frameCount;
    self.difference         = self.sampleVideo.frameCount - self.lastFrameCount;
    self.startIndex         = self.lastFrameCount;
    
    if (self.difference >= self.kDownloadFrameCount) {
        self.downloadFrameCount = self.kDownloadFrameCount;
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFrameWithIDWithStartIndexWithAmount((int)self.sampleVideo.uid, (int)self.startIndex, (int)self.downloadFrameCount)];
    }
    if (self.difference < self.kDownloadFrameCount) {
        self.downloadFrameCount = self.difference;
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFrameWithIDWithStartIndexWithAmount((int)self.sampleVideo.uid, (int)self.startIndex, (int)self.difference)];
    }
    if (self.sampleVideo.frameCount == self.lastFrameCount) {
            
        //[self.delegate videoRecorder:self didDownloadVideoFramesWithEyemoreVideo:self.sampleVideo];
        if (self.finishEyemoreBlock) {
            self.finishEyemoreBlock(self.sampleVideo, YES);
        }
        self.startIndex = 0;
        self.lastFrameCount = 0;
        self.recoderMode = VideoRecorderModeIdle;
    }
}

- (void)downloadFramesWithEyemoreVide:(EyemoreVideo *)eyemoreVideo Progress:(DownloadProcessingBlock)progressBlock  completion:(FinishEyemoreBlock)videoBlock
{
    self.finishEyemoreBlock = videoBlock;
    self.downloadProcessBlock = progressBlock;
    downloadprogressing = 0.0;
    if (eyemoreVideo.resolution.height == 540.0f || eyemoreVideo.resolution.height == 1080.0f) {
        self.kDownloadFrameCount = kDownloadHDFrameCount;
    }
    else self.kDownloadFrameCount = kDownloadLDFrameCount;
    [self downloadFramesWithEyemoreVide:eyemoreVideo];
}

- (void)downloadFirstFrameWithEyemoreVideo:(EyemoreVideo *)eyemoreVideo completeBlock:(FinishFirstFrameBlock)block
{
    [self downloadFirstFrameWithEyemoreVideo:eyemoreVideo];
    self.firstFrameBlock = block;
}

- (void)downloadDroppedFramesWithEyemoreVideo:(EyemoreVideo *)dict fromIndexs:(NSArray *)indexs
{
    //self.isDownloadDroppedFrames = YES;
    self.recoderMode = VideoRecorderModeFetchDrop;
    self.sampleVideo = dict;
    self.droppedFrameIndexs = [indexs mutableCopy];
    long int firstIndex = [indexs[0] intValue];
    NSLog(@"try to get frame of index %ld",firstIndex);
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetLiveFrameWithIndex((int)firstIndex)];
    
}
#pragma mark - TCP socket manager delegate

- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command
{
    [self.socketManager receiveMessageWithTimeOut:-1];
}

- (void)didFinishConnectToHost {
    
    if (self.timeOutInfo) {
        if ([(NSString *)[self.timeOutInfo objectForKey:@"CMD"] isEqualToString:@"CMDGetFrameWithIDWithStartIndexWithAmount"]) {
            int startIndex = [[self.timeOutInfo objectForKey:@"Index"] intValue];
            int amout      = [[self.timeOutInfo objectForKey:@"Amout"] intValue];
            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFrameWithIDWithStartIndexWithAmount(0, startIndex, amout)];
            [self executeTimeOutCounterWithCMD:@"CMDGetFrameWithIDWithStartIndexWithAmount" withIndex:startIndex Amout:amout];
        }
        //self.timeOutInfo = nil;
    }
    else {
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            //[ProgressHUD showSuccess:@"连接成功" Interaction:NO];
        });
    }
}

- (void)didSendData
{}
- (void)didReceiveACKWithState:(CTL_MESSAGE_PACKET)ACK
{
    if (ACK.cmd == SDB_BEGIN_RECORD_ACK) {
//        dispatch_async(dispatch_get_main_queue(), ^(){
//            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(getRecordDes) userInfo:nil repeats:NO];
//        });
    }
    if (ACK.cmd == SDB_SET_RECV_OK_ACK && ACK.param0 == 2) {
        if (self.receiveFlag == 0) {
        }
        if (self.receiveFlag == 1) {
            if (self.recoderMode == VideoRecorderModeFetchDrop) {
                
                if (self.droppedFrameIndexs.count != 0) {
                    NSLog(@"try to get frame index : %d", [self.droppedFrameIndexs[0] intValue]);
                    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetLiveFrameWithIndex([self.droppedFrameIndexs[0] intValue])];
                }
                else {
                    //self.isDownloadDroppedFrames = NO;
                    self.recoderMode = VideoRecorderModeIdle;
                    [self.delegate videoRecorderDidDownloadDroppedVideoFramesWithEyemoreVideo:self.sampleVideo];
                }
            }
            else if (self.recoderMode == VideoRecorderModeDownload) {
                [self downloadFramesWithEyemoreVide:self.sampleVideo];
            }
            //else [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetRecordDESWithID(self.desID)];
        }
    }
    
    if (ACK.cmd == SDB_GET_LIVE_FRAME_ACK) {
        //如果返回4状态，则丢掉当前帧，继续下一张
        if (ACK.state == 4) {
            if (self.droppedFrameIndexs.count != 0) {
                NSLog(@"try to get frame index : %d", [self.droppedFrameIndexs[0] intValue]);
                [self.droppedFrameIndexs removeObjectAtIndex:0];
                [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDReceiveOInMode(2)];
            }

        }
    }
    if (ACK.cmd == SDB_DELETE_VIDEO_ACK) {
        if (ACK.state == SDB_STATE_SUCCESS) {
            if (self.deleteRecordHandler) {
                self.deleteRecordHandler(YES);
            }
            else self.deleteRecordHandler(NO);
        }
    }
    if (ACK.cmd == SDB_GET_FRAME_ACK && ACK.state != SDB_STATE_SUCCESS) {
        if (self.recoderMode == VideoRecorderModeDownload) {
            if (self.finishEyemoreBlock) {
                self.finishEyemoreBlock(self.sampleVideo, NO);
            }
        }
    }
    if (ACK.cmd == SDB_CURRENT_RECORD_NUM_ACK) {
        if (ACK.state == SDB_STATE_SUCCESS) {
            
            if ([self.delegate respondsToSelector:@selector(videoRecorder:didGetTimeLapseNum:)]) {
                [self.delegate videoRecorder:self didGetTimeLapseNum:ACK.paramn[0]];
            }
        }
        else if (ACK.state == SDB_SERVER_NOT_READY){
            if ([self.delegate respondsToSelector:@selector(videoRecorder:didGetTimeLapseNum:)]) {
                [self.delegate videoRecorder:self didGetTimeLapseNum:-1];
            }
        }
    }
}

- (void)didDisconnectSocket
{}
- (void)didReceiveLensStatus:(LENS_PARAMS)lensStatus
{}
- (void)didSetIRISWithStatus:(SDB_STATE)state
{}
- (void)didReceiveDebugInfo:(DEBUG_INFO)info
{}
- (void)didLoseAlive
{}
- (void)didReceiveDevInfo:(DEV_INFO)decInfo
{}

- (void)didFinishDownloadRecordingData:(NSData *)recordData withCMD:(CTL_MESSAGE_PACKET)CMD
{
    //finishdate赋值，未超时
    _finishDate = self.socketManager.connectTimer.fireDate;
    
    //获取指定视频描述文件信息
    if (CMD.cmd == SDB_GET_RECORD_DES_ACK && self.desID != -1) {
        
        self.receiveFlag = 0;
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDReceiveOInMode(2)];
        [self.delegate videoRecorder:self didGetDesData:recordData];
        //self.sampleVideo = [self.videoManager setEyemoreVideonfoWithHeadData:recordData];
//        NSLog(@"sample video : %@", self.sampleVideo);
//        
//        self.currentFrameCount  = self.sampleVideo.frameCount;
//        self.difference         = self.currentFrameCount - self.lastFrameCount;
//        self.startIndex         = self.lastFrameCount;
//        
//        if (self.currentFrameCount > self.lastFrameCount && self.difference >= kDownloadFrameCount) {
//            self.downloadFrameCount = kDownloadFrameCount;
//            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFrameWithIDWithStartIndexWithAmount(self.desID, (int)self.startIndex, (int)self.downloadFrameCount)];
//        }
//        if (self.currentFrameCount > self.lastFrameCount && self.difference < kDownloadFrameCount) {
//            self.downloadFrameCount = self.difference;
//            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFrameWithIDWithStartIndexWithAmount(self.desID, (int)self.startIndex, (int)self.difference)];
//        }
//        if (self.currentFrameCount == self.lastFrameCount) {
//            static int i = 0;
//            if (i == 0) {
//                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(checkRecordDes) userInfo:nil repeats:NO];
//                i ++;
//            }
//            if (i == 1) {
//                
//                [self.delegate videoRecorderDidDownloadVideoFramesWithEyemoreVideo:self.sampleVideo];
//                i = 0;
//                self.startIndex = 0;
//                self.lastFrameCount = 0;
//            }
//        }
    }
    else if (CMD.cmd == SDB_GET_RECORD_DES_ACK && self.desID == -1) {
        
        [self decodeRecordDesListData:recordData];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDReceiveOInMode(2)];
    }
    
    if (CMD.cmd == SDB_GET_FIRST_FRAME_ACK) {
        //[self.delegate videoRecorder:self didGetFirstFrame:recordData forEyemoreVideo:self.sampleVideo];
        NSArray *firstFrameArray = [NSArray new];
        firstFrameArray = [self.videoManager decodeFrameData:recordData withStartFrame:0 withFrameCount:1];
        
        if (self.firstFrameBlock) {
            self.firstFrameBlock(firstFrameArray[1]);
        }
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDReceiveOInMode(2)];
        [self.socketManager receiveMessageWithTimeOut:-1];
    }
    if (CMD.cmd == SDB_GET_FRAME_ACK) {
        
        NSArray *array = [[NSArray alloc] init];
        //实际获取的张数
        self.downloadFrameCount = CMD.paramn[1];
        [self setDownloadProcessing];
        if (self.downloadFrameCount >= self.kDownloadFrameCount ) {
            array = [self.videoManager decodeFrameData:recordData
                                        withStartFrame:(int)self.startIndex
                                        withFrameCount:(int)self.downloadFrameCount];
        }
        else
        {
            array = [self.videoManager decodeFrameData:recordData
                                        withStartFrame:(int)self.startIndex
                                        withFrameCount:(int)self.downloadFrameCount];
        }
        
        [self.videoManager recordMultiFramesContentWithDataArray:array
                                                  withStartFrame:(int)self.startIndex
                                                  withFrameCount:(int)self.downloadFrameCount withEyemoreVideo:self.sampleVideo];
        self.lastFrameCount = self.lastFrameCount + self.downloadFrameCount;
        self.receiveFlag = 1;
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDReceiveOInMode(2)];
    }
    
    //实时取景指定帧数据
    if (CMD.cmd == SDB_GET_LIVE_FRAME_ACK) {
        self.receiveFlag = 1;
        NSArray *array = [[NSArray alloc] init];
        array = [self.videoManager decodeFrameData:recordData withStartFrame:0 withFrameCount:1];
        [self.videoManager recordFrameContentWithFrameImage:array[1]
                                             withFrameAudio:array[2]
                                             withFrameIndex:array[0]
                                                  withIndex:0
                                              withEyemoreVideo:self.sampleVideo];
        
        [self.droppedFrameIndexs removeObjectAtIndex:0];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDReceiveOInMode(2)];
    }
}

- (void)decodeRecordDesListData:(NSData *)desListData
{
    NSString *desListString = [[NSString alloc] initWithData:desListData encoding:NSUTF8StringEncoding];
    NSArray *desList = [desListString componentsSeparatedByString:@"\n"];
    NSLog(@"des list string: %@", desListString);
    NSLog(@"des list array: %@", desList);
    self.VideoConfigInCam = [[VideoConfig alloc] init];
    for (int i = 0 ; i < desList.count - 1; i++) {
        [self.VideoConfigInCam addEyemoreVideos:[self.videoManager setEyemoreVideonfoWithString:desList[i]]];
    }
    [self.delegate videoRecorder:self didGetVideoDesList:self.VideoConfigInCam];
}

- (void)setDownloadProcessing
{
    downloadprogressing += (float)self.kDownloadFrameCount / (float)self.sampleVideo.frameCount;
    if (self.downloadProcessBlock) {
        self.downloadProcessBlock(downloadprogressing);
    }
    //[self.delegate videoRecorderDidDownloadProcessing:downloadprogressing];
}
- (void)executeTimeOutCounterWithCMD:(NSString *)cmd withIndex:(int)index Amout:(int)amout
{
    
    //清空超时信息
    _startDate = self.socketManager.connectTimer.fireDate;
    _finishDate = nil;
    self.timeOutInfo = nil;
    //超时计时开始
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timeOutTimer setFireDate:[NSDate distantFuture]];
        [self.timeOutTimer invalidate];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:cmd forKey:@"CMD"];
        [dict setObject:[NSString stringWithFormat:@"%d",amout] forKey:@"Amout"];
        [dict setObject:[NSString stringWithFormat:@"%d",index] forKey:@"Index"];
        
        self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                             target:self
                                                           selector:@selector(timeOutHandle:)
                                                           userInfo:[dict copy]
                                                            repeats:NO];
        NSLog(@"time out info : %@", dict);
    });
}

- (void)timeOutHandle:(NSTimer *)timer
{
    if (!_finishDate) {
        NSLog(@"......time out");
        if (!self.socketManager.isLost) {
            [self.socketManager tcpLingSocketConnectToHost];
            self.timeOutInfo = (NSDictionary *)[timer userInfo];
        }
        else {
            //[ProgressHUD showError:@"同步超时" Interaction:NO];
            [self.timeOutTimer invalidate];
        }
    }
}

@end

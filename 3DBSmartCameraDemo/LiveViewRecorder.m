//
//  LiveViewRecorder.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/24.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import "LiveViewRecorder.h"
#import "net_interface_params.h"
#import "TimeoutManager.h"
#import "VideoClient.h"
#define kHost                           @"192.168.1.134"
#define kwriteStartMessageTag 1
#define kreadMessageTag  2
#define kreadFrameDataTag 3
#define kwriteStopMessageTag 4

@interface LiveViewRecorder()<GCDAsyncSocketDelegate, TimeOutManagerDelegate>
//@property (strong, nonatomic)            TimeoutManager    *timaoutManager;
@property (assign, nonatomic) BOOL                       didGetFrame;
@property (strong, nonatomic)       NSTimer             *getFrameTimer;
@property (assign, nonatomic) BOOL                       stopFlag;
@property (strong, nonatomic)       VideoClient         *videoManager;
@property (strong, nonatomic)       NSArray             *frameDataArray;
@property (assign, nonatomic)       LIVEVIEWOFFLINETYPE  offLineType;
@property (strong, nonatomic)        NSTimer            *connectLiveViewTimer;
@property (assign, nonatomic)       BOOL                 isDownloadingDroppedFrames;

@end

@implementation LiveViewRecorder

+ (LiveViewRecorder *)sharedLiveViewRecorder
{
    static LiveViewRecorder *instance = nil;
    if (instance == nil) {
        instance = [[LiveViewRecorder alloc] init];
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.videoManager = [[VideoClient alloc] init];
        self.frameDataArray = [[NSArray alloc] init];
    }
    return self;
}

- (void)tcpLiveViewSocketConnectToHost{
    
    self.liveViewSocket = [self sharedLiveViewSocket];
    
    NSError *error3 = nil;
    
    [self.liveViewSocket disconnect];
    
    [self.liveViewSocket connectToHost:kHost onPort:SERVER_LIVEVIEW_PORT withTimeout:3 error:&error3];
    
    self.liveViewSocket.userData = LiveSocketOfflineByServer;
    
}

- (GCDAsyncSocket *)sharedLiveViewSocket
{
    static GCDAsyncSocket *instance = nil;
    if (instance == nil) {
        dispatch_queue_t lQueue = dispatch_queue_create("live view tcp data socket", NULL);
        
        instance = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:lQueue];
    }
    return instance;
}

- (void)sendStartLiveViewMessage
{
    NSLog(@"start 0");
    char CMDstring[] = "start 0";
    NSData   *cmdData= [[NSData alloc] initWithBytes:&CMDstring length:sizeof(CMDstring)];
    [self.liveViewSocket writeData:cmdData withTimeout:-1 tag:kwriteStartMessageTag];
}

- (void)sendStartLiveRecordingMessage
{
    NSLog(@"start 1");
    char CMDstring[] = "start 1";
    NSData   *cmdData= [[NSData alloc] initWithBytes:&CMDstring length:sizeof(CMDstring)];
    [self.liveViewSocket writeData:cmdData withTimeout:-1 tag:kwriteStartMessageTag];
}

- (void)sendStopLiveViewMessage
{
    char CMDstring[] = "End";
    NSData   *cmdData= [[NSData alloc] initWithBytes:&CMDstring length:sizeof(CMDstring)];
    [self.liveViewSocket writeData:cmdData withTimeout:-1 tag:kwriteStopMessageTag];
}

- (void)receiveOneFrameInfoWithTimeOut:(NSUInteger)timeOut
{
    [self.liveViewSocket readDataToLength:4 withTimeout:timeOut tag:kreadMessageTag];
}

- (void)receiveOneFrameDataWithLength:(int)length
{
    
    [self.liveViewSocket readDataToLength:length withTimeout:1.0 tag:kreadFrameDataTag];
}

- (void)getFrame
{
    if (self.didGetFrame) {
        //[self.timaoutManager executeTimeOutCounterWithCMD:nil withAmout:0 withTimeOut:1.0 repeat:YES];
        [self receiveOneFrameInfoWithTimeOut:2];
        self.didGetFrame = NO;
    }
}

//- (void)downloadDroppedFramesWithIndexs:(NSString *)indexs
//{
//    self.isDownloadingDroppedFrames = YES;
//    [self sendStopLiveViewMessage];
//}

- (void)startLiveViewing
{
    self.stopFlag = NO;
    self.offLineType = LiveSocketOfflineByServer;
    
    [self tcpLiveViewSocketConnectToHost];
}

- (void)stopLiveViewing
{
    [self cleanInstance];
    self.stopFlag = YES;
    self.offLineType = LiveSocketOfflineByUser;
    
    [self sendStopLiveViewMessage];
}

- (void)setViewingMode:(VIEWING_MODE)mode
{
    self.mode = mode;
    if (self.isConnected) {
        
        if (mode == LIVE_VIEWING_MODE) {
            //[self cleanInstance];
            [self sendStartLiveViewMessage];
        }
        if (mode == LIVE_RECORDING_MODE) {
            //[self cleanInstance];
            //[self sendStartLiveRecordingMessage]; desperated in 2015 0421
            [self sendStartLiveViewMessage];
        }
    }
}

- (void)cleanInstance
{
    [self.getFrameTimer setFireDate:[NSDate distantFuture]];
    [self.getFrameTimer invalidate];
    //[self.timaoutManager stopTimeOutExecution];
}

- (void)autoRestartLiveViewing
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.connectLiveViewTimer setFireDate:[NSDate distantFuture]];
        [self.connectLiveViewTimer invalidate];
        self.connectLiveViewTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(reconnectingLiveView) userInfo:nil repeats:YES];
    });
}

- (void)reconnectingLiveView
{
    if (!self.isConnected) {
        [self tcpLiveViewSocketConnectToHost];
    }
}
#pragma mark - GCDAsynSocket Delegate
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //获取服务器返回信令ack
    
    if (tag == kwriteStartMessageTag)   {
        NSLog(@"did write start message to host");
            dispatch_async(dispatch_get_main_queue(), ^(){
            self.getFrameTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(getFrame) userInfo:nil repeats:YES];
        });
    }
    if (tag == kwriteStopMessageTag) {
        if (self.stopFlag) {
            [self.liveViewSocket disconnect];
        }
//        else {
//            if (self.isDownloadingDroppedFrames) {
//                
//            }
//        }
    }
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if (sock == self.liveViewSocket) {
        
        //[data getBytes:&receiveACK length:sizeof(receiveACK)];
        
        
        if (tag == kreadMessageTag) {
            
            CTL_MESSAGE_PACKET receiveACK;

            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([string isEqualToString:@"endl"]) {
                
                //成功读取endl后，相机主动断开liveview，标记offlinetype
                self.offLineType = LiveSocketOfflineByCam;
                [self.liveViewSocket disconnect];
                NSLog(@"receiving endl message");
            }
            else {
                
                int frameDataLength;
                [data getBytes:&frameDataLength length:sizeof(frameDataLength)];
//                const char* pos = [data bytes];
//                signed int a;
//                memcpy(&a, pos, sizeof(int));
                receiveACK.paramn[0] = frameDataLength;
//                if (a == 0x656e646c) {
//                    
//                }
                if (receiveACK.paramn[0] != 0) {
                    NSLog(@"one frame data length : %d", receiveACK.paramn[0]);
                    [self receiveOneFrameDataWithLength:receiveACK.paramn[0]];
                }
                else
                {
                    [self receiveOneFrameInfoWithTimeOut:-1];
                }
            }
        }
        if (tag == kreadFrameDataTag) {
            NSLog(@"One frame data downloaded with length : %lu", (unsigned long)[data length]);
            //[self.timaoutManager setFinishTransfering];
            self.didGetFrame = YES;
            
            //NSArray *array = [[NSArray alloc] init];
            
            self.frameDataArray = [self.videoManager decodeFrameData:data
                                            withStartFrame:(int)0
                                            withFrameCount:(int)1];

            //NSLog(@"self.frameDataArray[0]: %@", self.frameDataArray[0]);
            //[self.delegate didGetLiveViewData:self.frameDataArray[0]];
            [self.delegate didGetLiveViewData:self.frameDataArray];
            data = nil;
        }
    }

}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"live view socket did connect to host");
    self.isConnected = YES;
    [self.connectLiveViewTimer setFireDate:[NSDate distantFuture]];
    [self.connectLiveViewTimer invalidate];
    
    if (sock == self.liveViewSocket && self.stopFlag == NO) {
        
        if (self.mode == LIVE_VIEWING_MODE) {
            [self sendStartLiveViewMessage];
        }
        if (self.mode == LIVE_RECORDING_MODE) {
            //[self sendStartLiveRecordingMessage];
            [self sendStartLiveViewMessage];
        }
        
        self.didGetFrame = YES;
        //self.timaoutManager.isTimingOut = NO;
    }
    
    if (sock == self.liveViewSocket && self.stopFlag == YES) {
        [self.getFrameTimer setFireDate:[NSDate distantFuture]];
        [self.getFrameTimer invalidate];
        [self.liveViewSocket disconnect];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"live view socket did disconnect");
    self.isConnected = NO;
    [self cleanInstance];
    [self.delegate didLoseLiveViewDataWithType:self.offLineType];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    if (sock == self.liveViewSocket && tag == kreadMessageTag) {
        NSLog(@"live view socket read message times out, reconnect immediately! ");
        [self cleanInstance];
        [self tcpLiveViewSocketConnectToHost];
    }
    return 0;
}

//#pragma mark - Time Out Manager Delegate
//
//- (void)didTimeoutWithInfo:(id)userInfo
//{
//    //self.timaoutManager.isTimingOut = YES;
//    NSLog(@"live view socket data getting time out, reconnect immediately! ");//with istimingout : %@", self.timaoutManager.isTimingOut ? @"yes" : @"no");
//
//    [self cleanInstance];
//    [self tcpLiveViewSocketConnectToHost];
//    
//
//}

@end

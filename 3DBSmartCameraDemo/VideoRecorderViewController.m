//
//  VideoRecorderViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/13.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import "VideoRecorderViewController.h"
#import "TCPSocketManager.h"
#import "VideoClient.h"
#import "CMDManager.h"
#import "ProgressHUD.h"
#import "VideoRecorder.h"
#import "playImageViewController.h"
#import "SaveLoadInfoManager.h"
//#import "MovieEncoder.h"

@interface VideoRecorderViewController ()<VideoRecorderDelegate>

{
    NSData *_imageData;
    NSDate *_finishDate;
    NSDate *_startDate;
}

//@property (strong, nonatomic) TCPSocketManager      *socketManager;
@property (strong, nonatomic) VideoClient           *videoManager;
@property (strong, nonatomic) NSMutableDictionary   *sampleVideo;
@property (strong, nonatomic) VideoRecorder         *videoRecorder;

@property (weak,   nonatomic) IBOutlet UIImageView  *sampleImage;
@property (weak,   nonatomic) IBOutlet UIButton     *StartButton;
@property (weak,   nonatomic) IBOutlet UIButton     *StopButton;
//
//@property (assign, nonatomic)          NSInteger     startIndex;
//@property (assign, nonatomic)          NSInteger     downloadFrameCount;
//@property (assign, nonatomic) BOOL                   getFrameTag;
//@property (strong, nonatomic)          NSTimer      *playVideoTimer;
//@property (assign, nonatomic)          NSInteger     difference;

@property (strong, nonatomic)          NSTimer      *playVideoTimer;
@property (strong, nonatomic)          NSTimer      *timeOutTimer;
@property (strong, nonatomic)          NSDictionary *timeOutInfo;

@end

@implementation VideoRecorderViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.socketManager.delegate = self;
    self.videoRecorder.delegate = self;
    self.videoRecorder.socketManager.delegate = self.videoRecorder;
    //self.sampleImage.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    self.videoRecorder = [VideoRecorder sharedVideoRecorder];
    self.sampleVideo = [[NSMutableDictionary alloc] init];
    self.videoManager= [VideoClient sharedVideoClient];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playVideo
{
    NSLog(@"sample image view tapped");
    self.playVideoTimer = [NSTimer scheduledTimerWithTimeInterval:0.04f target:self selector:@selector(showFrame) userInfo:nil repeats:YES];
}

- (void)showFrame
{
//    static int i = 0;
//    [self.sampleImage setImage:[UIImage imageWithData:[self.videoManager getFrameImageDataWithVideoDict:self.sampleVideo withIndex:(int)i]]];
//    i++;
//    if (i == [[self.sampleVideo objectForKey:@"Framecount"] intValue]) {
//        [self.playVideoTimer invalidate];
//        i = 0;
//        [ProgressHUD showSuccess:@"播放完毕"];
//    }
}

#pragma mark - Button Actions

- (IBAction)startButtonTapped:(id)sender {
    
    [self.videoRecorder startLDRecording];
    
}

- (IBAction)stopButtonTapped:(id)sender {
    
    [self.videoRecorder endRecording];
    
}
- (IBAction)getFramesButtonTapped:(id)sender {
    [self.videoRecorder getRecordDesWithID:0];
}

- (IBAction)playButtonTapped:(id)sender {
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(playVideo) userInfo:nil repeats:NO];
}

- (IBAction)fullScreenButtonTapped:(id)sender {
    
    playImageViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"playImageViewController"];
    controller.videoDict = self.sampleVideo;
    [self presentViewController:controller animated:YES completion:nil];
}
#pragma mark - Video Recorder Delegate

- (void)videoRecorderDidDownloadVideoFramesWithVideoDict:(NSMutableDictionary *)recordVideo
{
    self.sampleVideo = recordVideo;
    [self.videoRecorder endRecording];
}

//#pragma mark - TCP socket manager delegate
//
//- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command
//{
//    [self.socketManager receiveMessageWithTimeOut:-1];
//}
//- (void)didSendData
//{
//}
//- (void)didReceiveACKWithState:(CTL_MESSAGE_PACKET)ACK
//{
//}
//
//- (void)didFinishConnectToHost {
//    
//    if (self.timeOutInfo) {
//        if ([(NSString *)[self.timeOutInfo objectForKey:@"CMD"] isEqualToString:@"CMDGetFrameWithIDWithStartIndexWithAmount"]) {
//            int startIndex = [[self.timeOutInfo objectForKey:@"Index"] intValue];
//            int amout      = [[self.timeOutInfo objectForKey:@"Amout"] intValue];
//            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFrameWithIDWithStartIndexWithAmount(0, startIndex, amout)];
//            [self executeTimeOutCounterWithCMD:@"CMDGetFrameWithIDWithStartIndexWithAmount" withIndex:startIndex Amout:amout];
//        }
//        //self.timeOutInfo = nil;
//    }
//    else {
//        
//        dispatch_async(dispatch_get_main_queue(), ^(){
//            //[ProgressHUD showSuccess:@"连接成功" Interaction:NO];
//        });
//    }
//}
//
//- (void)didDisconnectSocket
//{}
//
//- (void)didReceiveLensStatus:(LENS_PARAMS)lensStatus
//{}
//
//- (void)didSetIRISWithStatus:(SDB_STATE)state
//{}
//
//- (void)didReceiveDebugInfo:(DEBUG_INFO)info
//{
//}
//
//- (void)didLoseAlive
//{}
//
//- (void)didReceiveDevInfo:(DEV_INFO)decInfo
//{}
//
//- (void)didFinishDownloadRecordingData:(NSData *)recordData withCMD:(SDB_COMM_SIG_TYPE)CMD
//{
//    if (CMD == SDB_GET_RECORD_DES) {
//        [self.videoManager setVideoHeadInfoWithHeadData:recordData withVideoDict:self.sampleVideo];
//        NSLog(@"sample video : %@", self.sampleVideo);
//        static int lastFrameCount = 0;
//        int currentFrameCount = [[self.sampleVideo objectForKey:@"Framecount"] intValue];
//        
//        if (lastFrameCount == 0 && currentFrameCount != 0) {
//            self.socketManager 
//        }
//    }
//    
//    //finishdate赋值，未超时
//    _finishDate = self.socketManager.connectTimer.fireDate;
//    
//    if (CMD == SDB_GET_FIRST_FRAME) {
//        NSArray *array = [self.videoManager decodeFrameData:recordData withStartFrame:0 withFrameCount:1];
//        //        [self.videoManager storeVideoFrameWithData:array[0] WithPath:@"frame01"];
//        
//        [self.videoManager recordFrameContentWithFrameImage:array[0] withFrameAudio:array[1] withIndex:0 withVideoDict:self.sampleVideo];
//        dispatch_async(dispatch_get_main_queue(), ^(){
//            [self.sampleImage setImage:[UIImage imageWithData:[self.videoManager getFrameImageDataWithVideoDict:self.sampleVideo withIndex:0]]];
//        });
//    }
//    if (CMD == SDB_GET_FRAME) {
//        
//        NSArray *array = [[NSArray alloc] init];
//        if ([[self.sampleVideo objectForKey:@"Framecount"] intValue] - self.startIndex >= self.downloadFrameCount) {
//            
//            array = [self.videoManager decodeFrameData:recordData
//                                        withStartFrame:(int)self.startIndex
//                                        withFrameCount:(int)self.downloadFrameCount];
//        }
//        else
//        {
//            array = [self.videoManager decodeFrameData:recordData
//                                          withStartFrame:(int)self.startIndex
//                                          withFrameCount:(int)([[self.sampleVideo objectForKey:@"Framecount"] intValue] - self.startIndex)];
//        }
//        [self.videoManager recordMultiFramesContentWithDataArray:array
//                                                    withStartFrame:(int)self.startIndex
//                                                    withFrameCount:(int)self.downloadFrameCount withVideoDict:self.sampleVideo];
//        
//        self.startIndex      = self.startIndex + self.downloadFrameCount;
//        NSInteger difference = [[self.sampleVideo objectForKey:@"Framecount"] intValue] - self.startIndex;
//        
//        if (difference > self.downloadFrameCount || difference == self.downloadFrameCount)
//        {
//            
//            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFrameWithIDWithStartIndexWithAmount(0,
//                                                                                                                 (int)self.startIndex,
//                                                                                                                 (int)self.downloadFrameCount)];
//            [self executeTimeOutCounterWithCMD:@"CMDGetFrameWithIDWithStartIndexWithAmount"
//                                     withIndex:(int)self.startIndex
//                                         Amout:(int)self.downloadFrameCount];
//        }
//        else if (difference < self.downloadFrameCount && 0 < difference)
//        {
//            
//            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFrameWithIDWithStartIndexWithAmount(0,
//                                                                                                                 (int)self.startIndex,
//                                                                                                                 (int)difference)];
//            
//            NSLog(@"difference is :%ld", (long)difference);
//            dispatch_async(dispatch_get_main_queue(), ^(){
//                
//                //下载完成后，清空超时信息
//                self.timeOutInfo = nil;
//                [self.timeOutTimer setFireDate:[NSDate distantFuture]];
//                [self.timeOutTimer invalidate];
//                
//                [ProgressHUD showSuccess:@"已下载完0号视频"];
//                //[NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(playVideo) userInfo:nil repeats:NO];
//            });
//        }
//        if (difference == 0) {
//            
//        }
//    }
//}
//
//- (void)executeTimeOutCounterWithCMD:(NSString *)cmd withIndex:(int)index Amout:(int)amout
//{
//    
//    //清空超时信息
//    _startDate = self.socketManager.connectTimer.fireDate;
//    _finishDate = nil;
//    self.timeOutInfo = nil;
//    //超时计时开始
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.timeOutTimer setFireDate:[NSDate distantFuture]];
//        [self.timeOutTimer invalidate];
//        
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//        [dict setObject:cmd forKey:@"CMD"];
//        [dict setObject:[NSString stringWithFormat:@"%d",amout] forKey:@"Amout"];
//        [dict setObject:[NSString stringWithFormat:@"%d",index] forKey:@"Index"];
//        
//        self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
//                                                             target:self
//                                                           selector:@selector(timeOutHandle:)
//                                                           userInfo:[dict copy]
//                                                            repeats:NO];
//        NSLog(@"time out info : %@", dict);
//    });
//}
//
//- (void)timeOutHandle:(NSTimer *)timer
//{
//    if (!_finishDate) {
//        NSLog(@"......time out");
//        if (!self.socketManager.isLost) {
//            [self.socketManager tcpLingSocketConnectToHost];
//            self.timeOutInfo = (NSDictionary *)[timer userInfo];
//        }
//        else {
//            [ProgressHUD showError:@"同步超时" Interaction:NO];
//            [self.timeOutTimer invalidate];
//        }
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  ApiTestViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/4.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import "ApiTestViewController.h"
#import "TCPSocketManager.h"
#import "CMDManager.h"
#import "VideoClient.h"
#import "ProgressHUD.h"
#import "WIFIDetector.h"

@interface ApiTestViewController ()<TCPSocketManagerDelegate, UIGestureRecognizerDelegate>
{
    NSData *_imageData;
    NSDate *_finishDate;
    NSDate *_startDate;
}
@property (strong, nonatomic) TCPSocketManager    *socketManager;
@property (strong, nonatomic) VideoClient         *videoManager;
@property (strong, nonatomic) NSMutableDictionary *sampleVideo;
@property (weak, nonatomic) IBOutlet UIImageView  *sampleImage;
@property (assign, nonatomic) NSInteger            startIndex;
@property (assign, nonatomic) NSInteger            downloadFrameCount;
@property (assign, nonatomic) BOOL                 getFrameTag;
@property (strong, nonatomic) NSTimer             *playVideoTimer;
@property (assign, nonatomic) NSInteger            difference;

@property (strong, nonatomic)          NSTimer             *timeOutTimer;
@property (strong, nonatomic)          NSDictionary        *timeOutInfo;

@end

@implementation ApiTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    self.socketManager.delegate = self;
    self.videoManager = [VideoClient sharedVideoClient];
    [self.sampleImage setImage:[UIImage imageNamed:@"62-trash"]];
    self.sampleVideo = [[NSMutableDictionary alloc] init];
    self.sampleImage.contentMode = UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playVideo)];
    singleTap.numberOfTapsRequired = 1;
    [self.sampleImage addGestureRecognizer:singleTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)getRecordButtonTapped:(id)sender {

    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDBeginRecordConifg(0, 250)];
}
- (IBAction)endRecordButtonTapped:(id)sender {
    
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDEndingRecord];
    //[self.socketManager tcpLingSocketConnectToHost];
}
- (IBAction)getRecordNumButtonTapped:(id)sender {
    
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetRecordNum];
}
- (IBAction)getRecordDesButtonTapped:(id)sender {
    
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetRecordDESWithID(0)];
    NSLog(@"size of video info :%lu", sizeof(videoInfo));
}
- (IBAction)getFileHeadButtonTapped:(id)sender {
    
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetVideoHeadWithID(0)];
}
- (IBAction)getFirstFrameButtonTapped:(id)sender {
    
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFirstFrameWithID(0)];
}
- (IBAction)getFrameButtonTapeed:(id)sender {
    
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFrameWithIDWithStartIndexWithAmount(0, 0, 4)];
    self.startIndex = 0;
    self.downloadFrameCount = 4;
}
- (IBAction)getDeleteButtonTapped:(id)sender {
    
}
- (IBAction)assembleButtonTapped:(id)sender {
    
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(playVideo) userInfo:nil repeats:NO];
}

- (void)playVideo
{
    NSLog(@"sample image view tapped");
    self.playVideoTimer = [NSTimer scheduledTimerWithTimeInterval:0.04f target:self selector:@selector(showFrame) userInfo:nil repeats:YES];
}

- (void)showFrame
{
//    static int i = 0;
//    [self.sampleImage setImage:[UIImage imageWithData:[self.videoManager getFrameImageDataWithVideoDict:self.sampleVideo withIndex:i]]];
//    i++;
//    if (i == [[self.sampleVideo objectForKey:@"Framecount"] intValue]) {
//        [self.playVideoTimer invalidate];
//        i = 0;
//    }
}

#pragma mark - TCP socket manager delegate

- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command
{
    [self.socketManager receiveMessageWithTimeOut:-1];
}
- (void)didSendData
{
}
- (void)didReceiveACKWithState:(CTL_MESSAGE_PACKET)ACK
{
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

- (void)didDisconnectSocket
{}

- (void)didReceiveLensStatus:(LENS_PARAMS)lensStatus
{}

- (void)didSetIRISWithStatus:(SDB_STATE)state
{}

- (void)didReceiveDebugInfo:(DEBUG_INFO)info
{
}

- (void)didLoseAlive
{}

- (void)didReceiveDevInfo:(DEV_INFO)decInfo
{}

- (void)didFinishDownloadRecordingData:(NSData *)recordData withCMD:(SDB_COMM_SIG_TYPE)CMD
{
//    if (CMD == SDB_GET_RECORD_DES) {
//        [self.videoManager setVideoHeadInfoWithHeadData:recordData withVideoDict:self.sampleVideo];
//        NSLog(@"sample video : %@", self.sampleVideo);
//    }
//    
//    //finishdate赋值，未超时
//    _finishDate = self.socketManager.connectTimer.fireDate;
//
//    if (CMD == SDB_GET_FIRST_FRAME) {
//        NSArray *array = [self.videoManager decodeFrameData:recordData withStartFrame:0 withFrameCount:1];
////        [self.videoManager storeVideoFrameWithData:array[0] WithPath:@"frame01"];
//
//        [self.videoManager recordFrameContentWithFrameImage:array[1] withFrameAudio:array[2] withFrameIndex:array[0]  withIndex:0 withVideoDict:self.sampleVideo];
//        dispatch_async(dispatch_get_main_queue(), ^(){
//            [self.sampleImage setImage:[UIImage imageWithData:[self.videoManager getFrameImageDataWithVideoDict:self.sampleVideo withIndex:0]]];
//        });
//    }
//    if (CMD == SDB_GET_FRAME) {
//        
//        NSArray *array = [[NSArray alloc] init];
//        if ([[self.sampleVideo objectForKey:@"Framecount"] intValue] - self.startIndex >= self.downloadFrameCount) {
//            array = [self.videoManager decodeFrameData:recordData withStartFrame:(int)self.startIndex withFrameCount:(int)self.downloadFrameCount];
//        }
//        else {array = [self.videoManager decodeFrameData:recordData withStartFrame:(int)self.startIndex
//                                                   withFrameCount:(int)([[self.sampleVideo objectForKey:@"Framecount"] intValue] - self.startIndex)];}
//        [self.videoManager recordMultiFramesContentWithDataArray:array withStartFrame:(int)self.startIndex withFrameCount:(int)self.downloadFrameCount withVideoDict:self.sampleVideo];
//        
//        self.startIndex = self.startIndex + self.downloadFrameCount;
//        NSInteger difference = [[self.sampleVideo objectForKey:@"Framecount"] intValue] - self.startIndex;
//        
//        if (difference > self.downloadFrameCount || difference == self.downloadFrameCount) {
//            
//            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFrameWithIDWithStartIndexWithAmount(0, (int)self.startIndex, (int)self.downloadFrameCount)];
//            [self executeTimeOutCounterWithCMD:@"CMDGetFrameWithIDWithStartIndexWithAmount" withIndex:(int)self.startIndex Amout:(int)self.downloadFrameCount];
//        }
//        else if (difference < self.downloadFrameCount && 0 < difference) {
//            
//            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFrameWithIDWithStartIndexWithAmount(0, (int)self.startIndex, (int)difference)];
//            
//            NSLog(@"difference is :%ld", (long)difference);
//            dispatch_async(dispatch_get_main_queue(), ^(){
//                //下载完成后，清空超时信息
//                self.timeOutInfo = nil;
//                [self.timeOutTimer setFireDate:[NSDate distantFuture]];
//                [self.timeOutTimer invalidate];
//                
//                [ProgressHUD showSuccess:@"已下载完0号视频"];
//                [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(playVideo) userInfo:nil repeats:NO];
//            });
//        }
//        if (difference == 0) {
//            
//        }
//    }
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
        NSLog(@".......................................................................................time out");
        if (!self.socketManager.isLost) {
            [self.socketManager tcpLingSocketConnectToHost];
            self.timeOutInfo = (NSDictionary *)[timer userInfo];
        }
        else {
            [ProgressHUD showError:@"同步超时" Interaction:NO];
            [self.timeOutTimer invalidate];
        }
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

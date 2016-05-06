//
//  PulseWaveController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/6/25.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "PulseWaveController.h"
//#import "PAImageView.h"
#import "JTWavePulser.h"
#import <QuartzCore/QuartzCore.h>
#import "CameraSoundPlayer.h"
#import "ProgressHUD.h"
#import "RootScrollViewController.h"
#import "JTMaterialTransition.h"
#import "JPSVolumeButtonHandler.h"
#import "CMDManager.h"
#import "SEFilterControl.h"
#import "SEFilterKnob.h"
#import "TTRangeSlider.h"
#import "BL32BitCheckSumValidator.h"
#import "UpdateViewController.h"
#import "WIFIDetector.h"
#import "MMPopLabel.h"
#import "YJSegmentedControl.h"
#import "BLAnimation.h"
#import "MRoundedButton.h"
#import "VideoClient.h"
#import "SaveLoadInfoManager.h"
#import "RootVideoBrowseViewController.h"
#import "BLFocusingIndicator.h"
#import "FirmwareManager.h"
#import "CustomedToolBar.h"
#import "BLRocker.h"
#import "CameraConfiguration.h"
#import "YAScrollSegmentControl.h"
#import "BLCountDowner.h"
#import "EyemoreVideo.h"
#import "VideoConfig.h"
#import "VideoListController.h"

#define kscanShootTimeInterval 0.2
#define kLanscapeDirection CGAffineTransformMakeRotation(- M_PI / 2);
#define kPortraitDirection CGAffineTransformMakeRotation( M_PI * 2);
#define kSelfieShootCount 30

@interface PulseWaveController ()<imageClientDelegate, TCPSocketManagerDelegate, TTRangeSliderDelegate, UIAlertViewDelegate, MMPopLabelDelegate, YJSegmentedControlDelegate, LiveViewRecorderDelegate, VideoRecorderDelegate, BLRockerDelegate, YAScrollSegmentControlDelegate, BLCountDownerDelegate>
{
    NSMutableDictionary *_HDVideoInfo;
    BOOL _isSocketManagerTransforing;
    BOOL _firstime;
    int remoteNumber;
}
//@property (strong, nonatomic)          PAImageView *imageButtom;
//@property (strong, nonatomic)          NSTimer     *scanShootTimer;
@property (strong, nonatomic) NSTimer              *pulseTimer1;
@property (strong, nonatomic) NSTimer              *pulseTimer2;
@property (strong, nonatomic) UIView               *topView;
@property (strong, nonatomic) UIImageView          *canvas;
@property (strong, nonatomic) UIImageView          *liveView;
@property (strong, nonatomic) CustomedToolBar      *toolBar;
@property (strong, nonatomic) UIButton             *detailButton;
@property (strong, nonatomic) UIButton             *menuToolButton;
@property (strong, nonatomic) UIBarButtonItem      *reloadButton;
@property (strong, nonatomic) UIBarButtonItem      *fullScreenButton;
@property (strong, nonatomic) UIProgressView       *recordProgressBar;
@property (strong, nonatomic) UIActivityIndicatorView *MovieIndicator;
@property (strong, nonatomic) UILabel              *recordLabel;
@property (strong, nonatomic) UIView               *focusingCoordinateView;
@property (strong, nonatomic) UIToolbar            *filterBar;
@property (strong, nonatomic) CustomedToolBar      *bottomBar;
@property (strong, nonatomic) CustomedToolBar      *extendBar1;
@property (strong, nonatomic) UIView               *selectedFrame;
@property (strong, nonatomic) UILabel              *burstShootingView;
@property (strong, nonatomic) UIButton             *hideButton;

@property (strong, nonatomic) JTWavePulserAnimation *animation;
@property (nonatomic)         JTMaterialTransition  *transition;
@property (strong, nonatomic) JPSVolumeButtonHandler *volumeButtonHandler;
@property (strong, nonatomic) YJSegmentedControl   *segment;
@property (strong, nonatomic) YAScrollSegmentControl *scrollSegment;

@property (strong, nonatomic) SEFilterControl      *exposurevValueFilter;
@property (strong, nonatomic) SEFilterControl      *shutterFilter;
@property (strong, nonatomic) SEFilterControl      *irisFilter;
@property (strong, nonatomic) TTRangeSlider        *exposureSlider;
@property (strong, nonatomic) TTRangeSlider        *shutterSlider;
@property (strong, nonatomic) TTRangeSlider        *irisSlider;

@property (strong, nonatomic) MRoundedButton       *takeButton;
@property (strong, nonatomic) UIView               *borderButton;
@property (strong, nonatomic) MRoundedButton       *recordButton;

@property (strong, nonatomic) NSArray              *irisArray;
@property (strong, nonatomic) NSArray              *shutterArray;
@property (strong, nonatomic) NSArray              *exposureArray;
@property (strong, nonatomic) NSArray              *irisDisplayArray;
@property (assign, nonatomic) NSInteger             irisMinValue;
@property (strong, nonatomic) NSTimer              *recordAutoProgressTimer;
@property (strong, nonatomic) NSTimer              *longPressTimer;
@property (strong, nonatomic) NSTimer              *selfieShootTimer;

@property (strong, nonatomic) EyemoreVideo         *sampleVideoInfo;

@property (assign, nonatomic) NSInteger             debouncingFlag;
@property (assign, nonatomic) NSInteger             selfieCount;
@property (assign, nonatomic) BOOL                  isExecuteShootTimer;
@property (strong, nonatomic) MMPopLabel           *popLinkLabel;
//@property (assign, nonatomic) BOOL                  isTakeButtonTapped;
@property (assign, nonatomic) BOOL                  isRecordButtonTapped;
@property (assign, nonatomic) BOOL                  isFullScreen;
@property (assign, nonatomic) BOOL                  isTakeButtonLongPressed;
@property (assign, nonatomic) int                   downloadedFrameCount;

//@property (strong, nonatomic) UIPickerView         *EVPickerView;
//@property (strong, nonatomic) UIPickerView         *shutterPickerView;
//@property (strong, nonatomic) UIPickerView         *irisPickerView;

@property (strong, nonatomic) UILabel              *evLabelCurrent;
@property (strong, nonatomic) UILabel              *shutterLabelCurrent;
@property (strong, nonatomic) UILabel              *irisLabelCurrent;

@property (strong, nonatomic) BLRocker             *evRocker;
@property (strong, nonatomic) BLRocker             *shutterRocker;
@property (strong, nonatomic) BLRocker             *irisRocker;
@property (strong, nonatomic) BLFocusingIndicator  *focusingIndicator;
@property (strong, nonatomic) UIButton             *resetButton;
@property (strong, nonatomic) UIView               *extendToolView;

@end

@implementation PulseWaveController

+ (PulseWaveController *)sharedPulseWaveController
{
    static PulseWaveController *instance = nil;
    if (instance == nil) {
        instance = [[PulseWaveController alloc] init];
    }
    return instance;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
    //解决由于第一次进入该界面下，音量键没有初始化是拍立得还是自拍模式而产生音量键无法使用的问题，以及第一次加载app时，该界面无法接收到来自appdelegate进入前台的消息而无法触发
//    static BOOL firstLoad = YES;
//    if (firstLoad) {
//        [self setShootModeToSync];
//        //[self detect3dbNetWork];
//        firstLoad = NO;
//    }
    if (self.shootMode == LIVEVIEW_MODE || self.shootMode == RECORDING_MOVIE_MODE || self.shootMode == SELFIE_MODE || self.shootMode == HD_RECORDING_MODE) {
        [self.liveViewRecorder startLiveViewing];
    }
    //[self detect3dbNetWork];
    [self controllerAppear];
    [self updateUIWithoutConnection];
    [self updateUIToolBarWithMode:self.shootMode];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_firstime) {
        [self.scrollSegment setSelectedIndex:1];
        _firstime = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"view will disappear , stop timer, set camera mode to download mode");
    //[self disappearingHandle];
    [self stopBreathPulsing];
    //[self.selfieTimer invalidate];
    self.imgClient.syncLeavingFlag = self.imgClient.lastImageIndex;
    //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    if (self.shootMode == LIVEVIEW_MODE || self.shootMode == RECORDING_MOVIE_MODE || self.shootMode == HD_RECORDING_MODE || self.shootMode == SELFIE_MODE) {
        [self.liveViewRecorder stopLiveViewing];
    }
}

//- (void)disappearingHandle
//{
//    [self stopBreathPulsing];
//    [self.selfieTimer invalidate];
//    //self.autoRotate = YES;
//    self.imgClient.syncLeavingFlag = self.imgClient.lastImageIndex;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"pulse wave controller view did load");
    // Do any additional setup after loading the view.
    //单例图像管理对象
    self.imgClient = [ImageClient sharedImageClient];
    self.imgClient.delegate = self;
    
    //单例视频管理对象
    self.videoManager = [VideoClient sharedVideoClient];
    
    //设置工作模式
    self.imgClient.cameraMode = SYNCMODE;
    
    self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    self.socketManager.delegate = self;
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToDDR];
    
    //初始化PAImageView
//    self.imageButtom =[[PAImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width / 4 ) * 3, self.view.bounds.size.height - 57, 100, 100) backgroundProgressColor:[UIColor whiteColor] progressColor:[UIColor lightGrayColor]];
//    self.imageButtom.center = CGPointMake(self.view.bounds.size.width / 2 , self.view.bounds.size.height / 2);
//    [self.imageButtom setAlpha:1.0];
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfieReviewTapped:)];
//    [self.imageButtom addGestureRecognizer:singleTap];
    
    //初始化wave动画效果
    [self setUpWavePulser];

    //初始化顶层uiview，添加点击事件
    //[self setUpTopView];
    
    //初始化dismiss button
    //[self setUpDismissButon];
    
    [self.socketManager addObserver:self forKeyPath:@"isLost" options:NSKeyValueObservingOptionOld context:nil];

    //初始化选择器
    [self setUpSegmentControl];
    [self setUpScrollSegmentControl];
    
    //初始化顶部工具条
    [self setUpToolBar];
    
    //初始化底部工具条
    [self setUpBottomBar];
    
    //初始化提示窗
    [self setUpPoPLinkLabel];
    
    //初始化滤镜bar
    [self setUpFilterBar];
    
    //初始化相机设置控件
//    [self setUpEVPickerView];
//    [self setUpShutterPickerView];
//    [self setUpIrisPickerView];
    
    //初始化相机设置控件
    [self setUpSettingFilters];
    
    //初始化扩展工具按钮
    //[self setUpResetButton];
    //初始化扩展工具窗
    //[self setUpExtendToolView];

    //初始化通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modeDetectingFore)    name:@"EnterForeground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modeDetectingBack)    name:@"EnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doubleDismiss)        name:@"doubleDismiss" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setShootModeToSync)   name:@"setShootModeToSync" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setShootModeToSelfie) name:@"setShootModeToSelfie" object:nil];
    
    self.isFullScreen = NO;
    
    [self setShootModeToSync];
    _firstime = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)exposureValueChanged:(SEFilterControl *)sender
//{
//    NSLog(@"exposure sender index : %lu", (unsigned long)sender.selectedIndex);
//    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetExposureValueParam([self convertToExposureValueWithIndex:(int)sender.selectedIndex])];
//}
//
//- (void)shutterValueChanged:(SEFilterControl *)sender
//{
//    //NSLog(@"shutter sender index : %lu", (unsigned long)sender.selectedIndex);
//    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetShutterParam([self convertToShutterValueWithIndex:(int)sender.selectedIndex])];
//}
//
//- (void)irisValueChanged:(SEFilterControl *)sender
//{
//    NSLog(@"IRIS sender index : %lu", (unsigned long)sender.selectedIndex);
//    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetIRISParams([self convertToIRISValueWithIndex:(int)sender.selectedIndex])];
//}

//- (void)detect3dbNetWork
//{
//    if (![[WIFIDetector sharedWIFIDetector] isConnecting3dbCamera]) {
//
//        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(popingLinkLabel) userInfo:nil repeats:NO];
//        
//    }
//}



#pragma mark - wave pulsing controlling

- (void)startBreathPulsing
{
    [self startPulsing];
}

- (void)stopBreathPulsing
{
    [self.pulseTimer1 invalidate];
    [self.pulseTimer2 invalidate];
    [self.animation stopPulsing];
}
- (void)stopPulsing
{
    [self.animation stopPulsing];
    self.pulseTimer1 = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(startPulsing) userInfo:nil repeats:NO];
}

- (void)startPulsing
{
    [self.animation startPulsing];
    self.pulseTimer2 = [NSTimer scheduledTimerWithTimeInterval:0.6f target:self selector:@selector(stopPulsing) userInfo:nil repeats:NO];
}

#pragma mark - Tapping action events

- (void)selfieReviewTapped:(id)sender {
    
    NSLog(@"selfie review button tapped");

    [self showImage];
}

- (void)topViewTapped{
    
    [self showImage];
}

- (IBAction)dimissButtonTapped:(id)sender {
    
    //[self.socketManager stopKeepingAlive];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)doubleDismiss
{
    NSLog(@"double dismiss");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)takePicButtonTappedDown
{
    NSLog(@"take pic button tapped down start");
    
    //self.isTakeButtonTapped = YES;
    [self updateUIButton:self.takeButton withTapped:YES];
    //    if (self.shootMode == SYNC_MODE || self.shootMode == LIVEVIEW_MODE) {
    //        _isSocketManagerTransforing = YES;
    //        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDRemoteSnapshot(1)];
    //    }
    self.isTakeButtonLongPressed = NO;
    [self.longPressTimer invalidate];
    self.longPressTimer = nil;
    self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.8f target:self selector:@selector(takeButtonLongPressed) userInfo:nil repeats:NO];
}

- (void)takePicButtonTappedUp
{
    NSLog(@"take pic button tapped up release");
    [self.longPressTimer setFireDate:[NSDate distantFuture]];
    [self.longPressTimer invalidate];
    self.longPressTimer = nil;
    
    if (self.isTakeButtonLongPressed) {
        [self updateUIButton:self.takeButton withTapped:NO];
        if (self.shootMode == LIVEVIEW_MODE) {
            [self.liveViewRecorder startLiveViewing];
        }
    }
    else {
        if (self.shootMode == SYNC_MODE || self.shootMode == LIVEVIEW_MODE) {
            _isSocketManagerTransforing = YES;
            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDRemoteSnapshot(remoteNumber)];
        }
        
        else if (self.shootMode == SELFIE_MODE){
            NSLog(@"selfie - shoot");
            if (!self.socketManager.isLost) {
                BLCountDowner *counter = [[BLCountDowner alloc] initWithCountTime:3 onView:self.view withColor:[UIColor redColor] withBeeping:YES];
                counter.delegate = self;
                [counter startCounting];
            }
        }
    }
    self.isTakeButtonLongPressed = NO;
}

- (void)takeButtonLongPressed
{
    [self.longPressTimer invalidate];
    self.longPressTimer = nil;

    self.isTakeButtonLongPressed = YES;
    NSLog(@"take pic button long pressed");
    if (self.shootMode == LIVEVIEW_MODE) {
        [self.liveViewRecorder stopLiveViewing];
        if (self.shootMode == SYNC_MODE || self.shootMode == LIVEVIEW_MODE) {
            _isSocketManagerTransforing = YES;
            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDRemoteSnapshot(1)];
        }
    }
}

- (void)MovieDetailButtonTapped
{
    VideoListController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"RootVideoBrowseNaviController"];
    //VideoBrowserController *controller = [[VideoBrowserController alloc] init];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)recordButtonTapped
{
    //NSLog(@"record button tapped with video list : %lu",(unsigned long)self.videoManager.videoList.count);
    static BOOL willRecording = YES;
    if (self.takeButton.isSelected) {
        willRecording = NO;
    }
    else willRecording = YES;
    
    if (willRecording) {
        
        self.sampleVideoInfo = [[EyemoreVideo alloc] initWithProfileDict:@[@"0", @"0", @"250", @"480", @"270", @"", @"", @"", @""]];
        if ([[VideoConfig sharedVideoConfig] myEyemoreVideos] != nil) {
            int videoIndex = (int)[[VideoConfig sharedVideoConfig] myLastEyemoreVideo].uid + 1;
            self.sampleVideoInfo.uid = videoIndex;
        }
        else self.sampleVideoInfo.uid = 0;
        
        //    if (self.shootMode == RECORDING_MOVIE_MODE || self.shootMode == HD_RECORDING_MODE) {
        if (self.shootMode == RECORDING_MOVIE_MODE) {
            
            self.videoRecorder = [VideoRecorder sharedVideoRecorder];
            [self.videoRecorder startLDRecording];
            [self setUpRecordProgressBar];
            [self startRecordAutoProgressing];
            [self updateUIButton:self.takeButton withRecorded:YES];

            //self.sampleVideoInfo.videoType = @"LD_RECORDING";
            //[self setUpRecordProgressBar];
            //[self startRecordAutoProgressing];
            //[self updateUIButton:self.takeButton withTapped:YES];
            //由于实时取景回调时间的不确定性，务必在视频词典创建后再设置以下标志位
            //self.downloadedFrameCount = 0;
            //self.isRecordButtonTapped = YES;
            //[NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(stopRecordingVideoFrames) userInfo:nil repeats:NO];
        }
        
        if (self.shootMode == HD_RECORDING_MODE) {
            
            self.recordLabel.text = @"正在录制...";
            self.videoRecorder = [VideoRecorder sharedVideoRecorder];
            [self.videoRecorder startHDRecording];
            [self setUpRecordProgressBar];
            [self startRecordAutoProgressing];
            [self updateUIButton:self.takeButton withRecorded:YES];
        }
    }
    else {
        [self updateUIButton:self.takeButton withRecorded:NO];
        [self stopRecording];
        
    }

}

- (void)coordinateViewTapped:(id)sender
{
    UITapGestureRecognizer *tapped = sender;
    CGPoint tappedLocation = [tapped locationInView:self.focusingCoordinateView];
    CGPoint transLocation  = [self transferPositionTo1080pWithPoint:(CGPoint)tappedLocation];
    NSLog(@"tapped loacation X: %.0f, location Y: %.0f", tappedLocation.x, tappedLocation.y);
    [self setUpFocusingIndicator];
    [self.focusingIndicator startFocusingOnPosition:tappedLocation onView:self.focusingCoordinateView];
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetFocusPoint((int)transLocation.x, (int)transLocation.y)];
}

- (void)menuToolButtonTapped
{
//    [CameraSoundPlayer playSwipeSoundWithVibrate:NO];
//    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(resetExposure) userInfo:nil repeats:NO];
//    [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(resetShutter) userInfo:nil repeats:NO];
//    [NSTimer scheduledTimerWithTimeInterval:0.7f target:self selector:@selector(resetIRISParams) userInfo:nil repeats:NO];
//    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(getStatus) userInfo:nil repeats:NO];
    static BOOL isShown = YES;
    if (isShown) {
        [self setUpExtendToolView];
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^(){
//            CGAffineTransform at = CGAffineTransformMakeRotation(M_PI / 4);
//            [self.extendToolButton setTransform:at];
            [self.resetButton setBackgroundColor:[UIColor redColor]];
            self.resetButton.center = CGPointMake(self.resetButton.center.x, self.resetButton.center.y - 100);
            self.extendToolView.center = CGPointMake(self.extendToolView.center.x, self.extendToolView.center.y - 100);
        } completion:^(BOOL finished){
            isShown = NO;
        }];
    }
    else {
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
//            CGAffineTransform at = CGAffineTransformMakeRotation( 3 * M_PI / 4);
//            [self.extendToolButton setTransform:at];
            [self.resetButton setBackgroundColor:[UIColor whiteColor]];
            self.resetButton.center = CGPointMake(self.resetButton.center.x, self.resetButton.center.y + 100);
            self.extendToolView.center = CGPointMake(self.extendToolView.center.x, self.extendToolView.center.y + 100);
        } completion:^(BOOL finished){
            isShown = YES;
            [self unSetUpExtendToolView];
        }];
    }
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFilterMode];
    [CameraSoundPlayer playSwipeSoundWithVibrate:NO];
}


- (void)resetButtonTapped:(id)sender
{
//    static BOOL isShown = YES;
//    if (isShown) {
//        [self setUpExtendToolView];
//        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^(){
//            CGAffineTransform at = CGAffineTransformMakeRotation(M_PI / 4);
//            [self.extendToolButton setTransform:at];
//            [self.extendToolButton setBackgroundColor:[UIColor redColor]];
//            self.extendToolButton.center = CGPointMake(self.extendToolButton.center.x, self.extendToolButton.center.y - 100);
//            self.extendToolView.center = CGPointMake(self.extendToolView.center.x, self.extendToolView.center.y - 100);
//        } completion:^(BOOL finished){
//            isShown = NO;
//        }];
//    }
//    else {
//        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
//            CGAffineTransform at = CGAffineTransformMakeRotation(- M_PI / 2);
//            [self.extendToolButton setTransform:at];
//            [self.extendToolButton setBackgroundColor:[UIColor whiteColor]];
//            self.extendToolButton.center = CGPointMake(self.extendToolButton.center.x, self.extendToolButton.center.y + 100);
//            self.extendToolView.center = CGPointMake(self.extendToolView.center.x, self.extendToolView.center.y + 100);
//        } completion:^(BOOL finished){
//            isShown = YES;
//            [self unSetUpExtendToolView];
//        }];
//    }
//    [CameraSoundPlayer playSwipeSoundWithVibrate:NO];
    
    [CameraSoundPlayer playSwipeSoundWithVibrate:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(resetExposure) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(resetShutter) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.7f target:self selector:@selector(resetIRISParams) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(getStatus) userInfo:nil repeats:NO];
    
}

- (void)extendBar1ItemTapped:(id)sender
{
    UIButton *btn = sender;

    static BOOL isSelectedFullFrame = YES;
    if (btn.tag == 3) {
        if (isSelectedFullFrame) {
            [btn setTitle:@"满帧视频" forState:UIControlStateNormal];
            isSelectedFullFrame = NO;
            [btn setTitleColor:[UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1] forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor redColor]];
        }
        else {
            [btn setTitle:@"半帧视频" forState:UIControlStateNormal];
            isSelectedFullFrame = YES;
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1]];
        }
    }
    
    if (btn.tag == 2) {
        if (remoteNumber == 3) {
            remoteNumber = 1;
            [CameraConfiguration saveSmartBurstConfig:NO];
            [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1]];
        }
        else {
            remoteNumber = 3;
            [CameraConfiguration saveSmartBurstConfig:YES];
            [btn setTitleColor:[UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1] forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor redColor]];

        }
    }
    if (btn.tag == 1) {
        
        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(resetExposure) userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(resetShutter) userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:0.7f target:self selector:@selector(resetIRISParams) userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(getStatus) userInfo:nil repeats:NO];
    }
    [CameraSoundPlayer playSwipeSoundWithVibrate:NO];
}

- (void)reloadButtonTapped
{
    [self.liveViewRecorder startLiveViewing];
}

- (void)fullScreenButtonTapped
{
    if (self.isFullScreen) {
        [self updateUIWithPortait];
    }
    else [self updateUIWithLanscape];
}

- (void)filterBarItemTapped:(id)sender
{
    UIButton *btn = sender;
    [self setUpSelectedFrameOnView:btn];
    
    if ([btn.titleLabel.text isEqualToString:@"质感"]) {
        //[self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetBWDisplayParam(DISPLAY_COLOR)];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetFilterMode(DISPLAY_COLOR)];
    }
    if ([btn.titleLabel.text isEqualToString:@"标准"]) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetFilterMode(DISPLAY_SOFT)];
    }
    if ([btn.titleLabel.text isEqualToString:@"黑白"]) {
        //[self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetBWDisplayParam(DISPLAY_BLACKANDWHITE)];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetFilterMode(DISPLAY_BLACKANDWHITE)];
    }
    if ([btn.titleLabel.text isEqualToString:@"星空"]) {
        //[self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetBWDisplayParam(DISPLAY_BLACKANDWHITE)];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetFilterMode(DISPLAY_LONG_EXPOSURE)];
    }
    [CameraSoundPlayer playSwipeSoundWithVibrate:NO];
}

- (void)resetExposure
{
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetExposureValueParam([self convertToExposureValueWithIndex:(signed int)0])];
}

- (void)resetShutter
{
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetShutterParam([self convertToShutterValueWithIndex:(signed int)0])];
}

- (void)resetIRISParams
{
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetIRISParams([self convertToIRISValueWithIndex:(signed int)0])];
}

- (void)evHandleSwipeFrom:(UISwipeGestureRecognizer *)regonizer
{
    static int i = 0;
    if (regonizer.direction == UISwipeGestureRecognizerDirectionUp) {
        if (i < 20) {
            i ++;
            [CameraSoundPlayer playSwipeSoundWithVibrate:NO];
        }
        else {
            [CameraSoundPlayer playSwipeSoundWithVibrate:YES];
        }
        NSLog(@"up : %d",i);
    }
    
    if (regonizer.direction == UISwipeGestureRecognizerDirectionDown) {
        if (i > 0) {
            i --;
            [CameraSoundPlayer playSwipeSoundWithVibrate:NO];
        }
        else {
            [CameraSoundPlayer playSwipeSoundWithVibrate:YES];
        }
        NSLog(@"down : %d",i);
    }
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetExposureValueParam([self convertToExposureValueWithIndex:[self.exposureArray[i] intValue]])];
    self.evLabelCurrent.text = self.exposureArray[i];
}

- (void)shutterHandleSwipeFrom:(UISwipeGestureRecognizer *)regonizer
{
    static int i = 0;
    if (regonizer.direction == UISwipeGestureRecognizerDirectionUp) {
        if (i < 6) {
            i ++;
            [CameraSoundPlayer playSwipeSoundWithVibrate:NO];
        }
        else {
            [CameraSoundPlayer playSwipeSoundWithVibrate:YES];
        }
        NSLog(@"up : %d",i);
    }
    
    if (regonizer.direction == UISwipeGestureRecognizerDirectionDown) {
        if (i > 0) {
            i --;
            [CameraSoundPlayer playSwipeSoundWithVibrate:NO];
        }
        else {
            [CameraSoundPlayer playSwipeSoundWithVibrate:YES];
        }
        NSLog(@"down : %d",i);
    }
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetShutterParam([self convertToShutterValueWithIndex:[self.shutterArray[i] intValue]])];
    self.shutterLabelCurrent.text = self.shutterArray[i];
}

- (void)irisHandleSwipeFrom:(UISwipeGestureRecognizer *)regonizer
{
    static int i = 0;
    if (regonizer.direction == UISwipeGestureRecognizerDirectionUp) {
        if (i < 6) {
            i ++;
            [CameraSoundPlayer playSwipeSoundWithVibrate:NO];
        }
        else {
            [CameraSoundPlayer playSwipeSoundWithVibrate:YES];
        }
        NSLog(@"up : %d",i);
    }
    
    if (regonizer.direction == UISwipeGestureRecognizerDirectionDown) {
        if (i > 0) {
            i --;
            [CameraSoundPlayer playSwipeSoundWithVibrate:NO];
        }
        else {
            [CameraSoundPlayer playSwipeSoundWithVibrate:YES];
        }
        NSLog(@"down : %d",i);
    }
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetIRISParams([self convertToIRISValueWithIndex:[self.irisDisplayArray[i] intValue]])];
    self.irisLabelCurrent.text = self.irisDisplayArray[i];
}


- (void)getStatus
{
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetLensStatus];
}

- (void)startToDownloadVideoFrames
{
    self.recordLabel.text = @"正在下载视频帧...";
    [self setUpRecordProgressBar];
    [self updateRecordProgressBarToColor:[UIColor greenColor]];
    [self.videoRecorder getRecordDesWithID:0];
}

- (void)showImage {
    
    if (self.imgClient.imgPath.count > 0) {

        
        RootScrollViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"root"];
        //controller.scrollArray = self.imgClient.syncImgPath;
        controller.scrollArray = self.imgClient.imgPath;
        if (self.shootMode == SELFIE_MODE && self.isExecuteShootTimer) {
            controller.shootMode = SELFIE_MODE;
        }
        if (self.shootMode == LIVEVIEW_MODE) {
            controller.shootMode = LIVEVIEW_MODE;
        }
        else {
            controller.shootMode = SYNC_MODE;
        }
        
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationLandscapeLeft:
                controller.presentingDirection = UIInterfaceOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                controller.presentingDirection = UIInterfaceOrientationLandscapeLeft;
                break;
            case UIDeviceOrientationPortrait:
                controller.presentingDirection = UIInterfaceOrientationPortrait;
                break;
            default:
                controller.presentingDirection = UIInterfaceOrientationPortrait;
                break;
        }
        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = UIInterfaceOrientationPortrait;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
        
        //NSLog(@"self.imgClient.imgPath :%@", self.imgClient.imgPath);
        //controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        // Indicate you use a custom transition
        //controller.modalPresentationStyle = UIModalPresentationCustom;
        //controller.transitioningDelegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
    }
}


#pragma mark - Notification center

- (void)setShootModeToSync
{
    self.shootMode = SYNC_MODE;
    self.isExecuteShootTimer = NO;
}
- (void)setShootModeToSelfie
{
    self.shootMode = SELFIE_MODE;
    self.debouncingFlag = 0;
    self.selfieCount = 0;
    self.isExecuteShootTimer = NO;
}

- (void)modeDetectingFore
{
    NSLog(@"notification detecting fore");
    if (self.imgClient.cameraMode == SYNCMODE) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToDDR];

    }
    else [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
    //[self detect3dbNetWork];

}

- (void)modeDetectingBack
{
    NSLog(@"notification detecting back");
    if (self.imgClient.cameraMode == SYNCMODE) {
    }
}

- (void)controllerAppear
{
    NSLog(@"notification view will appear");
    
    //设置工作模式
    self.imgClient = [ImageClient sharedImageClient];
    self.imgClient.delegate = self;
    
    
    self.imgClient.cameraMode = SYNCMODE;
    
    self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    self.socketManager.delegate = self;
    if (self.shootMode == LIVEVIEW_MODE) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToDDR];
    }
    if (self.shootMode == RECORDING_MOVIE_MODE) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
    }
    [self.socketManager startKeepingAlive];
    //[self.socketManager setCameraToSyncMode];
    
    if (!self.socketManager.isLost) {
        NSLog(@"fire timer view will appear");
        
        [self startBreathPulsing];
        self.animation.pulseRingColor = [UIColor colorWithRed:251/255.0 green:32/255.0 blue:7/255.0 alpha:1];
        self.animation.pulseRingBackgroundColor = [UIColor colorWithRed:251/255.0 green:32/255.0 blue:7/255.0 alpha:1];
    }
    else{
        [self stopBreathPulsing];
        [self.irisFilter           setAlpha:0.5];
        [self.irisFilter           setEnabled:NO];
        [self.exposurevValueFilter setAlpha:0.5];
        [self.exposurevValueFilter setEnabled:NO];
        [self.exposurevValueFilter setSelectedIndex:3 animated:YES];
        [self.shutterFilter        setAlpha:0.5];
        [self.shutterFilter        setEnabled:NO];
        [self.exposureSlider       setAlpha:0.5];
        [self.exposureSlider       setEnabled:NO];
        [self.shutterSlider        setAlpha:0.5];
        [self.shutterSlider        setEnabled:NO];
        [self.irisSlider           setAlpha:0.5];
        [self.irisSlider           setEnabled:NO];
    }
    
    if (self.imgClient.imgPath.count == 0) {
    }
    else{
        [self.backGroundImageView setImage:[UIImage imageNamed:@"3db_拍立得3"]];
    }
    self.autoRotate = NO;
    
    //observing volume buttons event
    //[self setUpVolumeButtonHandler];
    
    //若有固件更新，提示
//    static int oneTimeUpdateNoti = 0;
//    FirmwareManager *manager = [FirmwareManager sharedFirmwareManager];
//    if (!self.socketManager.isLost && [manager checkingCameraShouldUpdateWithCamVer:manager.camVerison] && oneTimeUpdateNoti == 0) {
//        oneTimeUpdateNoti = 1;
//        UpdateViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"updateController"];
//        controller.currentVersion = [[manager.camVerison substringFromIndex:1] floatValue];
//        controller.message = [NSString stringWithFormat:@"检测到您的设备: %@ 有新固件: %@ 待升级, 为不影响您的体验, 建议您确定更新 \n更新说明: \n%@",[[WIFIDetector sharedWIFIDetector] getDeviceSSID], manager.latestUpdate, manager.latestUpdateInfo];
//        [self presentViewController:controller animated:YES completion:nil];
//    }
}

- (void)selfieCounter
{
//    static int i = 0;
    [CameraSoundPlayer playSelfieSound];
    self.selfieCount++;
    if (self.selfieCount >= 3) {
        self.selfieCount = 0;
        //[self.selfieTimer invalidate];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDRemoteSnapshot(1)];
        //self.debouncingFlag = 0;
    }
}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isLost"]) {
        
        if (!self.socketManager.isLost) {
            NSLog(@"fire timer view will appear");
            
            self.animation.pulseRingColor = [UIColor colorWithRed:251/255.0 green:32/255.0 blue:7/255.0 alpha:1];
            self.animation.pulseRingBackgroundColor = [UIColor colorWithRed:251/255.0 green:32/255.0 blue:7/255.0 alpha:1];
        }
        else{
            NSLog(@"wifi is lost, wave pulser should be stopped");
            [self stopBreathPulsing];
        }
    }
}

-(void)dealloc
{
    [self.socketManager removeObserver:self forKeyPath:@"isLost"];
}


#pragma mark - BL Counter Delegate
- (void)BLCounterdidFinishCounting:(BLCountDowner *)counter
{
    counter = nil;
    [self.liveViewRecorder stopLiveViewing];
    [self.selfieShootTimer invalidate];
    self.selfieShootTimer = nil;
    self.selfieShootTimer = [NSTimer scheduledTimerWithTimeInterval:0.35f target:self selector:@selector(selfieShooting) userInfo:nil repeats:YES];
}

- (void)selfieShooting
{
    static int count = 0;
    if (count < kSelfieShootCount) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDRemoteSnapshot(1)];
        count++;
    }
    else {
        count = 0;
        [self.liveViewRecorder startLiveViewing];
        [self.selfieShootTimer setFireDate:[NSDate distantFuture]];
        [self.selfieShootTimer invalidate];
        self.selfieShootTimer = nil;
    }
}


#pragma mark - YJSegmentedControl Delegate

- (void)segumentSelectionChange:(NSInteger)selection{
    
    NSLog(@"Button selected at index: %lu", (long)index);
    if (selection == 0) {
        NSLog(@"拍立得按下");
        if (self.shootMode == LIVEVIEW_MODE) {
            [self.liveViewRecorder stopLiveViewing];
            [self hideLiveWindow];
            [self updateUIWithMode:SYNC_MODE];
        }
        
        if (self.shootMode == SELFIE_MODE) {
            [self.liveViewRecorder stopLiveViewing];
            [self hideLiveWindow];
            [self updateUIWithMode:SYNC_MODE];
        }
        
        if (self.shootMode == RECORDING_MOVIE_MODE) {
            [self.liveViewRecorder stopLiveViewing];
            [self hideLiveWindow];
            [self updateUIWithMode:SYNC_MODE];
        }
        
        if (self.shootMode == HD_RECORDING_MODE) {
            [self hideCanvas];
            [self.liveViewRecorder stopLiveViewing];
            [self hideLiveWindow];
            [self updateUIWithMode:SYNC_MODE];
        }
        //        [self.liveViewRecorder stopLiveViewing];
        //        [self hideLiveWindow];
        //        if (self.shootMode == RECORDING_MOVIE_MODE || self.shootMode == HD_RECORDING_MODE) {
        //            [self updateUIWithMode:SYNC_MODE];
        //        }
        self.shootMode = SYNC_MODE;
        
    }
    
    else if (selection == 1){
        NSLog(@"实时取景按下");
        if (self.shootMode == SYNC_MODE) {
            [self showLiveViewWindow];
            [self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
            [self updateUIWithMode:LIVEVIEW_MODE];
        }
        
        if (self.shootMode == SELFIE_MODE) {
        }
        
        if (self.shootMode == RECORDING_MOVIE_MODE) {
            [self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
            [self updateUIWithMode:LIVEVIEW_MODE];
        }
        
        if (self.shootMode == HD_RECORDING_MODE) {
            [self hideCanvas];
            [self showLiveViewWindow];
            [self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
            [self updateUIWithMode:LIVEVIEW_MODE];
        }
        self.shootMode = LIVEVIEW_MODE;
    }
    
    else if (selection == 2) {
        NSLog(@"自拍30张按下");
        if (self.shootMode == SYNC_MODE) {
            [self showLiveViewWindow];
            [self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
            [self updateUIWithMode:SELFIE_MODE];
        }
        
        if (self.shootMode == LIVEVIEW_MODE) {
            
        }
        if (self.shootMode == RECORDING_MOVIE_MODE) {
            [self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
            [self updateUIWithMode:SELFIE_MODE];
        }
        
        if (self.shootMode == HD_RECORDING_MODE) {
            [self hideCanvas];
            [self showLiveViewWindow];
            [self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
            [self updateUIWithMode:SELFIE_MODE];
        }
        self.shootMode = SELFIE_MODE;
        
        
    }
    else if (selection == 3){
        NSLog(@"10s段视频按下");
        if (self.shootMode == SYNC_MODE) {
            [self showLiveViewWindow];
            [self.liveViewRecorder setViewingMode:LIVE_RECORDING_MODE];
            [self updateUIWithMode:RECORDING_MOVIE_MODE];
        }
        
        if (self.shootMode == LIVEVIEW_MODE) {
            [self.liveViewRecorder setViewingMode:LIVE_RECORDING_MODE];
            [self updateUIWithMode:RECORDING_MOVIE_MODE];
            
        }
        
        if (self.shootMode == SELFIE_MODE) {
            [self.liveViewRecorder setViewingMode:LIVE_RECORDING_MODE];
            [self updateUIWithMode:RECORDING_MOVIE_MODE];
        }
        
        if (self.shootMode == HD_RECORDING_MODE) {
            [self hideCanvas];
            [self showLiveViewWindow];
            [self.liveViewRecorder setViewingMode:LIVE_RECORDING_MODE];
            [self updateUIWithMode:RECORDING_MOVIE_MODE];
        }
        //        if (self.shootMode == SYNC_MODE || self.shootMode == HD_RECORDING_MODE) {
        //            [self showLiveViewWindow];
        //            [self.liveViewRecorder setViewingMode:LIVE_RECORDING_MODE];
        //            //[self hideCanvas];
        //        }
        //
        //        if (self.shootMode == SYNC_MODE || self.shootMode == LIVEVIEW_MODE) {
        //            [self.liveViewRecorder setViewingMode:LIVE_RECORDING_MODE];
        //            [self updateUIWithMode:RECORDING_MOVIE_MODE];
        //        }
        self.shootMode = RECORDING_MOVIE_MODE;
    }
    
    else if (selection == 4){
        NSLog(@"高清录制按下");
        //[self showCanvas];
        if (self.shootMode == SYNC_MODE) {
            //3.00 modified
            [self showLiveViewWindow];
            [self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
            [self updateUIWithMode:HD_RECORDING_MODE];
        }
        
        if (self.shootMode == LIVEVIEW_MODE) {
            [self updateUIWithMode:HD_RECORDING_MODE];
            //[self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
            //[self.liveViewRecorder stopLiveViewing];
            //[self hideLiveWindow];
        }
        
        if (self.shootMode == RECORDING_MOVIE_MODE) {
            //[self.liveViewRecorder stopLiveViewing];
            //[self hideLiveWindow];
            //3.00 modified
            [self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
        }
        self.shootMode = HD_RECORDING_MODE;
        //3.00 modified
        //[self setUpRecordLabel];
    }
    [self updateUIToolBarWithMode:self.shootMode];
    [CameraSoundPlayer playSwipeSoundWithVibrate:NO];
    
}

#pragma mark - YA Scroll Segment Control Delegate

- (void)didSelectItemAtIndex:(NSInteger)selection
{
    NSLog(@"Button selected at index: %lu", (long)index);
    if (selection == 0) {
        NSLog(@"拍立得按下");
        if (self.shootMode == LIVEVIEW_MODE) {
            [self.liveViewRecorder stopLiveViewing];
            [self hideLiveWindow];
            [self updateUIWithMode:SYNC_MODE];
        }
        
        if (self.shootMode == SELFIE_MODE) {
            [self.liveViewRecorder stopLiveViewing];
            [self hideLiveWindow];
            [self updateUIWithMode:SYNC_MODE];
        }
        
        if (self.shootMode == RECORDING_MOVIE_MODE) {
            [self.liveViewRecorder stopLiveViewing];
            [self hideLiveWindow];
            [self updateUIWithMode:SYNC_MODE];
        }
        
        if (self.shootMode == HD_RECORDING_MODE) {
            [self hideCanvas];
            [self.liveViewRecorder stopLiveViewing];
            [self hideLiveWindow];
            [self updateUIWithMode:SYNC_MODE];
        }
        //        [self.liveViewRecorder stopLiveViewing];
        //        [self hideLiveWindow];
        //        if (self.shootMode == RECORDING_MOVIE_MODE || self.shootMode == HD_RECORDING_MODE) {
        //            [self updateUIWithMode:SYNC_MODE];
        //        }
        self.shootMode = SYNC_MODE;
        
    }
    
    else if (selection == 1){
        NSLog(@"实时取景按下");
        if (self.shootMode == SYNC_MODE) {
            [self showLiveViewWindow];
            [self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
            [self updateUIWithMode:LIVEVIEW_MODE];
        }
        
        if (self.shootMode == SELFIE_MODE) {
        }
        
        if (self.shootMode == RECORDING_MOVIE_MODE) {
            [self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
            [self updateUIWithMode:LIVEVIEW_MODE];
        }
        
        if (self.shootMode == HD_RECORDING_MODE) {
            [self hideCanvas];
            [self showLiveViewWindow];
            [self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
            [self updateUIWithMode:LIVEVIEW_MODE];
        }
        self.shootMode = LIVEVIEW_MODE;
    }
    
    else if (selection == 2) {
        NSLog(@"自拍30张按下");
        if (self.shootMode == SYNC_MODE) {
            [self showLiveViewWindow];
            [self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
            [self updateUIWithMode:SELFIE_MODE];
        }
        
        if (self.shootMode == LIVEVIEW_MODE) {
            
        }
        if (self.shootMode == RECORDING_MOVIE_MODE) {
            [self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
            [self updateUIWithMode:SELFIE_MODE];
        }
        
        if (self.shootMode == HD_RECORDING_MODE) {
            [self hideCanvas];
            [self showLiveViewWindow];
            [self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
            [self updateUIWithMode:SELFIE_MODE];
        }
        self.shootMode = SELFIE_MODE;

        
    }
    else if (selection == 3){
        NSLog(@"10s段视频按下");
        if (self.shootMode == SYNC_MODE) {
            [self showLiveViewWindow];
            [self.liveViewRecorder setViewingMode:LIVE_RECORDING_MODE];
            [self updateUIWithMode:RECORDING_MOVIE_MODE];
        }
        
        if (self.shootMode == LIVEVIEW_MODE) {
            [self.liveViewRecorder setViewingMode:LIVE_RECORDING_MODE];
            [self updateUIWithMode:RECORDING_MOVIE_MODE];
            
        }
        
        if (self.shootMode == SELFIE_MODE) {
            [self.liveViewRecorder setViewingMode:LIVE_RECORDING_MODE];
            [self updateUIWithMode:RECORDING_MOVIE_MODE];
        }
        
        if (self.shootMode == HD_RECORDING_MODE) {
            //[self hideCanvas];
            //[self showLiveViewWindow];
            [self.liveViewRecorder setViewingMode:LIVE_RECORDING_MODE];
            [self updateUIWithMode:RECORDING_MOVIE_MODE];
        }
        //        if (self.shootMode == SYNC_MODE || self.shootMode == HD_RECORDING_MODE) {
        //            [self showLiveViewWindow];
        //            [self.liveViewRecorder setViewingMode:LIVE_RECORDING_MODE];
        //            //[self hideCanvas];
        //        }
        //
        //        if (self.shootMode == SYNC_MODE || self.shootMode == LIVEVIEW_MODE) {
        //            [self.liveViewRecorder setViewingMode:LIVE_RECORDING_MODE];
        //            [self updateUIWithMode:RECORDING_MOVIE_MODE];
        //        }
        self.shootMode = RECORDING_MOVIE_MODE;
    }
    
    else if (selection == 4){
        NSLog(@"高清录制按下");
        //[self showCanvas];
        if (self.shootMode == SYNC_MODE) {
            //3.00 modified
            [self showLiveViewWindow];
            [self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
            [self updateUIWithMode:HD_RECORDING_MODE];
        }
        
        if (self.shootMode == LIVEVIEW_MODE) {
            [self updateUIWithMode:HD_RECORDING_MODE];
            //[self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
            //[self.liveViewRecorder stopLiveViewing];
            //[self hideLiveWindow];
        }
        
        if (self.shootMode == RECORDING_MOVIE_MODE) {
            //[self.liveViewRecorder stopLiveViewing];
            //[self hideLiveWindow];
            //3.00 modified
            [self.liveViewRecorder setViewingMode:LIVE_VIEWING_MODE];
        }
        self.shootMode = HD_RECORDING_MODE;
        //3.00 modified
        //[self setUpRecordLabel];
    }
    [self updateUIToolBarWithMode:self.shootMode];
    [CameraSoundPlayer playSwipeSoundWithVibrate:NO];

}

#pragma mark - TTRange Slider Delegate

- (void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum
{
    //NSLog(@"exposure sender index : %lu", (unsigned long)sender.selectedIndex);
    if (sender == self.exposureSlider) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetExposureValueParam([self convertToExposureValueWithIndex:(signed int)selectedMaximum])];
    }
    if (sender == self.shutterSlider) {
        NSLog(@"shutter sender index : %lu, selected Maximum : %d,", (unsigned long)[self convertToShutterValueWithIndex:(signed int)selectedMaximum],(signed int)selectedMaximum);
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetShutterParam([self convertToShutterValueWithIndex:(signed int)selectedMaximum])];
    }
    if (sender == self.irisSlider) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetIRISParams([self convertToIRISValueWithIndex:(signed int)selectedMaximum])];
    }
}

#pragma mark - Video Recorder Delegate

- (void)videoRecorderDidDownloadVideoFramesWithEyemoreVideo:(EyemoreVideo *)recordVideo
{
    //还原socket代理者为self
    self.socketManager.delegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        self.isRecordButtonTapped = NO;
        //[self.videoManager.videoList addObject:self.sampleVideoInfo];
        //update ui state
        [self updateUIButton:self.takeButton withTapped:NO];
        //[self updateUIButton:self.takeButton withRecorded:NO];
        [self updateRecordProgressBarToColor:[UIColor redColor]];
        [self showCanvasAnimation];
        [self unSetUpRecordProgressBar];
        [self setUpMovieIndicator];
        [self.detailButton setImage:nil forState:UIControlStateNormal];
        [self.liveViewRecorder startLiveViewing];
        self.recordLabel.text = @"正在封装视频...";
    });
    
//    if (self.shootMode == HD_RECORDING_MODE) {
//        __block PulseWaveController *blockSelf = self;
//        [self.videoManager encodeMovieFromImagesWithVideoInfo:self.sampleVideoInfo withCallBackBlock:^(BOOL success){
//            [self.videoManager addAudioTrackIntoMovieWithDict:self.sampleVideoInfo withCallBackBlock:^(BOOL success){
//                if (success) {
//                    NSLog(@"HD封装视频成功");
//                    [blockSelf finishedDownloadingHandler];
//                }
//            }];
//        }];
//    }
}

//- (void)finishedDownloadingHandler
//{
//    //[self.sampleVideoInfo removeAllObjects];
//    dispatch_async(dispatch_get_main_queue(), ^(){
//        //update ui state
//        [self.detailButton setBackgroundImage:[self.videoManager getThumbnailImageWithEyemoeVideo:[[VideoConfig sharedVideoConfig] myLastEyemoreVideo]] forState:UIControlStateNormal];
//        [self unSetUpMovieIndicator];
//        [self unSetUpRecordProgressBar];
//        [self.detailButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
//        self.recordLabel.text = @"点击下方按钮开始录制";
//    });
//}

- (void)videoRecorderDidDownloadProcessing:(float)progress
{
    NSLog(@"hd movie downloading processing: %f", progress);
    dispatch_async(dispatch_get_main_queue(), ^(){
    
        if (self.shootMode == HD_RECORDING_MODE) {
            if (progress <= 0.99) {
                [self.recordProgressBar setProgress:progress animated:NO];
            }
        }
    });
}

- (void)videoRecorderDidDownloadDroppedVideoFramesWithEyemoreVideo:(EyemoreVideo *)recordVideo;
{
    //还原socket代理者为self
    self.socketManager.delegate = self;
    NSLog(@"补帧完成");
    
    //停止取帧，刷新界面
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self updateUIButton:self.takeButton withTapped:NO];
        //[self updateUIButton:self.takeButton withRecorded:NO];
    });
    
    if (self.shootMode == RECORDING_MOVIE_MODE) {
        [self.liveViewRecorder startLiveViewing];
        //封装视频
        [self.videoManager composeCompleteMovieFileWithEyemoreVideo:self.sampleVideoInfo withCallBackBlock:^(BOOL success){
            if (success) {
                NSLog(@"，封装视频成功");
                //[self.sampleVideoInfo removeAllObjects];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"EyemoreVideosUpdated" object:nil];
                    //update ui state
                    [self.detailButton setBackgroundImage:[self.videoManager getThumbnailImageWithEyemoeVideo:[[VideoConfig sharedVideoConfig] myLastEyemoreVideo]] forState:UIControlStateNormal];
                    [self unSetUpMovieIndicator];
                    [self.detailButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
                });
            }
        }];
    }
    else if (self.shootMode == HD_RECORDING_MODE) {
        //只封装音频
//        [self.videoManager generateVideoAudioWithVideoInfo:self.sampleVideoInfo];
//        [self.videoManager removeVideoFrameIndexWithVideoInfo:self.sampleVideoInfo];
//        //音频合成后开始下载960 540帧
//        NSLog(@"已经封装音频，开始下载960_540帧");
//        dispatch_async(dispatch_get_main_queue(), ^(){
//            [self.liveViewRecorder stopLiveViewing];
//            self.videoRecorder = [VideoRecorder sharedVideoRecorder];
//            self.videoRecorder.delegate = self;
//            self.socketManager.delegate = self.videoRecorder;
//            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(startToDownloadVideoFrames) userInfo:nil repeats:NO];
//        });

    }
}

- (void)stopRecordingVideoFrames
{
    //10秒后停止取帧
    dispatch_async(dispatch_get_main_queue(), ^(){
        self.isRecordButtonTapped = NO;
        [self.videoManager.videoList addObject:self.sampleVideoInfo];
        //update ui state
        //        [self updateUIButton:self.takeButton withTapped:NO];
        [self showCanvasAnimation];
        [self unSetUpRecordProgressBar];
        [self setUpMovieIndicator];
        [self.detailButton setImage:nil forState:UIControlStateNormal];
    });
    //检查是否漏帧
    NSArray *array = [self.videoManager checkingDroppedFramesWithEyemoreVideo:self.sampleVideoInfo];
    if (array.count != 0) {
        
        [self.liveViewRecorder stopLiveViewing];
        self.videoRecorder = [VideoRecorder sharedVideoRecorder];
        self.videoRecorder.delegate = self;
        self.socketManager.delegate = self.videoRecorder;
        [self.videoRecorder downloadDroppedFramesWithEyemoreVideo:self.sampleVideoInfo fromIndexs:array];
    }
    
    else {
        
        if (self.shootMode == RECORDING_MOVIE_MODE) {
            //封装视频
            [self.videoManager composeCompleteMovieFileWithEyemoreVideo:self.sampleVideoInfo withCallBackBlock:^(BOOL success){
                if (success) {
                    NSLog(@"封装视频成功");
                    //[self.sampleVideoInfo removeAllObjects];
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"EyemoreVideosUpdated" object:nil];
                        //update ui state
                        [self.detailButton setBackgroundImage:[self.videoManager getThumbnailImageWithEyemoeVideo:[[VideoConfig sharedVideoConfig] myLastEyemoreVideo]] forState:UIControlStateNormal];
                        [self unSetUpMovieIndicator];
                        [self.detailButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
                        [self updateUIButton:self.takeButton withTapped:NO];
                        //[self updateUIButton:self.takeButton withRecorded:NO];
                    });
                }
            }];
        }
        else if (self.shootMode == HD_RECORDING_MODE) {
////            //只封装音频
//            [self.videoManager generateVideoAudioWithVideoInfo:self.sampleVideoInfo];
//            [self.videoManager removeVideoFrameIndexWithVideoInfo:self.sampleVideoInfo];
//            //音频合成后开始下载960 540帧
//            NSLog(@"已经封装音频，开始下载960_540帧");
//            dispatch_async(dispatch_get_main_queue(), ^(){
//                [self.liveViewRecorder stopLiveViewing];
//                self.videoRecorder = [VideoRecorder sharedVideoRecorder];
//                self.videoRecorder.delegate = self;
//                self.socketManager.delegate = self.videoRecorder;
//                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(startToDownloadVideoFrames) userInfo:nil repeats:NO];
//            });
        }
    }
}


#pragma mark - Live view recorder Delegate

- (void)didGetLiveViewData:(NSArray *)data
{

    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.reloadButton setEnabled:NO];
        [self.liveView setImage:[UIImage imageWithData:data[1]]];
    });
    
    if (self.isRecordButtonTapped) {
        if (self.shootMode == RECORDING_MOVIE_MODE) {
            [self.videoManager recordFrameContentWithFrameImage:data[1]
                                                 withFrameAudio:data[2]
                                                 withFrameIndex:data[0]
                                                      withIndex:self.downloadedFrameCount
                                               withEyemoreVideo:self.sampleVideoInfo];

        }
        else if (self.shootMode == HD_RECORDING_MODE) {
            [self.videoManager recordFrameContentWithFrameImage:nil
                                                 withFrameAudio:data[2]
                                                 withFrameIndex:data[0]
                                                      withIndex:self.downloadedFrameCount
                                               withEyemoreVideo:self.sampleVideoInfo];

        }
        //        static float progress = 0.004;
//        dispatch_async(dispatch_get_main_queue(), ^(){
//            [self.recordProgressBar setProgress:progress animated:YES];
//        });
        
        if ([[[self.sampleVideoInfo.videoMaterial objectForKey:@"FrameIndexs"] objectAtIndex:0] intValue] + 250 <= [[[self.sampleVideoInfo.videoMaterial objectForKey:@"FrameIndexs"] lastObject] intValue]) {
            [self stopRecordingVideoFrames];
        }
        if (self.downloadedFrameCount == 249) {
            //[self.liveViewRecorder stopLiveViewing];
            //progress = 0;
//            dispatch_async(dispatch_get_main_queue(), ^(){
//                self.isRecordButtonTapped = NO;
//                [self.videoManager.videoList addObject:self.sampleVideoInfo];
//                //update ui state
//                [self updateUIButton:self.takeButton withTapped:NO];
//                [self showCanvasAnimation];
//                [self unSetUpRecordProgressBar];
//                [self setUpMovieIndicator];
//                [self.detailButton setImage:nil forState:UIControlStateNormal];
//            });
//            [self.videoManager composeCompleteMovieFileWithInfo:self.sampleVideoInfo withCallBackBlock:^(BOOL success){
//                if (success) {
//                    NSLog(@"封装视频成功");
//                    //[self.sampleVideoInfo removeAllObjects];
//                    dispatch_async(dispatch_get_main_queue(), ^(){
//                        //update ui state
//                        [self.detailButton setBackgroundImage:[self.videoManager getThumbnailImageWithVideoInfo:[self.videoManager.videoList lastObject]] forState:UIControlStateNormal];
//                        [self unSetUpMovieIndicator];
//                        [self.detailButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
//                    });
//                }
//            }];
        }
        
        NSLog(@"current frame....................................:%d",self.downloadedFrameCount);
        self.downloadedFrameCount ++;
//        progress = progress + 0.004;
    }
    data = nil;
    
}
- (void)didLoseLiveViewDataWithType:(LIVEVIEWOFFLINETYPE)type
{
    NSLog(@"live view offline type: %d", type);
    if (self.shootMode == LIVEVIEW_MODE || self.shootMode == RECORDING_MOVIE_MODE || self.shootMode == HD_RECORDING_MODE || self.shootMode == SELFIE_MODE) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.reloadButton setEnabled:YES];
            
        });
        //若为相机断开连接，则自动重连取景
        if (type == LiveSocketOfflineByServer || type == LiveSocketOfflineByCam) {
            [self.liveViewRecorder autoRestartLiveViewing];
        }
    }
}

#pragma mark - Socket - Manager - delegate

- (void)didFinishSingleFileDownloadingWithImageData:(NSData *)imageData
{
    NSLog(@"did finish download image and display : %lu", (unsigned long)[imageData length]);

    [self.imgClient storeSingleImageWithData:imageData];
    //NSLog(@"img path :%@", self.imgClient.imgPath);
    //[self.imageButtom updateWithImage:[UIImage imageWithData:imageData] animated:YES];
    
    //self.imgClient.lastImageIndex = self.imgClient.syncImgPath.count - 1;
    self.imgClient.lastImageIndex = self.imgClient.imgPath.count - 1;
    self.imgClient.syncLeavingFlag = self.imgClient.lastImageIndex;
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDReceiveOInMode(0)];
        [self.socketManager receiveMessageWithTimeOut:-1];
        [CameraSoundPlayer playSound];
        if (self.shootMode == SYNC_MODE) {
            [self updateUIButton:self.takeButton withTapped:NO];
            [self showImage];
        }
        //如果是实时取景，则传输实际大小照片完毕时再开启实时取景，同时更新缩略图
        if (self.shootMode == LIVEVIEW_MODE) {
            //[self showCanvasAnimation];
            [self updateUIButton:self.takeButton withTapped:NO];
            [self updateUIWithoutConnection];
            //[self.liveViewRecorder startLiveViewing];
            
            static int i = 1;
            if (self.isTakeButtonLongPressed) {
                
                _isSocketManagerTransforing = YES;
                [self.liveView setImage:[self.imgClient getImageForKey:[self.imgClient.imgPath lastObject]]];
                [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDRemoteSnapshot(1)];
                [self setUpBurstShootingLabelWithCount:i];
                i ++;
            }
            else {
//                if (remoteNumber == 1) {
                    [self showCanvasAnimation];
//                }
                [self unSetUpBurstShootingViewWithCount:i];
                i = 1;
            }
        }
        if (self.shootMode == SELFIE_MODE) {
            [self updateUIButton:self.takeButton withTapped:NO];
            [self updateUIWithoutConnection];
            [self.liveView setImage:[self.imgClient getImageForKey:[self.imgClient.imgPath lastObject]]];
        }
    });
    _isSocketManagerTransforing = NO;
}

- (void)didDisconnectSocket
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self stopBreathPulsing];
        [self.irisFilter           setAlpha:0.5];
        [self.irisFilter           setEnabled:NO];
        [self.exposurevValueFilter setAlpha:0.5];
        [self.exposurevValueFilter setEnabled:NO];
        [self.shutterFilter        setAlpha:0.5];
        [self.shutterFilter        setEnabled:NO];
        [self.exposureSlider       setAlpha:0.5];
        [self.exposureSlider       setEnabled:NO];
        [self.shutterSlider        setAlpha:0.5];
        [self.shutterSlider        setEnabled:NO];
        [self.irisSlider           setAlpha:0.5];
        [self.irisSlider           setEnabled:NO];
    });

}

- (void)didFinishConnectToHost
{

    NSLog(@"*****************************************************************");
    dispatch_async(dispatch_get_main_queue(), ^(){
        //[ProgressHUD showSuccess:@"连接成功" Interaction:NO];
    });
    if (self.imgClient.cameraMode == SYNCMODE && !self.socketManager.isLost) {
        
        //self.isConnectedHost = YES;
        NSLog(@"did connect to host in sync controller");
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToDDR];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self startBreathPulsing];
            [self.popLinkLabel dismiss];
        });
    }
}
- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command
{
//    if (command == (CTL_MESSAGE_PACKET)) {
//
//    }
    [self.socketManager receiveMessageWithTimeOut:-1];
    NSLog(@"[self.socketManager receiveMessageWithTimeOut:-1]");
}

- (void)didReceiveACKWithState:(CTL_MESSAGE_PACKET)ACK
{
    if (ACK.cmd == SDB_GET_FLASH_PHOTO_ACK) {
    }
    if (ACK.cmd == SDB_SET_DEV_WORK_MODE_ACK && ACK.param0 == DWM_FLASH_PHOTO) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetLensStatus];
    }
    
    if (ACK.cmd == SDB_SET_EXPOSURE_PARAM_ACK || ACK.cmd == SDB_SET_IRIS_PARAM_ACK || ACK.cmd == SDB_SET_SHUTTER_PARAM_ACK) {
        if (ACK.state != SDB_STATE_SUCCESS) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [ProgressHUD showError:@"设置失败"];
            });
        }
    }

    if (ACK.cmd == SDB_SET_RECV_OK_ACK) {
        NSLog(@"确认已接收图片");
    }
    if (ACK.cmd == SDB_GET_NORMAL_PHOTO_COUNT_ACK) {
        if (self.socketManager.fileList.paramn[0] != 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotoCountUpdate" object:[NSNumber numberWithInt:self.socketManager.fileList.paramn[0]]];
        }
    }
    if (ACK.cmd == SDB_PUSH_FOCUS_STATUS_ACK) {
        if (ACK.param0 == 1) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.focusingIndicator setFocusingDone];
                [CameraSoundPlayer playFocusSound];
            });
        }
    }
    if (ACK.cmd == SDB_GET_FILTER_MODE_ACK) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (ACK.param0 == DISPLAY_BLACKANDWHITE) {
                [self setUpSelectedFrameOnView:self.filterBar.items[5].customView];
            }
            if (ACK.param0 == DISPLAY_SOFT) {
                [self setUpSelectedFrameOnView:self.filterBar.items[1].customView];
            }
            if (ACK.param0 == DISPLAY_COLOR) {
                [self setUpSelectedFrameOnView:self.filterBar.items[3].customView];
            }
            if (ACK.param0 == DISPLAY_LONG_EXPOSURE) {
                [self setUpSelectedFrameOnView:self.filterBar.items[7].customView];
            }
        });
    }
    [self.socketManager receiveMessageWithTimeOut:-1];
}

- (void)didReceiveLensStatus:(LENS_PARAMS)lensStatus
{
    if (lensStatus.iris_min_value && lensStatus.iris_max_value) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = lensStatus.iris_min_value; i <= lensStatus.iris_max_value - 10; i ++) {
            [array addObject:[self decodeLensValueWith:i]];
        }
        self.irisArray = array;
        self.irisMinValue = (NSUInteger)lensStatus.iris_min_value;
        NSLog(@"len current iris : %lu, mini iris : %lu, shutter value : %lu", (unsigned long)lensStatus.current_iris_value, (unsigned long)lensStatus.iris_min_value,(unsigned long)lensStatus.current_shutter_value);
    }

    
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        [self.irisFilter           setAlpha:1];
        [self.irisFilter           setEnabled:YES];
        [self.exposurevValueFilter setAlpha:1];
        [self.exposurevValueFilter setEnabled:YES];
        [self.shutterFilter        setAlpha:1];
        [self.shutterFilter        setEnabled:YES];
        [self.exposureSlider       setAlpha:1];
        [self.exposureSlider       setEnabled:YES];
        [self.shutterSlider        setAlpha:1];
        [self.shutterSlider        setEnabled:YES];
        [self.irisSlider           setAlpha:1];
        [self.irisSlider           setEnabled:YES];
        
        [self updateUIButton:self.takeButton withTapped:NO];
        [self updateUIWithLensParam:lensStatus];
    });
    
    //if (self.shootMode == SYNC_MODE) {
    [self.socketManager receiveMessageWithTimeOut:-1];
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetDeviceInfo];
    [NSThread sleepForTimeInterval:0.1f];
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFileList];
    //}
}

- (void)didLoseAlive
{}

- (void)didReceiveDevInfo:(DEV_INFO)decInfo
{
    NSString *camVer = [NSString stringWithFormat:@"%s", decInfo.dev_version];
    FirmwareManager *manager = [FirmwareManager sharedFirmwareManager];
    manager.camVerison = [NSString stringWithString:camVer];
    [manager saveFirmware];
}

- (void)didReceiveDebugInfo
{}

- (void)didSendData
{}

- (void)didSetIRISWithStatus:(SDB_STATE)state
{}
#pragma mark - MMPopLabelDelegate
///////////////////////////////////////////////////////////////////////////////


- (void)dismissedPopLabel:(MMPopLabel *)popLabel
{
    NSLog(@"disappeared");
}

- (void)didPressButtonForPopLabel:(MMPopLabel *)popLabel atIndex:(NSInteger)index
{
    NSLog(@"pressed %li", (long)index);
    if (popLabel == self.popLinkLabel && index == 1) {
        [[WIFIDetector sharedWIFIDetector] openWIFISetting];
    }
}

//#pragma mark - Picker view Delegate
//
//// pickerView 列数
//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
//    
//    return 1;
//}
//
//// pickerView 每列个数
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
//    
//    if (pickerView == self.EVPickerView) {
//        return self.exposureArray.count;
//    }
//    if (pickerView == self.shutterPickerView) {
//        return self.shutterArray.count;
//    }
//    if (pickerView == self.irisPickerView) {
//        return self.irisArray.count;
//    }
//    else return 0;
//}
//
//// 每列宽度
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
//    
//    if (component == 0) {
//        return 50;
//    }
//    return 180;
//}
//// 返回选中的行
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
//{
//    NSLog(@"did select row : %ld, value : %@", (long)row, self.exposureArray[row]);
//    
//}
//
////返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
//-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    if (pickerView == self.EVPickerView) {
//        return [self.exposureArray objectAtIndex:row];
//    }
//    if (pickerView == self.shutterPickerView) {
//        return [self.shutterArray objectAtIndex:row];
//    }
//    if (pickerView == self.irisPickerView) {
//        return [self.irisArray objectAtIndex:row];
//    }
//    else return @"";
//    
//}
//
////返回每行view，可以设置view的外观
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
//    UILabel* pickerLabel = (UILabel*)view;
//    if (!pickerLabel){
//        pickerLabel = [[UILabel alloc] init];
//        // Setup label properties - frame, font, colors etc
//        //adjustsFontSizeToFitWidth property to YES
//        //pickerLabel.minimumFontSize = 8.;
//        [pickerLabel setTextColor:[UIColor whiteColor]];
//        pickerLabel.adjustsFontSizeToFitWidth = YES;
//        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
//        [pickerLabel setBackgroundColor:[UIColor clearColor]];
//        [pickerLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:25]];
//    }
//    // Fill the label text here
//    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
//    return pickerLabel;
//}

#pragma mark -  UIViewController Transitioning Delegate
//// Initialize the tansition
//- (void)createTransition
//{
//    // self.presentControllerButton is the animatedView used for the transition
//    self.transition = [[JTMaterialTransition alloc] initWithAnimatedView:self.wavePulser];
//}
//
//// Indicate which transition to use when you this controller present a controller
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
//                                                                  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
//{
//    self.transition.reverse = NO;
//    return self.transition;
//}
//
//// Indicate which transition to use when the presented controller is dismissed
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
//{
//    self.transition.reverse = YES;
//    return self.transition;
//}

#pragma mark - BLRocker Delegate

- (void)rockerDidChangeDirection:(BLRocker *)rocker
{
    [self rockerDirectionChangedHandling:rocker];
}

- (void)rockerDidScanDirection:(BLRocker *)rocker
{
    [self rockerDirectionChangedHandling:rocker];
}

- (void)rockerDirectionChangedHandling:(BLRocker *)rocker
{
    if (rocker == self.evRocker) {
        static int i = 0;
        if (rocker.direction == RockDirectionUp) {
            if (i < 20) {
                i ++;
                dispatch_async(dispatch_get_main_queue(), ^(){ [CameraSoundPlayer playSwipeSoundWithVibrate:NO]; });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^(){ [CameraSoundPlayer playSwipeSoundWithVibrate:NO]; });
            }
        }
        if (rocker.direction == RockDirectionDown) {
            if (i > 0) {
                i --;
                dispatch_async(dispatch_get_main_queue(), ^(){ [CameraSoundPlayer playSwipeSoundWithVibrate:NO]; });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^(){ [CameraSoundPlayer playSwipeSoundWithVibrate:NO]; });
            }
        }
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetExposureValueParam([self convertToExposureValueWithIndex:[self.exposureArray[i] intValue]])];
        self.evLabelCurrent.text = self.exposureArray[i];
    }
    if (rocker == self.shutterRocker) {
        static int i = 0;
        if (rocker.direction == RockDirectionUp) {
            if (i < 6) {
                i ++;
                dispatch_async(dispatch_get_main_queue(), ^(){ [CameraSoundPlayer playSwipeSoundWithVibrate:NO]; });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^(){ [CameraSoundPlayer playSwipeSoundWithVibrate:NO]; });
            }
        }
        if (rocker.direction == RockDirectionDown) {
            if (i > 0) {
                i --;
                dispatch_async(dispatch_get_main_queue(), ^(){ [CameraSoundPlayer playSwipeSoundWithVibrate:NO]; });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^(){ [CameraSoundPlayer playSwipeSoundWithVibrate:NO]; });
            }
        }
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetShutterParam([self convertToShutterValueWithIndex:[self.shutterArray[i] intValue]])];
        self.shutterLabelCurrent.text = self.shutterArray[i];
    }
    if (rocker == self.irisRocker) {
        static int i = 0;
        if (rocker.direction == RockDirectionUp) {
            if (i < 6) {
                i ++;
                dispatch_async(dispatch_get_main_queue(), ^(){ [CameraSoundPlayer playSwipeSoundWithVibrate:NO]; });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^(){ [CameraSoundPlayer playSwipeSoundWithVibrate:NO]; });
            }
        }
        
        if (rocker.direction == RockDirectionDown) {
            if (i > 0) {
                i --;
                dispatch_async(dispatch_get_main_queue(), ^(){ [CameraSoundPlayer playSwipeSoundWithVibrate:NO]; });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^(){ [CameraSoundPlayer playSwipeSoundWithVibrate:NO]; });
            }
        }
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetIRISParams([self convertToIRISValueWithIndex:[self.irisDisplayArray[i] intValue]])];
        self.irisLabelCurrent.text = self.irisDisplayArray[i];
    }
}

#pragma mark - UI initialization & presenting events

- (void)setUpWavePulser
{
    //初始化wave动画效果
    self.wavePulser = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.wavePulser.backgroundColor = [UIColor redColor];
    CGPoint viewCenter = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 4.9 * 1);
    self.wavePulser.center = viewCenter;
    self.wavePulser.layer.cornerRadius = 50;//self.wavePulser.layer.bounds.size.width / 2;
    self.wavePulser.layer.borderColor = [[UIColor greenColor] CGColor];
    [self.view addSubview:self.wavePulser];
    
    self.animation = [JTWavePulser animationWithView:self.wavePulser];
    self.animation.pulseAnimationDuration = 1.0f;
    self.animation.pulseAnimationInterval = 0.3f;
    self.animation.pulseRingWidth = 0;
    self.animation.pulseRingScale = 3.0;
}

- (void)setUpTopView
{
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.height)];
    self.topView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *ViewSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topViewTapped)];
    [self.topView addGestureRecognizer:ViewSingleTap];
    [self.view insertSubview:self.topView aboveSubview:self.wavePulser];
}

- (void)setUpDismissButon
{
    self.dimissButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 30, 40, 40)];
    [self.dimissButton addTarget:self action:@selector(dimissButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.dimissButton setImage:[UIImage imageNamed:@"137-button-error"] forState:UIControlStateNormal];
    [self.topView addSubview:self.dimissButton];
}

- (void)setUpSegmentControl
{
    NSArray * btnDataSource = @[@"拍立得", @"抓拍", @"连拍", @"小视频" , @"高清录制"];
    UIFont *titleFont ;//= [UIFont fontWithName:@".Helvetica Neue Interface" size:18.0f];
    //6p,6sp界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 414) {
        titleFont = [UIFont fontWithName:@".Helvetica Neue Interface" size:18.0f];
    }
    //5,5s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 320) {
        titleFont = [UIFont fontWithName:@".Helvetica Neue Interface" size:15.0f];
    }
    //6,6s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 375) {
        titleFont = [UIFont fontWithName:@".Helvetica Neue Interface" size:16.5f];
    }
    self.segment = [YJSegmentedControl segmentedControlFrame:CGRectMake(0, self.view.frame.size.height / 3 * 1 + 33, self.view.bounds.size.width, 50)
                                             titleDataSource:btnDataSource
                                             backgroundColor:[UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1]
                                                  titleColor:[UIColor grayColor]
                                                   titleFont:titleFont
                                                 selectColor:[UIColor redColor]
                                             buttonDownColor:[UIColor clearColor]
                                                    Delegate:self];
    
    //[self.view addSubview:self.segment];
}

- (void)setUpScrollSegmentControl
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height / 3 * 1 + 33, self.view.bounds.size.width, 50)];
    view.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
    
    NSArray * btnDataSource = @[@"拍立得 ", @" 抓拍 ", @" 连拍 ", @" 小视频 " , @" 高清录制"];
    UIFont *titleFont ;//= [UIFont fontWithName:@".Helvetica Neue Interface" size:18.0f];
    //6p,6sp界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 414) {
        titleFont = [UIFont fontWithName:@".Helvetica Neue Interface" size:17.0f];
    }
    //5,5s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 320) {
        titleFont = [UIFont fontWithName:@".Helvetica Neue Interface" size:16.5f];
        btnDataSource = @[@"拍立得", @"抓拍", @"连拍", @"小视频" , @"高清录制"];
    }
    //6,6s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 375) {
        titleFont = [UIFont fontWithName:@".Helvetica Neue Interface" size:16.5f];
        btnDataSource = @[@"拍立得", @"抓拍", @"连拍", @"小视频" , @"高清录制"];
    }
    self.scrollSegment = [[YAScrollSegmentControl alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    self.scrollSegment.buttons = btnDataSource;
    self.scrollSegment.delegate = self;
    [self.scrollSegment setFont:titleFont];
    self.scrollSegment.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
    [self.scrollSegment setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.scrollSegment setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [self.scrollSegment.scrollView setScrollEnabled:NO];
    [view addSubview:self.scrollSegment];
    [self.view addSubview:view];

}

- (void)setUpSettingFilters
{
    UIView *frame = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                             self.segment.frame.origin.y + self.segment.frame.size.height + (self.bottomBar.frame.origin.y - (self.segment.frame.origin.y + self.segment.frame.size.height)) / 4 - self.view.frame.size.height / 26,
                                                             self.view.frame.size.width / 10 * 9 + 5,
                                                             self.view.frame.size.height / 13)];
    frame.center = CGPointMake(self.view.frame.size.width / 2, frame.center.y - 10);
    frame.layer.masksToBounds = YES;
    frame.layer.cornerRadius = 5;
//    frame.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.45].CGColor;
//    frame.layer.borderWidth = 1.5;
    frame.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
    [self.view addSubview:frame];
    
    UILabel *exposureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    exposureLabel.center = CGPointMake(35, frame.frame.size.height / 2 );
    [exposureLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:17]];
    exposureLabel.text = @"曝光";
    exposureLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.45];
    self.exposureArray = [NSArray arrayWithObjects:@"-3", @"-2", @"-1", @"0", @"+1",@"+2",@"+3", nil];
    [frame addSubview:exposureLabel];
    
    
    
    UIView *frame1 = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                              self.segment.frame.origin.y + self.segment.frame.size.height + 2 * ((self.bottomBar.frame.origin.y - (self.segment.frame.origin.y + self.segment.frame.size.height)) / 4) - self.view.frame.size.height / 26 + 5,
                                                              self.view.frame.size.width / 10 * 9 + 5,
                                                              self.view.frame.size.height / 13)];
    frame1.center = CGPointMake(self.view.frame.size.width / 2, frame1.center.y - 10);
    frame1.layer.masksToBounds = YES;
    frame1.layer.cornerRadius = 5;
//    frame1.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.45].CGColor;
//    frame1.layer.borderWidth = 1.5;
    frame1.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
    [self.view addSubview:frame1];
    
    UILabel *shutterLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, self.view.bounds.size.height / 10 * 6.5, 40, 20)];
    shutterLabel.center = CGPointMake(35, frame.frame.size.height / 2 );
    shutterLabel.text = @"快门";
    [shutterLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:17]];
    shutterLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.45];
    self.shutterArray =[NSArray arrayWithObjects:@"0", @"+1", @"+2", @"+3", @"+4", @"+5", @"+6", nil];
    [frame1 addSubview:shutterLabel];
    
    
    
    UIView *frame2 = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                              self.segment.frame.origin.y + self.segment.frame.size.height + 3 * ((self.bottomBar.frame.origin.y - (self.segment.frame.origin.y + self.segment.frame.size.height)) / 4) - self.view.frame.size.height / 26 + 10,
                                                              self.view.frame.size.width / 10 * 9 + 5,
                                                              self.view.frame.size.height / 13)];
    frame2.center = CGPointMake(self.view.frame.size.width / 2, frame2.center.y - 10);
    frame2.layer.masksToBounds = YES;
    frame2.layer.cornerRadius = 5;
//    frame2.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.45].CGColor;
//    frame2.layer.borderWidth = 1.5;
    frame2.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
    [self.view addSubview:frame2];
    
    UILabel *irisLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, self.view.bounds.size.height / 10 * 6.5, 40, 20)];
    irisLabel.center = CGPointMake(35, frame.frame.size.height / 2);
    irisLabel.text = @"光圈";
    [irisLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:17]];
    irisLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.45];
    self.irisArray =[NSArray arrayWithObjects:@"0", @"-1", @"-2", @"-3", @"-4", @"-5", @"-6", nil];
    [frame2 addSubview:irisLabel];
    
    //TTRangeSlider init
    //EV Slider
    self.exposureSlider = [[TTRangeSlider alloc] initWithFrame:CGRectMake( 0, 0, frame.frame.size.width - 60, 70)];
    self.exposureSlider.center = CGPointMake(frame.center.x + 5, self.exposureSlider.center.y);
    self.exposureSlider.delegate        = self;
    self.exposureSlider.minValue        = -10;
    self.exposureSlider.maxValue        =  10;
    self.exposureSlider.selectedMinimum = -10;
    self.exposureSlider.selectedMaximum =  0;
    self.exposureSlider.disableRange = YES;
    self.exposureSlider.maxLabelColour  = [UIColor redColor];
    self.exposureSlider.tintColor       = [UIColor redColor];
    [frame addSubview:self.exposureSlider];
    
    //Shutter Slider
    self.shutterSlider = [[TTRangeSlider alloc] initWithFrame:CGRectMake( 0, 0, frame.frame.size.width - 60, 70)];
    self.shutterSlider.center = CGPointMake(frame.center.x + 5, self.shutterSlider.center.y);
    self.shutterSlider.delegate        = self;
    self.shutterSlider.minValue        = 0;
    self.shutterSlider.maxValue        = 6;
    self.shutterSlider.selectedMinimum = 0;
    self.shutterSlider.selectedMaximum = 0;
    self.shutterSlider.disableRange = YES;
    self.shutterSlider.maxLabelColour  = [UIColor redColor];
    self.shutterSlider.tintColor       = [UIColor redColor];
    [frame1 addSubview:self.shutterSlider];
    
    //IRIS Slider
    self.irisSlider = [[TTRangeSlider alloc] initWithFrame:CGRectMake( 0, 0, frame.frame.size.width - 60, 70)];
    self.irisSlider.center = CGPointMake(frame.center.x + 5, self.irisSlider.center.y);
    self.irisSlider.delegate        = self;
    self.irisSlider.minValue        = -6;
    self.irisSlider.maxValue        = 0;
    self.irisSlider.selectedMinimum = -6;
    self.irisSlider.selectedMaximum = 0;
    self.irisSlider.maxLabelColour  = [UIColor redColor];
    self.irisSlider.tintColor       = [UIColor redColor];
    [frame2 addSubview:self.irisSlider];
    
    //6p,6sp界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 414) {
        
    }
    //5,5s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 320) {
        
        self.exposureSlider.center = CGPointMake(frame.center.x + 10, self.exposureSlider.center.y - 5);
        self.shutterSlider.center  = CGPointMake(frame.center.x + 10, self.shutterSlider.center.y - 5);
        self.irisSlider.center     = CGPointMake(frame.center.x + 10, self.irisSlider.center.y - 5);
        [exposureLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:17]];
        [shutterLabel  setFont:[UIFont fontWithName:@"Trebuchet MS" size:17]];
        [irisLabel     setFont:[UIFont fontWithName:@"Trebuchet MS" size:17]];
    }
    //6,6s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 375) {
        
        [exposureLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:17]];
        [shutterLabel  setFont:[UIFont fontWithName:@"Trebuchet MS" size:17]];
        [irisLabel     setFont:[UIFont fontWithName:@"Trebuchet MS" size:17]];
    }
}

- (void)setUpPoPLinkLabel
{
    [[MMPopLabel appearance] setLabelColor:[UIColor colorWithRed: 0.89 green: 0.8 blue: 0 alpha: 1]];
    [[MMPopLabel appearance] setLabelTextColor:[UIColor whiteColor]];
    [[MMPopLabel appearance] setLabelTextHighlightColor:[UIColor greenColor]];
    [[MMPopLabel appearance] setLabelFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
    [[MMPopLabel appearance] setButtonFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
    
    self.popLinkLabel = [MMPopLabel popLabelWithText:
                         @"iPhone未连接相机无线热点"];
    
    self.popLinkLabel.delegate = self;
    
    UIButton *skipButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [skipButton setTitle:NSLocalizedString(@"忽略", @"Skip") forState:UIControlStateNormal];
    [self.popLinkLabel addButton:skipButton];
    
    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [okButton setTitle:NSLocalizedString(@"设置", @"Dismiss") forState:UIControlStateNormal];
    [self.popLinkLabel addButton:okButton];
    
    [self.view addSubview:self.popLinkLabel];
    //[self.popLinkLabel popAtView:self.downloadButton];
    
}

- (void)setUpToolBar
{
    if (self.toolBar == nil) {
        self.toolBar = [[CustomedToolBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 52)];
        [self.toolBar setTranslucent:NO];
        self.toolBar.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1];
        self.toolBar.tintColor = [UIColor lightGrayColor];
        
        UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(doubleDismiss)];
        UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *btn4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        self.fullScreenButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"fullScreen.png"] style:UIBarButtonItemStylePlain target:self action:@selector(fullScreenButtonTapped)];
        self.reloadButton     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadButtonTapped)];
        [self.reloadButton setEnabled:NO];
        NSArray *arr1=[[NSArray alloc]initWithObjects:btn1,btn2, self.fullScreenButton, btn4, self.reloadButton, nil];
        [self.toolBar setItems:arr1 animated:YES];
    }
    [self.view addSubview:self.toolBar];
}


- (void)setUpTakePicButton
{
    
    CGFloat buttonSize = 65;
    CGRect buttonRect1 = CGRectMake(self.view.bounds.size.width/10.0 * 1,
                                    self.view.bounds.size.height/10.0 * 8.5,
                                    buttonSize,
                                    buttonSize);
    self.takeButton = [[MRoundedButton alloc] initWithFrame:buttonRect1
                                                     buttonStyle:MRoundedButtonDefault
                                            appearanceIdentifier:[NSString stringWithFormat:@"%d", 2]];
    self.takeButton.backgroundColor = [UIColor clearColor];
    //[self setUpShadowWithView:self.takeButton];
    self.takeButton.textLabel.text = @"";
    self.takeButton.textLabel.font = [UIFont fontWithName:@"STHeitiJ-Light" size:25];
    //self.takeButton.imageView.image = [UIImage imageNamed:@"download2"];
    self.takeButton.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height  / 10 * 9.3);
//    [self.takeButton addTarget:self action:@selector(takePicButtonTapped) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.takeButton];
    
    [self.takeButton addTarget:self action:@selector(takePicButtonTappedDown) forControlEvents:UIControlEventTouchDown];
    //[self.view addSubview:self.takeButton];
    
    [self.takeButton addTarget:self action:@selector(takePicButtonTappedUp) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setUpTakeButtonBorder
{
    CGFloat buttonSize = 65;
    CGRect buttonRect1 = CGRectMake(self.view.bounds.size.width/10.0 * 1,
                                    self.view.bounds.size.height/10.0 * 8.5,
                                    buttonSize,
                                    buttonSize);
    self.borderButton = [[UIView alloc] initWithFrame:buttonRect1];
    self.borderButton.backgroundColor = [UIColor clearColor];
    self.borderButton.layer.masksToBounds = YES;
    self.borderButton.layer.cornerRadius = 32.5;
    self.borderButton.layer.borderWidth = 4;
    self.borderButton.layer.borderColor = [UIColor redColor].CGColor;
    //[self setUpShadowWithView:self.borderButton];
    //self.takeButton.imageView.image = [UIImage imageNamed:@"download2"];
    //self.borderButton.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 10 * 9.3);
    
    //[self.borderButton setUserInteractionEnabled:NO];
    [self.borderButton addSubview:self.takeButton];
    self.takeButton.center = CGPointMake(32.5, 32.5);
    //[self.view addSubview:self.borderButton];
}

- (void)setUpRecordButton
{
    [self.takeButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.takeButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchDown];
    [self.takeButton addTarget:self action:@selector(recordButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [UIView animateWithDuration:0.2f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^(){
                         self.takeButton.foregroundColor = [UIColor redColor];
                         self.takeButton.foregroundAnimateToColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
                     }
                     completion:^(BOOL finish){}];
}

- (void)setUpDetailButton
{
    self.detailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 46)];
    [self.detailButton.layer setCornerRadius:3.0];

    //[self setUpShadowWithView:self.detailButton];
    
    self.detailButton.center = CGPointMake(self.view.frame.size.width / 6.5 * 1, self.view.frame.size.height / 10 * 9.4);
    self.detailButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.detailButton addTarget:self action:@selector(showImage) forControlEvents:UIControlEventTouchUpInside];
    if (self.imgClient.imgPath.count != 0) {
        NSLog(@"path :%@",self.imgClient.imgPath);
        [self.detailButton setImage:[self.imgClient getImageForKey:[self.imgClient.imgPath lastObject]] forState:UIControlStateNormal];
        self.detailButton.backgroundColor = [UIColor clearColor];
    }
    else {
        [self.detailButton setImage:nil forState:UIControlStateNormal];
        self.detailButton.backgroundColor = [UIColor blackColor];
    }
    //[self.view addSubview:self.detailButton];
}

- (void)setUpMovieDetailButton
{
    [self.detailButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    [self.detailButton addTarget:self action:@selector(MovieDetailButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.detailButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    if ([[VideoConfig sharedVideoConfig] myEyemoreVideos].count != 0) {
        //NSLog(@"path :%@",self.imgClient.imgPath);
        [self.detailButton setBackgroundImage:[self.videoManager getThumbnailImageWithEyemoeVideo:[[VideoConfig sharedVideoConfig] myLastEyemoreVideo]] forState:UIControlStateNormal];
        self.detailButton.backgroundColor = [UIColor clearColor];
    }
    else {
        [self.detailButton setBackgroundImage:nil forState:UIControlStateNormal];
        self.detailButton.backgroundColor = [UIColor blackColor];
    }
}

- (void)setUpMenuToolButton
{
    if (self.menuToolButton == nil) {
        
        self.menuToolButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.menuToolButton setFrame:CGRectMake(0, 0, 40, 40)];
        self.menuToolButton.center = CGPointMake(self.view.frame.size.width / 6.5 * 5.5 + 20, self.view.frame.size.height / 10 * 9.4);
        self.menuToolButton.alpha = 1;
        self.menuToolButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.menuToolButton setImage:[UIImage imageNamed:@"menu1"] forState:UIControlStateNormal];
        //    [self.resetButton setTitle:@"默认值" forState:UIControlStateNormal];
        //    self.resetButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        //    self.resetButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        //    self.resetButton.imageEdgeInsets = UIEdgeInsetsMake(-10,0 ,0,0);
        //    self.resetButton.titleEdgeInsets = UIEdgeInsetsMake(50,-42 ,0,0);
        [self.menuToolButton addTarget:self action:@selector(menuToolButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        //[self.view addSubview:self.resetButton];
    }


}
- (void)setUpVolumeButtonHandler
{
    self.volumeButtonHandler = [JPSVolumeButtonHandler volumeButtonHandlerWithUpBlock:^{
        // Volume Up Button Pressed
        NSLog(@"volume up button tapped");
        if (self.shootMode == SYNC_MODE || self.shootMode == LIVEVIEW_MODE) {
            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDRemoteSnapshot(1)];
            self.isExecuteShootTimer = NO;
        }
        
        if (self.debouncingFlag == 0) {
            
            if (self.shootMode == SELFIE_MODE) {
                //[self.selfieTimer invalidate];
                self.isExecuteShootTimer = YES;
                //self.selfieTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(selfieCounter) userInfo:nil repeats:YES];
            }
            self.debouncingFlag = 1;
        }
        
    } downBlock:^{
        // Volume Down Button Pressed
        NSLog(@"volume down button tapped");
        if (self.shootMode == SYNC_MODE || self.shootMode == LIVEVIEW_MODE) {
            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDRemoteSnapshot(1)];
            self.isExecuteShootTimer = NO;
        }
        
        if (self.debouncingFlag == 0) {
            
            if (self.shootMode == SELFIE_MODE) {
                //[self.selfieTimer invalidate];
                self.isExecuteShootTimer = YES;
                //self.selfieTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(selfieCounter) userInfo:nil repeats:YES];
            }
            self.debouncingFlag = 1;
        }
        
    }];
}

- (void)setUpRecordProgressBar
{
    self.recordProgressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 2)];
    
    if (self.isFullScreen) {
        CGAffineTransform at = kLanscapeDirection;
        [self.recordProgressBar setTransform:at];
        self.recordProgressBar.center = CGPointMake(1, self.view.frame.size.height / 2);
        

    }
    self.recordProgressBar.progressViewStyle = UIProgressViewStyleDefault;
    self.recordProgressBar.progressTintColor = [UIColor redColor];
    self.recordProgressBar.trackTintColor    = [UIColor clearColor];
    self.recordProgressBar.progress = 0;
    [self.view addSubview:self.recordProgressBar];
}

- (void)setUpMovieIndicator
{
    if (self.MovieIndicator == nil) {
        self.MovieIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 80, 46)];
        //self.MovieIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        self.MovieIndicator.center = CGPointMake(60, self.bottomBar.center.y);
        self.MovieIndicator.color  = [UIColor redColor];
        self.MovieIndicator.hidesWhenStopped = YES;
        [self.MovieIndicator startAnimating];
    }
    [self.view addSubview:self.MovieIndicator];
}

- (void)setUpRecordLabel
{
    self.recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    self.recordLabel.center = CGPointMake(self.wavePulser.center.x, self.wavePulser.center.y + 15);
    self.recordLabel.textAlignment = NSTextAlignmentCenter;
    self.recordLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20.0];
    self.recordLabel.textColor = [UIColor whiteColor];
    self.recordLabel.text = @"点击下方按钮开始录制";
    [self.view addSubview:self.recordLabel];
}

- (void)setUpShadowWithView:(UIView *)view
{
    //设置阴影
    view.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.8].CGColor;
    view.layer.shadowOffset= CGSizeMake(0, 5);
    view.layer.shadowOpacity = 0.8;
    view.layer.shadowRadius = 5;
}

- (void)setUpFocusingCoordinateView
{
    if (self.focusingCoordinateView == nil) {
        
        self.focusingCoordinateView = [[UIView alloc] initWithFrame:CGRectMake(0, 42, self.view.bounds.size.width, self.view.frame.size.height / 3 * 1 )];
        [self.focusingCoordinateView setUserInteractionEnabled:YES];
        self.focusingCoordinateView.alpha = 1;
        [self.view addSubview:self.focusingCoordinateView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coordinateViewTapped:)];
        tap.numberOfTapsRequired = 1;
        [self.focusingCoordinateView addGestureRecognizer:tap];
        NSLog(@"gesturer : %@", tap);
    }
    [self.view bringSubviewToFront:self.focusingCoordinateView];
}

- (void)setUpFocusingIndicator
{
    if (self.focusingIndicator == nil) {
        self.focusingIndicator = [[BLFocusingIndicator alloc] init];
    }
}

- (void)setUpFilterBar
{
    if (self.filterBar == nil) {
        
        self.filterBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 10 * 1.0 + 20)];
        [self.filterBar setTranslucent:NO];
        self.filterBar.barTintColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
        //self.filterBar.layer.masksToBounds = YES;
        self.filterBar.tintColor = [UIColor whiteColor];
        //[self.view addSubview:self.filterBar];
        
        //    UIImageView *defaultFilterView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height / 10 * 1.0 * 2 - 20, self.view.frame.size.height / 10 * 1.0) ];
        //    defaultFilterView.layer.cornerRadius = 3;
        //    defaultFilterView.layer.masksToBounds = YES;
        //    defaultFilterView.contentMode = UIViewContentModeScaleToFill;
        //    [defaultFilterView setImage:[UIImage imageNamed:@"filterColorful"]];
        
        UIButton *defaultFilter = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 4 * 1.0 - 2, self.view.frame.size.height / 10 * 1.0)];
        defaultFilter.layer.cornerRadius = 3;
        defaultFilter.layer.masksToBounds = YES;
        defaultFilter.imageView.contentMode = UIViewContentModeScaleToFill;
        [defaultFilter setImage:[UIImage imageNamed:@"filterColorful"] forState:UIControlStateNormal];
        defaultFilter.titleLabel.textAlignment = NSTextAlignmentCenter;
        defaultFilter.titleLabel.font = [UIFont systemFontOfSize:13.0];
        //[self setUpShadowWithView: defaultFilter.titleLabel];
        [defaultFilter setTitle:@"标准" forState:UIControlStateNormal];
        defaultFilter.titleEdgeInsets = UIEdgeInsetsMake(30, -480, 0, 0);
        [defaultFilter addTarget:self action:@selector(filterBarItemTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        //    UIImageView *BWFilterView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height / 10 * 1.0 * 2 - 20, self.view.frame.size.height / 10 * 1.0)];
        //    BWFilterView.layer.cornerRadius = 3;
        //    BWFilterView.layer.masksToBounds = YES;
        //    BWFilterView.contentMode = UIViewContentModeScaleToFill;
        //    [BWFilterView setImage:[UIImage imageNamed:@"filterBW"]];
        
        UIButton *BWFilter = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 4 * 1.0 - 2, self.view.frame.size.height / 10 * 1.0)];
        BWFilter.layer.cornerRadius = 3;
        BWFilter.layer.masksToBounds = YES;
        BWFilter.imageView.contentMode = UIViewContentModeScaleToFill;
        [BWFilter setImage:[UIImage imageNamed:@"filterBW"] forState:UIControlStateNormal];
        BWFilter.titleLabel.textAlignment = NSTextAlignmentCenter;
        BWFilter.titleLabel.font = [UIFont systemFontOfSize:13.0];
        //[self setUpShadowWithView: BWFilter.titleLabel];
        [BWFilter setTitle:@"黑白" forState:UIControlStateNormal];
        BWFilter.titleEdgeInsets = UIEdgeInsetsMake(30, -480, 0, 0);
        [BWFilter addTarget:self action:@selector(filterBarItemTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        //    UIImageView *presetFilterView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height / 10 * 1.0 * 2 - 20, self.view.frame.size.height / 10 * 1.0)];
        //    presetFilterView.layer.cornerRadius = 3;
        //    presetFilterView.layer.masksToBounds = YES;
        //    presetFilterView.contentMode = UIViewContentModeScaleToFill;
        //    [presetFilterView setImage:[UIImage imageNamed:@"presetFilterOne"]];
        
        UIButton *presetFilter = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 4 * 1.0 - 2, self.view.frame.size.height / 10 * 1.0)];
        presetFilter.layer.cornerRadius = 3;
        presetFilter.layer.masksToBounds = YES;
        presetFilter.imageView.contentMode = UIViewContentModeScaleToFill;
        [presetFilter setImage:[UIImage imageNamed:@"filterLight"] forState:UIControlStateNormal];
        [presetFilter setBackgroundColor:[UIColor darkGrayColor]];
        presetFilter.titleLabel.textAlignment = NSTextAlignmentCenter;
        presetFilter.titleLabel.font = [UIFont systemFontOfSize:13.0];
        //[presetFilter setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        //[self setUpShadowWithView: presetFilter.titleLabel];
        [presetFilter setTitle:@"质感" forState:UIControlStateNormal];
        presetFilter.titleEdgeInsets = UIEdgeInsetsMake(30, -480, 0, 0);
        [presetFilter addTarget:self action:@selector(filterBarItemTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *presetsSecondFilter = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 4 * 1.0 - 2, self.view.frame.size.height / 10 * 1.0)];
        presetsSecondFilter.layer.cornerRadius = 3;
        presetsSecondFilter.layer.masksToBounds = YES;
        presetsSecondFilter.imageView.contentMode = UIViewContentModeScaleToFill;
        [presetsSecondFilter setImage:[UIImage imageNamed:@"noFilter"] forState:UIControlStateNormal];
        [presetsSecondFilter setBackgroundColor:[UIColor darkGrayColor]];
        presetsSecondFilter.titleLabel.textAlignment = NSTextAlignmentCenter;
        presetsSecondFilter.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [presetsSecondFilter setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self setUpShadowWithView: presetsSecondFilter];
        [presetsSecondFilter setTitle:@"星空" forState:UIControlStateNormal];
        presetsSecondFilter.titleEdgeInsets = UIEdgeInsetsMake(30, -30, 0, 0);
        [presetsSecondFilter addTarget:self action:@selector(filterBarItemTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *fixedCenter = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        //6p,6sp界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 414) {
            fixedCenter.width = - 20;
        }
        //5,5s界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 320) {
            fixedCenter.width = - 15.0;
        }
        //6,6s界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 375) {
            fixedCenter.width = - 18.0;
        }
        UIBarButtonItem *FlexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:defaultFilter];
        UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithCustomView:BWFilter];
        UIBarButtonItem *btn3 = [[UIBarButtonItem alloc] initWithCustomView:presetFilter];
        UIBarButtonItem *btn4 = [[UIBarButtonItem alloc] initWithCustomView:presetsSecondFilter];
        
        NSArray *arr1=[[NSArray alloc]initWithObjects:fixedCenter, btn1, FlexibleSpace, btn3, FlexibleSpace, btn2, FlexibleSpace, btn4, fixedCenter, nil];
        [self.filterBar setItems:arr1 animated:YES];
    }

    //[self.view addSubview:self.filterBar];

}

- (void)setUpSelectedFrameOnView:(UIView *)view
{
    [self.selectedFrame removeFromSuperview];
    if (self.selectedFrame == nil) {
        self.selectedFrame = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 4 * 1.0 - 2, self.view.frame.size.height / 10 * 1.0)];
        [self.selectedFrame.layer setCornerRadius:3];
        [self.selectedFrame.layer setBorderWidth:3];
        [self.selectedFrame.layer setBorderColor:[UIColor redColor].CGColor];
        [self setUpShadowWithView:self.selectedFrame];
        self.selectedFrame.layer.masksToBounds = YES;
        self.selectedFrame.clipsToBounds = YES;
    }
    [view addSubview:self.selectedFrame];
}

- (void)setUpBottomBar
{
    
    if (self.bottomBar == nil) {
        
        //初始化拍照按键
        [self setUpTakePicButton];
        [self setUpTakeButtonBorder];
        //初始化查看照片按钮
        [self setUpDetailButton];
        //初始化reset按钮
        [self setUpMenuToolButton];
        
        UIBarButtonItem *fixedCenter = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        //6p,6sp界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 414) {
            fixedCenter.width = 0;
            //初始化底部工具条
            self.bottomBar = [[CustomedToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height / 10 * 9 - 40, self.view.frame.size.width, self.view.frame.size.height / 10 * 1.0 + 40)];
        }
        //5,5s界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 320) {
            fixedCenter.width = 0;
            //初始化底部工具条
            self.bottomBar = [[CustomedToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height / 10 * 9 - 30, self.view.frame.size.width, self.view.frame.size.height / 10 * 1.0 + 30)];
        }
        //6,6s界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 375) {
            fixedCenter.width = 0;
            //初始化底部工具条
            self.bottomBar = [[CustomedToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height / 10 * 9 - 35, self.view.frame.size.width, self.view.frame.size.height / 10 * 1.0 + 35)];
        }
        
        [self.bottomBar setTranslucent:NO];
        self.bottomBar.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
        //self.filterBar.layer.masksToBounds = YES;
        //[self setUpShadowWithView:self.bottomBar];
        //self.bottomBar.tintColor = [UIColor whiteColor];
        [self.view addSubview:self.bottomBar];
        
        
        UIBarButtonItem *FlexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:self.detailButton];
        UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithCustomView:self.borderButton];
        UIBarButtonItem *btn3 = [[UIBarButtonItem alloc] initWithCustomView:self.menuToolButton];
        btn3.customView.alpha = 0.5;
        NSArray *arr1=[[NSArray alloc]initWithObjects:fixedCenter, btn1, FlexibleSpace, btn2, FlexibleSpace, btn3, fixedCenter, nil];
        [self.bottomBar setItems:arr1 animated:YES];

    }
    
    [self.view addSubview:self.bottomBar];

}

- (void)setUpHideButton
{
    if (self.hideButton == nil) {
        self.hideButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        self.hideButton.center = CGPointMake(20, self.view.frame.size.height / 2);
        self.hideButton.alpha = 0.7;
        self.hideButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self setUpShadowWithView:self.hideButton];
        [self.hideButton setImage:[UIImage imageNamed:@"visibleView"] forState:UIControlStateNormal];
        [self.hideButton addTarget:self action:@selector(updateUIWithHiden) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.hideButton];
        CGAffineTransform at = kLanscapeDirection;
        [self.hideButton setTransform:at];
    }
}

- (void)showCanvasAnimation
{
    
    self.canvas.contentMode = UIViewContentModeScaleAspectFill;
    self.canvas = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default.jpg"]];
    if (self.isFullScreen) {
        CGAffineTransform at = kLanscapeDirection;
        [self.canvas setTransform:at];
        self.canvas.frame = self.view.frame;
        
    }
    else self.canvas.frame = CGRectMake(0, 50, self.view.bounds.size.width, self.view.frame.size.height / 3 * 1 - 15 );
    
    self.canvas.alpha = 0.0;
    [self.view addSubview:self.canvas];
    [BLAnimation revealView:self.canvas WithBLAnimation:BLEffectFadeIn completion:^(BOOL finish){
        [BLAnimation revealView:self.canvas WithBLAnimation:BLEffectFadeOut completion:^(BOOL finish){
            [self.canvas removeFromSuperview];
        }];
    }];
}

- (void)setUpBurstShootingLabelWithCount:(int)count
{
    
    if (self.burstShootingView == nil) {
        self.burstShootingView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        [self.burstShootingView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
        self.burstShootingView.layer.masksToBounds = YES;
        self.burstShootingView.layer.cornerRadius = 40;
        self.burstShootingView.center = CGPointMake(self.bottomBar.center.x, self.bottomBar.center.y - 100);
        self.burstShootingView.text = [NSString stringWithFormat:@"%d", count];
        self.burstShootingView.textAlignment = NSTextAlignmentCenter;
        self.burstShootingView.textColor = [UIColor whiteColor];
        self.burstShootingView.font = [UIFont systemFontOfSize:25.0];
        self.burstShootingView.alpha = 0.0;
        [self.view addSubview:self.burstShootingView];
        [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^(){
            
            self.burstShootingView.alpha = 1.0;
            
        } completion:^(BOOL finished){}];
    }
    else {
        self.burstShootingView.text = [NSString stringWithFormat:@"%d", count];
        [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^(){
            
            self.burstShootingView.alpha = 1.0;
            
        } completion:^(BOOL finished){}];
    }
}

- (void)setUpEVPickerView
{
    self.exposureArray = [NSArray arrayWithObjects:@"-10", @"-9", @"-8", @"-7", @"-6", @"-5", @"-4", @"-3", @"-2", @"-1", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil];
    
    UIView *frame = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 7 * 1 - 5 - 10, self.segment.frame.origin.y + self.segment.frame.size.height + (self.bottomBar.frame.origin.y - (self.segment.frame.origin.y + self.segment.frame.size.height)) / 2 - self.view.frame.size.height / 10, self.view.frame.size.width / 7 + 10, self.view.frame.size.height / 5)];
    frame.layer.masksToBounds = YES;
    frame.layer.cornerRadius = (self.view.frame.size.width / 7 + 10) / 4;
    frame.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.45].CGColor;
    frame.layer.borderWidth = 1.5;
    [self.view addSubview:frame];
    
    self.evLabelCurrent = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.evLabelCurrent setTextColor:[UIColor redColor]];
    self.evLabelCurrent.adjustsFontSizeToFitWidth = YES;
    [self.evLabelCurrent setTextAlignment:NSTextAlignmentCenter];
    [self.evLabelCurrent setBackgroundColor:[UIColor clearColor]];
    [self.evLabelCurrent setFont:[UIFont fontWithName:@"Trebuchet MS" size:35]];
    [self.evLabelCurrent setText:self.exposureArray[0]];
    //[self.evLabelCurrent setTextColor:[UIColor lightGrayColor]];
    self.evLabelCurrent.center = CGPointMake(frame.frame.size.width / 2 , 35 );
    [frame addSubview:self.evLabelCurrent];
    
    UILabel *pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [pickerLabel setTextColor:[UIColor whiteColor]];
    pickerLabel.adjustsFontSizeToFitWidth = YES;
    [pickerLabel setTextAlignment:NSTextAlignmentCenter];
    [pickerLabel setBackgroundColor:[UIColor clearColor]];
    [pickerLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:25]];
    [pickerLabel setText:@"EV"];
    [pickerLabel setTextColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5]];
    pickerLabel.center = CGPointMake(frame.frame.size.width / 2 , frame.frame.size.height - 35 );
    [frame addSubview:pickerLabel];

    self.evRocker = [[BLRocker alloc] initWithFrame:frame.frame handleView:frame];
    self.evRocker.delegate = self;
    [self.view addSubview:self.evRocker];
    
    UIImage *upShapeImage = [UIImage imageNamed:@"shapes_gray-up"];
    UIImageView *upShape = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    upShape.image = upShapeImage;
    upShape.center = CGPointMake(self.evRocker.center.x, self.evRocker.frame.origin.y - 30);
    [self.view addSubview:upShape];
    
    UIImage *downShapeImage = [UIImage imageNamed:@"shapes_gray-down"];
    UIImageView *downShape = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    downShape.image = downShapeImage;
    downShape.center = CGPointMake(self.evRocker.center.x, self.evRocker.frame.origin.y + self.evRocker.frame.size.height + 30);
    [self.view addSubview:downShape];
    
    //6p,6sp界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 414) {
        [self.evLabelCurrent setFont:[UIFont fontWithName:@"Trebuchet MS" size:35]];
        [pickerLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:25]];
        upShape.center = CGPointMake(self.evRocker.center.x, self.evRocker.frame.origin.y - 15);
        downShape.center = CGPointMake(self.evRocker.center.x, self.evRocker.frame.origin.y + self.evRocker.frame.size.height + 20);
        
    }
    //5,5s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 320) {
        [self.evLabelCurrent setFont:[UIFont fontWithName:@"Trebuchet MS" size:25]];
        [pickerLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:20]];
        upShape.center = CGPointMake(self.evRocker.center.x, self.evRocker.frame.origin.y - 10);
        downShape.center = CGPointMake(self.evRocker.center.x, self.evRocker.frame.origin.y + self.evRocker.frame.size.height + 10);
    }
    //6,6s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 375) {
        [self.evLabelCurrent setFont:[UIFont fontWithName:@"Trebuchet MS" size:30]];
        [pickerLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:25]];
        upShape.center = CGPointMake(self.evRocker.center.x, self.evRocker.frame.origin.y - 15);
        downShape.center = CGPointMake(self.evRocker.center.x, self.evRocker.frame.origin.y + self.evRocker.frame.size.height + 20);
        
    }
    
}

- (void)setUpShutterPickerView
{
    self.shutterArray =[NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", nil];
    
    UIView *frame = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 7 * 3 - 5, self.segment.frame.origin.y + self.segment.frame.size.height + (self.bottomBar.frame.origin.y - (self.segment.frame.origin.y + self.segment.frame.size.height)) / 2 - self.view.frame.size.height / 10 - 5 , self.view.frame.size.width / 7 + 10, self.view.frame.size.height / 5)];
    frame.layer.masksToBounds = YES;
    frame.layer.cornerRadius = (self.view.frame.size.width / 7 + 10) / 4;
    frame.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.45].CGColor;
    frame.layer.borderWidth = 1.5;
    [self.view addSubview:frame];
    
    self.shutterLabelCurrent = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.shutterLabelCurrent setTextColor:[UIColor redColor]];
    self.shutterLabelCurrent.adjustsFontSizeToFitWidth = YES;
    [self.shutterLabelCurrent setTextAlignment:NSTextAlignmentCenter];
    [self.shutterLabelCurrent setBackgroundColor:[UIColor clearColor]];
    [self.shutterLabelCurrent setFont:[UIFont fontWithName:@"Trebuchet MS" size:35]];
    [self.shutterLabelCurrent setText:self.shutterArray[0]];
    //[self.shutterLabelCurrent setTextColor:[UIColor lightGrayColor]];
    self.shutterLabelCurrent.center = CGPointMake(frame.frame.size.width / 2 , 35 );
    [frame addSubview:self.shutterLabelCurrent];

    
    UILabel *pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [pickerLabel setTextColor:[UIColor whiteColor]];
    pickerLabel.adjustsFontSizeToFitWidth = YES;
    [pickerLabel setTextAlignment:NSTextAlignmentCenter];
    [pickerLabel setBackgroundColor:[UIColor clearColor]];
    [pickerLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:25]];
    [pickerLabel setText:@"S"];
    [pickerLabel setTextColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5]];
    pickerLabel.center = CGPointMake(frame.frame.size.width / 2 , frame.frame.size.height - 30 );
    [frame addSubview:pickerLabel];

    self.shutterRocker = [[BLRocker alloc] initWithFrame:frame.frame handleView:frame];
    self.shutterRocker.delegate = self;
    [self.view addSubview:self.shutterRocker];
    
    UIImage *upShapeImage = [UIImage imageNamed:@"shapes_gray-up"];
    UIImageView *upShape = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    upShape.image = upShapeImage;
    upShape.center = CGPointMake(self.shutterRocker.center.x, self.shutterRocker.frame.origin.y - 30);
    [self.view addSubview:upShape];
    
    UIImage *downShapeImage = [UIImage imageNamed:@"shapes_gray-down"];
    UIImageView *downShape = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    downShape.image = downShapeImage;
    downShape.center = CGPointMake(self.shutterRocker.center.x, self.shutterRocker.frame.origin.y + self.shutterRocker.frame.size.height + 30);
    [self.view addSubview:downShape];
    
    //6p,6sp界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 414) {
        [self.shutterLabelCurrent setFont:[UIFont fontWithName:@"Trebuchet MS" size:35]];
        [pickerLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:25]];
        upShape.center = CGPointMake(self.shutterRocker.center.x, self.shutterRocker.frame.origin.y - 15);
        downShape.center = CGPointMake(self.shutterRocker.center.x, self.shutterRocker.frame.origin.y + self.shutterRocker.frame.size.height + 20);
        
    }
    //5,5s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 320) {
        [self.shutterLabelCurrent setFont:[UIFont fontWithName:@"Trebuchet MS" size:25]];
        [pickerLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:20]];
        upShape.center = CGPointMake(self.shutterRocker.center.x, self.shutterRocker.frame.origin.y - 10);
        downShape.center = CGPointMake(self.shutterRocker.center.x, self.shutterRocker.frame.origin.y + self.shutterRocker.frame.size.height + 10);
    }
    //6,6s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 375) {
        [self.shutterLabelCurrent setFont:[UIFont fontWithName:@"Trebuchet MS" size:30]];
        [pickerLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:25]];
        upShape.center = CGPointMake(self.shutterRocker.center.x, self.shutterRocker.frame.origin.y - 15);
        downShape.center = CGPointMake(self.shutterRocker.center.x, self.shutterRocker.frame.origin.y + self.shutterRocker.frame.size.height + 20);
        
    }
}

- (void)setUpIrisPickerView
{
    self.irisDisplayArray =[NSArray arrayWithObjects:@"-6", @"-5", @"-4", @"-3", @"-2", @"-1", @"0", nil];
    
    UIView *frame = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 7 * 5 - 5 + 10, self.segment.frame.origin.y + self.segment.frame.size.height + (self.bottomBar.frame.origin.y - (self.segment.frame.origin.y + self.segment.frame.size.height)) / 2 - self.view.frame.size.height / 10 , self.view.frame.size.width / 7 + 10, self.view.frame.size.height / 5)];
    frame.layer.masksToBounds = YES;
    frame.layer.cornerRadius = (self.view.frame.size.width / 7 + 10) / 4;
    frame.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.45].CGColor;
    frame.layer.borderWidth = 1.5;
    [self.view addSubview:frame];
    
    self.irisLabelCurrent = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.irisLabelCurrent setTextColor:[UIColor redColor]];
    self.irisLabelCurrent.adjustsFontSizeToFitWidth = YES;
    [self.irisLabelCurrent setTextAlignment:NSTextAlignmentCenter];
    [self.irisLabelCurrent setBackgroundColor:[UIColor clearColor]];
    [self.irisLabelCurrent setFont:[UIFont fontWithName:@"Trebuchet MS" size:35]];
    [self.irisLabelCurrent setText:self.irisDisplayArray[0]];
    //[self.irisLabelCurrent setTextColor:[UIColor lightGrayColor]];
    self.irisLabelCurrent.center = CGPointMake(frame.frame.size.width / 2 , 35 );
    [frame addSubview:self.irisLabelCurrent];
    
    UILabel *pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [pickerLabel setTextColor:[UIColor whiteColor]];
    pickerLabel.adjustsFontSizeToFitWidth = YES;
    [pickerLabel setTextAlignment:NSTextAlignmentCenter];
    [pickerLabel setBackgroundColor:[UIColor clearColor]];
    [pickerLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:25]];
    [pickerLabel setText:@"A"];
    [pickerLabel setTextColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5]];
    pickerLabel.center = CGPointMake(frame.frame.size.width / 2 , frame.frame.size.height - 30 );
    [frame addSubview:pickerLabel];
    
    self.irisRocker = [[BLRocker alloc] initWithFrame:frame.frame handleView:frame];
    self.irisRocker.delegate = self;
    [self.view addSubview:self.irisRocker];
    
    UIImage *upShapeImage = [UIImage imageNamed:@"shapes_gray-up"];
    UIImageView *upShape = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    upShape.image = upShapeImage;
    [self.view addSubview:upShape];
    
    UIImage *downShapeImage = [UIImage imageNamed:@"shapes_gray-down"];
    UIImageView *downShape = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    downShape.image = downShapeImage;
    [self.view addSubview:downShape];
    
    //6p,6sp界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 414) {
        [self.irisLabelCurrent setFont:[UIFont fontWithName:@"Trebuchet MS" size:35]];
        [pickerLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:25]];
        upShape.center = CGPointMake(self.irisRocker.center.x, self.irisRocker.frame.origin.y - 15);
        downShape.center = CGPointMake(self.irisRocker.center.x, self.irisRocker.frame.origin.y + self.irisRocker.frame.size.height + 20);

    }
    //5,5s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 320) {
        [self.irisLabelCurrent setFont:[UIFont fontWithName:@"Trebuchet MS" size:25]];
        [pickerLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:20]];
        upShape.center = CGPointMake(self.irisRocker.center.x, self.irisRocker.frame.origin.y - 10);
        downShape.center = CGPointMake(self.irisRocker.center.x, self.irisRocker.frame.origin.y + self.irisRocker.frame.size.height + 10);
    }
    //6,6s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 375) {
        [self.irisLabelCurrent setFont:[UIFont fontWithName:@"Trebuchet MS" size:30]];
        [pickerLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:25]];
        upShape.center = CGPointMake(self.irisRocker.center.x, self.irisRocker.frame.origin.y - 15);
        downShape.center = CGPointMake(self.irisRocker.center.x, self.irisRocker.frame.origin.y + self.irisRocker.frame.size.height + 20);

    }
}

- (void)setUpExtendToolView
{
    if (self.extendToolView == nil) {
        
        self.extendToolView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bottomBar.frame.origin.y, self.view.frame.size.width, 360)];
        self.extendToolView.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
        [self setUpFilterBar];
        //[self setUpExtendToolBar1];
        [self.extendToolView addSubview:self.filterBar];
        //[self.extendToolView addSubview:self.extendBar1];
       
    }
    [self.view bringSubviewToFront:self.bottomBar];
    [self.view insertSubview:self.extendToolView belowSubview:self.bottomBar];
}


- (void)setUpResetButton
{
    self.resetButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 10, self.bottomBar.frame.origin.y - 25, 20, 20)];
    self.resetButton.layer.masksToBounds = YES;
    self.resetButton.layer.cornerRadius = 10;
    self.resetButton.backgroundColor = [UIColor whiteColor];
    [self.resetButton setTintColor:[UIColor redColor]];
    [self.resetButton setTitleColor:[UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1] forState:UIControlStateNormal];
    [self.resetButton setTitle:@"R" forState:UIControlStateNormal];
    [self.resetButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.resetButton addTarget:self action:@selector(resetButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resetButton];
}

- (void)setUpExtendToolBar1
{
    if (self.extendBar1 == nil) {
        
        self.extendBar1 = [[CustomedToolBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
        [self.extendBar1 setTranslucent:NO];
        self.extendBar1.barTintColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
        self.extendBar1.tintColor = [UIColor whiteColor];
        
        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 35)];
        button1.layer.masksToBounds = YES;
        button1.layer.cornerRadius = 8;
        //button1.layer.borderColor = [UIColor grayColor].CGColor;
        //button1.layer.borderWidth = 1.5;
        button1.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1];;
        [button1 setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [button1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button1 setTitle:@"重置EVSA" forState:UIControlStateNormal];
        [button1.titleLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:12]];
        [button1 setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        button1.tag = 1;
        [button1 addTarget:self action:@selector(extendBar1ItemTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
        button2.layer.masksToBounds = YES;
        button2.layer.cornerRadius = 8;
//        button2.layer.borderColor = [UIColor grayColor].CGColor;
//        button2.layer.borderWidth = 1.5;
        
        if ([CameraConfiguration loadSmartBurstConfig]) {
            [button2 setTitleColor:[UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1] forState:UIControlStateNormal];
            [button2 setBackgroundColor:[UIColor redColor]];
            remoteNumber = 3;
        }
        else {
            button2.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1];;
            [button2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            remoteNumber = 1;
        }
        [button2 setTintColor:[UIColor redColor]];
        [button2 setTitle:@"智拍3张" forState:UIControlStateNormal];
        [button2.titleLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:15]];
        [button2 setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        button2.tag = 2;
        [button2 addTarget:self action:@selector(extendBar1ItemTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
        button3.layer.masksToBounds = YES;
        button3.layer.cornerRadius = 8;
        //        button2.layer.borderColor = [UIColor grayColor].CGColor;
        //        button2.layer.borderWidth = 1.5;
        button3.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1];;
        [button3 setTintColor:[UIColor redColor]];
        [button3 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button3 setTitle:@"半帧视频" forState:UIControlStateNormal];
        [button3.titleLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:15]];
        [button3 setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        button3.tag = 3;
        [button3 addTarget:self action:@selector(extendBar1ItemTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *fixedCenter = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        //6p,6sp界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 414) {
            fixedCenter.width = - 20;
        }
        //5,5s界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 320) {
            fixedCenter.width = - 15.0;
        }
        //6,6s界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 375) {
            fixedCenter.width = - 18.0;
        }
        UIBarButtonItem *FlexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:button1];
        UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithCustomView:button2];
        UIBarButtonItem *btn3 = [[UIBarButtonItem alloc] initWithCustomView:button3];
        
        NSArray *arr1=[[NSArray alloc]initWithObjects:FlexibleSpace, btn1, FlexibleSpace, btn2, FlexibleSpace, btn3, FlexibleSpace, nil];
        [self.extendBar1 setItems:arr1 animated:YES];
    }
    
    //[self.view addSubview:self.filterBar];

}

- (void)showCanvas
{
    
    self.canvas.contentMode = UIViewContentModeScaleAspectFit;
    self.canvas = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default.jpg"]];
    if (self.isFullScreen) {
        CGAffineTransform at = kLanscapeDirection;
        [self.canvas setTransform:at];
        self.canvas.frame = self.view.frame;
        
    }
    else self.canvas.frame = CGRectMake(0, 50, self.view.bounds.size.width, self.view.frame.size.height / 3 * 1 - 17 );
    
    self.canvas.alpha = 0.0;
    [self.view addSubview:self.canvas];
    [BLAnimation revealView:self.canvas WithBLAnimation:BLEffectFadeIn completion:^(BOOL finish){
        [self setUpRecordLabel];
    }];
}
- (void)hideCanvas
{
    [BLAnimation revealView:self.liveView WithBLAnimation:BLEffectFadeOut completion:^(BOOL finish){
        [self.canvas removeFromSuperview];
        [self unSetUpRecordLabel];
         //[self performSelectorOnMainThread:selector withObject:nil waitUntilDone:nil];
    }];
}

//- (void)popingLinkLabel
//{
//    [self.view addSubview:self.popLinkLabel];
//    [self.popLinkLabel popAtView:self.wavePulser];
//}

- (void)showLiveViewWindow
{
    if (self.liveView == nil) {
        self.liveViewRecorder = [LiveViewRecorder sharedLiveViewRecorder];
        self.liveViewRecorder.delegate = self;
        self.liveView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 42, self.view.bounds.size.width, self.view.frame.size.height / 3 * 1 )];
        self.liveView.contentMode = UIViewContentModeScaleAspectFit;
        [self.liveView setImage:[UIImage imageNamed:@"default.jpg"]];
        self.liveView.alpha = 0.0;
        
        UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateUIWithHiden)];
        tapped.numberOfTapsRequired = 1;
        tapped.numberOfTouchesRequired = 1;
        [self.liveView addGestureRecognizer:tapped];
        [self.liveView setUserInteractionEnabled:NO];
    }
    [self.view addSubview:self.liveView];
    [BLAnimation revealView:self.liveView WithBLAnimation:BLEffectFadeIn completion:^(BOOL finish){
        [self.liveViewRecorder startLiveViewing];
    }];
}

- (void)hideLiveWindow
{
    [BLAnimation revealView:self.liveView WithBLAnimation:BLEffectFadeOut completion:^(BOOL finish){
        [self.liveView removeFromSuperview];
        //[self hideCanvas:nil];
    }];
}

- (void)unSetUpTakeButton
{
    [self.takeButton removeFromSuperview];
    self.takeButton = nil;
}

- (void)unSetUpRecordButton
{
    [self.takeButton removeTarget:self action:@selector(recordButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.takeButton addTarget:self action:@selector(takePicButtonTappedUp) forControlEvents:UIControlEventTouchUpInside];
    [self.takeButton addTarget:self action:@selector(takePicButtonTappedDown) forControlEvents:UIControlEventTouchDown];
    [UIView animateWithDuration:0.2f
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^(){self.takeButton.foregroundColor = [UIColor whiteColor];}
                     completion:^(BOOL finish){
                         self.takeButton.foregroundAnimateToColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
                     }];
}

- (void)unSetUpMovieDetailButton
{
    [self.detailButton removeTarget:self action:@selector(MovieDetailButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.detailButton addTarget:self action:@selector(showImage) forControlEvents:UIControlEventTouchUpInside];
    [self.detailButton setBackgroundImage:nil forState:UIControlStateNormal];
    if (self.imgClient.imgPath.count != 0) {
        NSLog(@"path :%@",self.imgClient.imgPath);
        [self.detailButton setImage:[self.imgClient getImageForKey:[self.imgClient.imgPath lastObject]] forState:UIControlStateNormal];
        self.detailButton.backgroundColor = [UIColor clearColor];
    }
    else {
        [self.detailButton setImage:nil forState:UIControlStateNormal];
        self.detailButton.backgroundColor = [UIColor blackColor];
    }
}

- (void)unSetUpRecordProgressBar
{
    [self.recordProgressBar removeFromSuperview ];
    self.recordProgressBar = nil;
}

- (void)unSetUpMovieIndicator
{
    [self.MovieIndicator stopAnimating];
    [self.MovieIndicator removeFromSuperview];
    self.MovieIndicator = nil;
}

- (void)unSetUpRecordLabel
{
    [self.recordLabel removeFromSuperview];
    self.recordLabel = nil;
}

- (void)unSetUpFocusingCoordinateView
{
    [self.focusingCoordinateView removeFromSuperview];
    self.focusingCoordinateView = nil;
}

- (void)unSetUpHideButton
{
    [self.hideButton removeFromSuperview];
    self.hideButton = nil;
}

- (void)unSetUpBurstShootingViewWithCount:(int)count
{
    self.burstShootingView.text = [NSString stringWithFormat:@"%d", count];
    [UIView animateWithDuration:0.3f delay:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^(){
        self.burstShootingView.alpha = 0.0;
    } completion:^(BOOL finished){
        [self.burstShootingView removeFromSuperview];
        self.burstShootingView = nil;
    }];
}

- (void)unSetUpExtendToolView
{
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^(){
        self.extendToolView.alpha = 0.0;
    } completion:^(BOOL finished){
        [self.extendToolView removeFromSuperview];
        self.extendToolView = nil;
    }];
}

//- (void)unSetUpReloadButton
//{
//    if (self.reloadButton != nil) {
//        [self.reloadButton removeFromSuperview];
//        self.reloadButton = nil;
//    }
//}

#pragma mark - UI freshing

- (void)updateUIWithLensParam:(LENS_PARAMS)status
{
    
    NSLog(@"status.current_exposure_value %d", status.current_exposure_value);
    if (status.current_exposure_value != 22) {
        
        [self.exposurevValueFilter setSelectedIndex:[self convertToExposureIndexWithValue:status.current_exposure_value] animated:YES];
        self.exposureSlider.selectedMaximum = [self convertToExposureIndexWithValue:status.current_exposure_value];
        
        self.evLabelCurrent.text = [NSString stringWithFormat:@"%d", [self convertToExposureIndexWithValue:status.current_exposure_value]];
    }
    if (status.current_shutter_value) {
        [self.shutterFilter setSelectedIndex:[self convertToShutterIndexWithValue:status.current_shutter_value] animated:YES];
        self.shutterSlider.selectedMaximum = [self convertToShutterIndexWithValue:status.current_shutter_value];
        self.shutterLabelCurrent.text = [NSString stringWithFormat:@"%d", [self convertToShutterIndexWithValue:status.current_shutter_value]];
    }
    if (self.irisArray) {
        [self.irisFilter setSelectedIndex:[self convertToIRISIndexWithValue:status.current_iris_value] animated:YES];
        self.irisSlider.selectedMaximum = [self convertToIRISIndexWithValue:status.current_iris_value];
        self.irisLabelCurrent.text = [NSString stringWithFormat:@"%d", [self convertToIRISIndexWithValue:status.current_iris_value]];
    }
    else {
        
        [self.irisFilter setEnabled:NO];
        self.irisFilter.alpha = 0.6;
    }
}

- (void)updateUIWithoutConnection
{
    //刷新照片缩略图显示

    if (self.shootMode == LIVEVIEW_MODE || self.shootMode == SYNCMODE || self.shootMode == SELFIE_MODE) {
        if (self.imgClient.imgPath.count != 0) {
            [self.detailButton setImage:[self.imgClient getImageForKey:[self.imgClient.imgPath lastObject]] forState:UIControlStateNormal];
            self.detailButton.backgroundColor = [UIColor clearColor];
        }
        else {
            [self.detailButton setImage:nil forState:UIControlStateNormal];
            self.detailButton.backgroundColor = [UIColor blackColor];
        }
    }
    if (self.shootMode == RECORDING_MOVIE_MODE) {
        if ([[VideoConfig sharedVideoConfig] myEyemoreVideos]!= 0) {
             [self.detailButton setBackgroundImage:[self.videoManager getThumbnailImageWithEyemoeVideo:[[VideoConfig sharedVideoConfig] myLastEyemoreVideo]] forState:UIControlStateNormal];
            self.detailButton.backgroundColor = [UIColor clearColor];
        }
        else {
            [self.detailButton setBackgroundImage:nil forState:UIControlStateNormal];
            self.detailButton.backgroundColor = [UIColor blackColor];
        }
    }
    
}

- (void)updateUIWithMode:(SHOOTMODE)mode
{
    if (mode == SYNC_MODE ) {
        
        [self unSetUpRecordButton];
        [self unSetUpRecordProgressBar];
        [self unSetUpMovieDetailButton];
        [self unSetUpFocusingCoordinateView];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToDDR];
    }
    
    if (mode == LIVEVIEW_MODE || mode == SELFIE_MODE) {
        
        [self unSetUpRecordButton];
        [self unSetUpRecordProgressBar];
        [self unSetUpMovieDetailButton];
        [self setUpFocusingCoordinateView];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToDDR];
    }
    
    if (mode == RECORDING_MOVIE_MODE) {
        
        [self setUpRecordButton];
        [self setUpMovieDetailButton];
        [self setUpFocusingCoordinateView];
        [self unSetUpRecordLabel];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
    }
    
    if (mode == HD_RECORDING_MODE) {
        
        [self setUpRecordButton];
        [self setUpMovieDetailButton];
        [self setUpFocusingCoordinateView];
        
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
    }
}

- (void)updateUIToolBarWithMode:(SHOOTMODE)mode
{
    if (mode == SYNC_MODE || mode == HD_RECORDING_MODE) {
        [self.fullScreenButton setEnabled:NO];
    }
    if (mode == LIVEVIEW_MODE || mode == RECORDING_MOVIE_MODE) {
        [self.fullScreenButton setEnabled:YES];
    }
}

- (void)updateUIButton:(MRoundedButton *)button withTapped:(BOOL)isTapped
{
    if (isTapped) {
        [button  setSelected:YES];
        [button setUserInteractionEnabled:NO];
    }
    else {
        [button setSelected:NO];
        [button setUserInteractionEnabled:YES];
    }
    //按键按下3秒超时复位
//    if (self.shootMode == SYNCMODE || self.shootMode == LIVEVIEW_MODE) {
//        [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(resetUpdateUIButton) userInfo:nil repeats:NO];
//    }
}

- (void)updateUIButton:(MRoundedButton *)button withRecorded:(BOOL)isRecorded
{
    if (isRecorded) {
        [button setSelected:YES];
        [button setBackgroundColor:[UIColor colorWithRed:255/255.0 green:0/255.0 blue:0 /255.0 alpha:1]];
    }
    else {
        [button setSelected:NO];
        [button setBackgroundColor:[UIColor clearColor]];

    }
    CGAffineTransform scale;;
    if (isRecorded) {
        scale = CGAffineTransformMakeScale(0.7, 0.7);
    }
    else {
        scale = CGAffineTransformMakeScale(1, 1);
    }

    [UIView animateWithDuration:0.4f animations:^(){
        [button setTransform:scale];
    }];
}

- (void)resetUpdateUIButton
{
    [self updateUIButton:self.takeButton withTapped:NO];
}

- (void)updateUIWithLanscape
{
    [UIView animateWithDuration:0.2f
                          delay:0.1f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         
                         CGAffineTransform at = kLanscapeDirection;
                         //[self.toolBar setTransform:at];
                         //self.toolBar.center = CGPointMake(26, self.view.frame.size.height / 2);
                         [self.fullScreenButton setImage:[UIImage imageNamed:@"originalScreen.png"]];
                         self.toolBar.alpha = 1;
                         self.toolBar.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:0.3];
                         self.bottomBar.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:0.3];
                         
                         [self.liveView setTransform:at];
                         self.liveView.center = self.view.center;
                         self.liveView.frame = self.view.frame;
                         self.liveView.alpha = 1;
                         
                         [self.focusingIndicator setTransform:at];
                         [self.focusingCoordinateView setTransform:at];
                         self.focusingCoordinateView.center = self.view.center;
                         self.focusingCoordinateView.frame = self.view.frame;
                         
                         //self.detailButton.center = CGPointMake(self.view.frame.size.width / 6.5 * 1, self.view.frame.size.height / 10 * 9.2);
                         [self.detailButton setTransform:at];
                         self.detailButton.alpha = 1;
                         [self.menuToolButton setTransform:at];
                         self.menuToolButton.alpha = 1;
                         //self.borderButton.alpha = 1;
                         self.takeButton.alpha = 1;
                         
                         //[self.view bringSubviewToFront:self.detailButton];
                         //[self.view bringSubviewToFront:self.resetButton];
                         [self.view bringSubviewToFront:self.borderButton];
                         //[self.view bringSubviewToFront:self.takeButton];
                         [self.view bringSubviewToFront:self.toolBar];
                         [self.view bringSubviewToFront:self.bottomBar];
                         
                     }
                     completion:^(BOOL finished){
                         self.isFullScreen = YES;
                         [self.liveView setUserInteractionEnabled:YES];
                         if (self.shootMode == LIVEVIEW_MODE) {
                             //[self updateUIWithHiden];
                         }
                         [self setUpHideButton];
                     }];
}

- (void)updateUIWithPortait
{
    
    [UIView animateWithDuration:0.2f
                          delay:0.1f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(){
                         
                         CGAffineTransform at = kPortraitDirection;
                         //[self.toolBar setTransform:at];
                         //self.toolBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 52);
                         [self.fullScreenButton setImage:[UIImage imageNamed:@"fullScreen.png"]];
                         self.toolBar.alpha = 1;
                         self.toolBar.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1];
                         self.bottomBar.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
                         
                         [self.liveView setTransform:at];
                         self.liveView.center = self.view.center;
                         self.liveView.frame = CGRectMake(0, 42, self.view.bounds.size.width, self.view.frame.size.height / 3 * 1 );
                         self.liveView.alpha = 1;
                         
                         [self.focusingIndicator setTransform:at];
                         [self.focusingCoordinateView setTransform:at];
                         self.focusingCoordinateView.center = self.view.center;
                         self.focusingCoordinateView.frame = CGRectMake(0, 42, self.view.bounds.size.width, self.view.frame.size.height / 3 * 1 );

                         //self.detailButton.center = CGPointMake(self.view.frame.size.width / 6.5 * 1, self.view.frame.size.height / 10 * 9.4);
                         [self.detailButton setTransform:at];
                         self.detailButton.alpha = 1;
                         
                         [self.menuToolButton setTransform:at];
                         self.menuToolButton.alpha = 1;
                         
                         //self.borderButton.alpha = 1;
                         self.takeButton.alpha = 1;
                         
                         //[self.view bringSubviewToFront:self.detailButton];
                         //[self.view bringSubviewToFront:self.resetButton];
                         [self.view bringSubviewToFront:self.borderButton];
                         //[self.view bringSubviewToFront:self.takeButton];
                         [self.view bringSubviewToFront:self.toolBar];
                         [self.view bringSubviewToFront:self.bottomBar];
                         
                     }
                     completion:^(BOOL finished){
                         self.isFullScreen = NO;
                         [self.liveView setUserInteractionEnabled:NO];
                         [self unSetUpHideButton];
                     }];
    
}

- (void)updateUIWithHiden
{
    static BOOL isHiden = YES;
    if (isHiden) {
        [UIView animateWithDuration:0.3f
                              delay:0.1f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(){
                             self.toolBar.alpha = 0;
                             //self.detailButton.alpha = 0;
                             //self.borderButton.alpha = 0;
                             //self.takeButton.alpha = 0;
                             //self.resetButton.alpha = 0;
                             self.bottomBar.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             
                             [self.toolBar setHidden:YES];
                             //[self.detailButton  setHidden:YES];
                             //[self.borderButton setHidden:YES];
                             //[self.takeButton setHidden:YES];
                             //[self.resetButton setHidden:YES];
                             [self.bottomBar setHidden:YES];
                             [self.takeButton setEnabled:NO];
                             
                             [self.hideButton setImage:[UIImage imageNamed:@"invisibleView"] forState:UIControlStateNormal];
        }];
        isHiden = NO;
    }
    else {
        
        [self.toolBar setHidden:NO];
        //[self.detailButton  setHidden:NO];
        //[self.borderButton setHidden:NO];
        //[self.takeButton setHidden:NO];
        //[self.resetButton setHidden:NO];
        [self.bottomBar setHidden:NO];
        
        [UIView animateWithDuration:0.3f
                              delay:0.1f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(){
                             self.toolBar.alpha = 1;
                             //self.detailButton.alpha = 1;
                             self.borderButton.alpha = 1;
                             //self.takeButton.alpha = 1;
                             //self.resetButton.alpha = 1;
                             self.bottomBar.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             [self.takeButton setEnabled:YES];
                             [self.hideButton setImage:[UIImage imageNamed:@"visibleView"] forState:UIControlStateNormal];
                         }];
        isHiden = YES;
    }
}

- (void)updateRecordProgressBarToColor:(UIColor *)color
{
    self.recordProgressBar.progressTintColor = color;
    self.recordProgressBar.progress = 0;
}

- (void)startRecordAutoProgressing
{
    [self.recordAutoProgressTimer invalidate];
    self.recordAutoProgressTimer = nil;
    self.recordAutoProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(setRecordProgressBarProgress) userInfo:nil repeats:YES];
}

- (void)setRecordProgressBarProgress
{
    NSLog(@"hd recording progress bar is processing");
    static float value = 0;
    if (self.takeButton.isSelected == NO) {
        value = 0;
    }
    [self.recordProgressBar setProgress:value animated:YES];
    if (self.shootMode == HD_RECORDING_MODE) {
        value += 0.0033;
    }
    else {
        value += 0.0033;
    }
    if (value >= 0.99) {
        
        if (self.shootMode == HD_RECORDING_MODE) {
            //[self stopRecording];
        }
        [self stopRecording];
        self.recordLabel.text = @"录制完成...";
        [self updateRecordProgressBarToColor:[UIColor greenColor]];
        value = 0;
    }
}

- (void)stopRecording
{
    [self.videoRecorder endRecording];
    //[self updateUIButton:self.takeButton withTapped:NO];
    [self.recordAutoProgressTimer invalidate];
    self.recordAutoProgressTimer = nil;
    //update ui state
    
    [self updateUIButton:self.takeButton withRecorded:NO];
    [self updateRecordProgressBarToColor:[UIColor redColor]];
    [self showCanvasAnimation];
    [self unSetUpRecordProgressBar];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EyemoreVideosUpdated" object:nil];
}
#pragma mark - Rotation Setting

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {

    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Focusing Position Transfer

- (CGPoint)transferPositionTo1080pWithPoint:(CGPoint)pos
{
    CGPoint transferedPos;
    if (self.isFullScreen) {
        
        transferedPos.x = 1080 / self.focusingCoordinateView.frame.size.width * pos.x;
        transferedPos.y = 1920 / self.focusingCoordinateView.frame.size.height * pos.y;
    }
    else {
        transferedPos.x = 1920 / self.focusingCoordinateView.frame.size.width * pos.x;
        transferedPos.y = 1080 / self.focusingCoordinateView.frame.size.height * pos.y;
    }
    return transferedPos;
}

#pragma mark - Converting value

- (LENS_EXPOSURE_VALUE)convertToExposureValueWithIndex:(  signed int)index
{
    switch (index) {
            //        case 0:
            //            return EVN3P0;
            //            break;
            //        case 1:
            //            return EVN2P0;
            //            break;
            //        case 2:
            //            return EVN1P0;
            //            break;
            //        case 3:
            //            return EVP0P0;
            //            break;
            //        case 4:
            //            return EVP1P0;
            //            break;
            //        case 5:
            //            return EVP2P0;
            //            break;
            //        case 6:
            //            return EVP3P0;
            //            break;
            //
            //        default:
            //            return 0;
            //            break;
        case -10:
            return EVN10P0;
            break;
        case -9:
            return EVN9P0;
            break;
        case -8:
            return EVN8P0;
            break;
        case -7:
            return EVN7P0;
            break;
        case -6:
            return EVN6P0;
            break;
        case -5:
            return EVN5P0;
            break;
        case -4:
            return EVN4P0;
            break;
        case -3:
            return EVN3P0;
            break;
        case -2:
            return EVN2P0;
            break;
        case -1:
            return EVN1P0;
            break;
        case 0:
            return EVP0P0;
            break;
        case 1:
            return EVP1P0;
            break;
        case 2:
            return EVP2P0;
            break;
        case 3:
            return EVP3P0;
            break;
        case 4:
            return EVP4P0;
            break;
        case 5:
            return EVP5P0;
            break;
        case 6:
            return EVP6P0;
            break;
        case 7:
            return EVP7P0;
            break;
        case 8:
            return EVP8P0;
            break;
        case 9:
            return EVP9P0;
            break;
        case 10:
            return EVP10P0;
            break;
            
        default:
            return 22;
            break;
    }
}

- (LENS_SHUTTER_VALUE)convertToShutterValueWithIndex:(int)index
{
    switch (index) {
        case 0:
            return SHUTTER_1_25;
            break;
        case 1:
            return SHUTTER_1_50;
            break;
        case 2:
            return SHUTTER_1_100;
            break;
        case 3:
            return SHUTTER_1_150;
            break;
        case 4:
            return SHUTTER_1_200;
            break;
        case 5:
            return SHUTTER_1_500;
            break;
        case 6:
            return SHUTTER_1_1000;
            break;
            
        default:
            return 0;
            break;
    }
}

- (LENS_IRIS_VALE)convertToIRISValueWithIndex:(int)index
{
    switch (index) {
        case 0:
            return (int) self.irisMinValue;
            break;
        case -1:
            return (int)(self.irisMinValue + 1 * 3);
            break;
        case -2:
            return (int)(self.irisMinValue + 2 * 3);
            break;
        case -3:
            return (int)(self.irisMinValue + 4 * 2);
            break;
        case -4:
            return (int)(self.irisMinValue + 5 * 2);
            break;
        case -5:
            return (int)(self.irisMinValue + 6 * 2);
            break;
        case -6:
            return (int)(self.irisMinValue + 7 * 2);
            break;
            
        default:
            return 2;
            break;
    }
}

- (signed int)convertToExposureIndexWithValue:(LENS_EXPOSURE_VALUE)value
{
    switch (value) {
            //        case EVN3P0:
            //            return 0;
            //            break;
            //        case EVN2P0:
            //            return 1;
            //            break;
            //        case EVN1P0:
            //            return 2;
            //            break;
            //        case EVP0P0:
            //            return 3;
            //            break;
            //        case EVP1P0:
            //            return 4;
            //            break;
            //        case EVP2P0:
            //            return 5;
            //            break;
            //        case EVP3P0:
            //            return 6;
            //            break;
            
        case EVN10P0:
            return -10;
            break;
        case EVN9P0:
            return -9;
            break;
        case EVN8P0:
            return -8;
            break;
        case EVN7P0:
            return -7;
            break;
        case EVN6P0:
            return -6;
            break;
        case EVN5P0:
            return -5;
            break;
        case EVN4P0:
            return -4;
            break;
        case EVN3P0:
            return -3;
            break;
        case EVN2P0:
            return -2;
            break;
        case EVN1P0:
            return -1;
            break;
        case EVP0P0:
            return 0;
            break;
        case EVP1P0:
            return 1;
            break;
        case EVP2P0:
            return 2;
            break;
        case EVP3P0:
            return 3;
            break;
        case EVP4P0:
            return 4;
            break;
        case EVP5P0:
            return 5;
            break;
        case EVP6P0:
            return 6;
            break;
        case EVP7P0:
            return 7;
            break;
        case EVP8P0:
            return 8;
            break;
        case EVP9P0:
            return 9;
            break;
        case EVP10P0:
            return 10;
            break;
            
        default:
            return 22;
            break;
    }
}

- (int)convertToShutterIndexWithValue:(LENS_SHUTTER_VALUE)value
{
    switch (value) {
        case SHUTTER_1_25:
            return 0;
            break;
        case SHUTTER_1_50:
            return 1;
            break;
        case SHUTTER_1_100:
            return 2;
            break;
        case SHUTTER_1_150:
            return 3;
            break;
        case SHUTTER_1_200:
            return 4;
            break;
        case SHUTTER_1_500:
            return 5;
            break;
        case SHUTTER_1_1000:
            return 6;
            break;
            
        default:
            return 0;
            break;
    }
}

- (int)convertToIRISIndexWithValue:(LENS_IRIS_VALE)value
{
    if (value == self.irisMinValue) return 0;
    if (value == self.irisMinValue + 1 * 3) return -1;
    if (value == self.irisMinValue + 2 * 3) return -2;
    if (value == self.irisMinValue + 4 * 2) return -3;
    if (value == self.irisMinValue + 5 * 2) return -4;
    if (value == self.irisMinValue + 6 * 2) return -5;
    if (value == self.irisMinValue + 7 * 2) return -6;
    else return 1;
}
#pragma mark - recode value

- (LENS_EXPOSURE_VALUE)recodeLensExposureValueWith:(NSString *)string
{
    if ([string isEqualToString:@"-5.0"]) return 0;
    
    if ([string isEqualToString:@"-4.0"]) return 1;
    
    if ([string isEqualToString:@"-3.0"]) return 2;
    
    if ([string isEqualToString:@"-2.0"]) return 3;
    
    if ([string isEqualToString:@"-1.0"]) return 4;
    
    if ([string isEqualToString:@"0.0"]) return 5;
    
    if ([string isEqualToString:@"1.0"]) return 6;
    
    if ([string isEqualToString:@"2.0"]) return 7;
    
    if ([string isEqualToString:@"3.0"]) return 8;
    
    if ([string isEqualToString:@"4.0"]) return 9;
    
    if ([string isEqualToString:@"5.0"]) return 10;
    
    else return 11;
    
}


- (LENS_SHUTTER_VALUE)recodeLensShutterValue:(NSString *)string
{
    if ([string isEqualToString:@"1/25"]) return 1;
    
    if ([string isEqualToString:@"1/50"]) return 2;
    
    if ([string isEqualToString:@"1/75"]) return 3;
    
    if ([string isEqualToString:@"1/100"]) return 4;
    
    if ([string isEqualToString:@"1/125"]) return 5;
    
    if ([string isEqualToString:@"1/150"]) return 6;
    
    if ([string isEqualToString:@"1/200"]) return 7;
    
    if ([string isEqualToString:@"1/500"]) return 8;
    
    if ([string isEqualToString:@"1/1000"]) return 9;
    
    if ([string isEqualToString:@"1/2000"]) return 10;
    
    if ([string isEqualToString:@"1/4000"]) return 11;
    
    if ([string isEqualToString:@"1/8000"]) return 12;
    
    else return 0;
}

- (LENS_IRIS_VALE)recodeLensValueWith:(NSString *)string
{
    if ([string isEqualToString:@"F1.2"])   return 0;
    
    if ([string isEqualToString:@"F1.4"])   return 1;
    
    if ([string isEqualToString:@"F1.7"])   return 2;
    
    if ([string isEqualToString:@"F1.8"])   return 3;
    
    if ([string isEqualToString:@"F2.0"])   return 4;
    
    if ([string isEqualToString:@"F2.2"])   return 5;
    
    if ([string isEqualToString:@"F2.5"])   return 6;
    
    if ([string isEqualToString:@"F2.8"])   return 7;
    
    if ([string isEqualToString:@"F3.2"])   return 8;
    
    if ([string isEqualToString:@"F3.5"])   return 9;
    
    if ([string isEqualToString:@"F4.0"])   return 10;
    
    if ([string isEqualToString:@"F4.5"])   return 11;
    
    if ([string isEqualToString:@"F5.0"])   return 12;
    
    if ([string isEqualToString:@"F5.6"])   return 13;
    
    if ([string isEqualToString:@"F6.3"])   return 14;
    
    if ([string isEqualToString:@"F7.1"])   return 15;
    
    if ([string isEqualToString:@"F8.0"])   return 16;
    
    if ([string isEqualToString:@"F9.0"])   return 17;
    
    if ([string isEqualToString:@"F10.0"])  return 18;
    
    if ([string isEqualToString:@"F11.0"])  return 19;
    
    if ([string isEqualToString:@"F13.0"])  return 20;
    
    if ([string isEqualToString:@"F14.0"])  return 21;
    
    if ([string isEqualToString:@"F16.0"])  return 22;
    
    if ([string isEqualToString:@"F18.0"])  return 23;
    
    if ([string isEqualToString:@"F20.0"])  return 24;
    
    if ([string isEqualToString:@"F22.0"])  return 25;
    
    else return 26;
    
}

- (NSString *)decodeLensShutterValueWith:(int)shutter
{
    switch (shutter) {
        case 1:
            return @"1/25";
            break;
        case 2:
            return @"1/50";
            break;
        case 3:
            return @"1/75";
            break;
        case 4:
            return @"1/100";
            break;
        case 5:
            return @"1/125";
            break;
        case 6:
            return @"1/150";
            break;
        case 7:
            return @"1/200";
            break;
        case 8:
            return @"1/500";
            break;
        case 9:
            return @"1/1000";
            break;
        case 10:
            return @"1/2000";
            break;
        case 11:
            return @"1/4000";
            break;
        case 12:
            return @"1/8000";
            break;
            
        default:
            return @"unknow";
            break;
    }
}

- (NSString *)decodeLensExposureValueWith:(int)exposure
{
    switch (exposure) {
        case 0:
            return @"-5.0";
            break;
        case 1:
            return @"-4.0";
            break;
        case 2:
            return @"-3.0";
            break;
        case 3:
            return @"-2.0";
            break;
        case 4:
            return @"-1.0";
            break;
        case 5:
            return @"0.0";
            break;
        case 6:
            return @"1.0";
            break;
        case 7:
            return @"2.0";
            break;
        case 8:
            return @"3.0";
            break;
        case 9:
            return @"4.0";
            break;
        case 10:
            return @"5.0";
            break;
            
        default:
            return @"unknown";
            break;
    }
}


- (NSString *)decodeLensValueWith:(int)iris
{
    switch (iris) {
            
        case 0:
            return @"F1.2";
            break;
        case 1:
            return @"F1.4";
            break;
        case 2:
            return @"F1.7";
            break;
        case 3:
            return @"F1.8";
            break;
        case 4:
            return @"F2.0";
            break;
        case 5:
            return @"F2.2";
            break;
        case 6:
            return @"F2.5";
            break;
        case 7:
            return @"F2.8";
            break;
        case 8:
            return @"F3.2";
            break;
        case 9:
            return @"F3.5";
            break;
        case 10:
            return @"F4.0";
            break;
        case 11:
            return @"F4.5";
            break;
        case 12:
            return @"F5.0";
            break;
        case 13:
            return @"F5.6";
            break;
        case 14:
            return @"F6.3";
            break;
        case 15:
            return @"F7.1";
            break;
        case 16:
            return @"F8.0";
            break;
        case 17:
            return @"F9.0";
            break;
        case 18:
            return @"F10.0";
            break;
        case 19:
            return @"F11.0";
            break;
        case 20:
            return @"F13.0";
            break;
        case 21:
            return @"F14.0";
            break;
        case 22:
            return @"F16.0";
            break;
        case 23:
            return @"F18.0";
            break;
        case 24:
            return @"F20.0";
            break;
        case 25:
            return @"F22.0";
            break;
            
        default:
            return @"unknown";
            break;
    }
}


@end

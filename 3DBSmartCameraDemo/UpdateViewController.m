//
//  UpdateViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/6.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import "UpdateViewController.h"
#import "RootTabBarViewController.h"
#import "ImageClient.h"
#import "SaveLoadInfoManager.h"
#import "JTMaterialTransition.h"
#import "BLAnimation.h"
#import "PulseWaveController.h"
#import "CMDManager.h"
#import "BL32BitCheckSumValidator.h"
#import "LZProgressView.h"
#import "ProgressHUD.h"
#import "TCPSocketManager.h"
#import "net_interface_params.h"
#import "TimeoutManager.h"
#import "WIFIDetector.h"
#import "FirmwareManager.h"

#define kFirmwareName @"BOOT_T2.09"

@interface UpdateViewController ()<TCPSocketManagerDelegate, TimeOutManagerDelegate>

@property (nonatomic, strong) TCPSocketManager  *socketManager;
@property (nonatomic, strong) LZProgressView *progressView;
@property (nonatomic, strong) UIAlertView *updateAlert;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, assign) TimeoutManager *timeoutManager;
@property (nonatomic, assign) BOOL reUpdatedFlag;


@end

@implementation UpdateViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // setup background color
    //self.view.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
//    self.view.backgroundColor = [UIColor clearColor];
//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    blurView.frame = self.view.frame;
//    [self.view addSubview:blurView];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.updateAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Update Camera", nil)
                                                  message:self.message
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                        otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
    
    [self.updateAlert show];

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self.socketManager startKeepingAlive];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    self.socketManager.delegate = self;
    // Do any additional setup after loading the view.
    self.timeoutManager = [TimeoutManager sharedTimeOutManager];
    self.timeoutManager.delegate = self;
    self.reUpdatedFlag = NO;
    
    self.view.backgroundColor = [UIColor clearColor];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.view.frame;
    [self.view addSubview:blurView];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateCamera {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kFirmwareName ofType:@"bin"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    self.socketManager.upLoadData = data;
    unsigned int checksum;
    checksum = [BL32BitCheckSumValidator calculateCheckSumWithData:data];
    NSLog(@"开始上传固件，校验和checksum is :%u", checksum);
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDUploadSingleFileWithDataWithCheckSum(checksum, data)];
    [self.timeoutManager executeTimeOutCounterWithCMD:nil withAmout:0 withTimeOut:90.0 repeat:NO];
    [self.socketManager receiveMessageWithTimeOut:-1];
}

- (void)updateCameraWithFirmwarePath:(NSURL *)filePath
{
    
    NSData *uploadData = [NSData dataWithContentsOfURL:filePath];
    self.socketManager.upLoadData = uploadData;
    unsigned int checksum;
    checksum = [BL32BitCheckSumValidator calculateCheckSumWithData:uploadData];
    NSLog(@"开始上传固件，校验和checksum is :%u", checksum);
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDUploadSingleFileWithDataWithCheckSum(checksum, uploadData)];
    [self.timeoutManager executeTimeOutCounterWithCMD:nil withAmout:0 withTimeOut:90.0 repeat:NO];
    [self.socketManager receiveMessageWithTimeOut:-1];
}

- (void)updateLabelWithString:(NSString *)string
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        self.hintLabel.text = string;
    });
}

- (void)prepareDismiss
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(dismissController) userInfo:nil repeats:NO];
    });
    
}

- (void)prepareReupdate
{
    self.reUpdatedFlag = YES;
    if (!self.socketManager.isLost) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(reUpdateCamera) userInfo:nil repeats:NO];
        });
    }
    else [self dismissController];

    
}
- (void)dismissController
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self dismissViewControllerAnimated:YES completion:^(){
            [TCPSocketManager sharedTCPSocketManager].delegate = (id)self.presentingViewController;
        }];
    });
}

- (void)reUpdateCamera
{
    [self updateCamera];
}

#pragma mark - Socket Manager delegate

- (void)didFinishSingleFileDownloadingWithImageData:(NSData *)imageData
{}

- (void)didDisconnectSocket
{
    [self updateLabelWithString:NSLocalizedString(@"Connection Lost", nil)];
    //[self.updateAlert dismissWithClickedButtonIndex:0 animated:YES];
    [self.updateAlert dismissWithClickedButtonIndex:0 animated:YES];
    [self prepareDismiss];
}

- (void)didFinishConnectToHost
{
//    if (self.reUpdatedFlag) {
//        [self updateCamera];
//        self.reUpdatedFlag = NO;
//    }
}

- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command
{
    [self.socketManager receiveMessageWithTimeOut:-1];
}

- (void)didReceiveACKWithState:(CTL_MESSAGE_PACKET)ACK
{
    if (ACK.cmd == SDB_SET_STANDBY_EN_ACK || ACK.cmd == SDB_SET_STANDBY_EN) {
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self updateCamera];
        });
    }
    
    if (ACK.cmd == SDB_SET_UPLOAD_ZYNQ_FRIMWARE_ACK) {
        
        //if (self.currentVersion < 1.13f) {
            [self updateLabelWithString:[NSString stringWithFormat:@"%@ (state: %d)",NSLocalizedString(@"Preparing update", nil), ACK.state]];
        //}
    }
    if (ACK.cmd == SDB_GET_UPLOAD_STATE_ACK) {
        
        switch (ACK.state) {
                
            case SDB_STATE_UPLOAD_UNKNOWN:
                break;
                
            case SDB_STATE_TRANSMITTING:
                [self.socketManager receiveMessageWithTimeOut:-1];
                [self updateLabelWithString:NSLocalizedString(@"Updating", nil)];
                
                break;
                
            case SDB_STATE_TRANSMIT_SUCCESS:
                [self.socketManager receiveMessageWithTimeOut:-1];
                [self updateLabelWithString:NSLocalizedString(@"Updated", nil)];
                //[self prepareDismiss];
                
                break;
                
            case SDB_STATE_TRANSMIT_FAILED:
                [self updateLabelWithString:NSLocalizedString(@"Update Failed", nil)];
                [self prepareDismiss];
                
                break;
                
            case SDB_STATE_CHECKING:
                [self.socketManager receiveMessageWithTimeOut:-1];
                [self updateLabelWithString:NSLocalizedString(@"Verifying", nil)];
                
                break;
                
            case SDB_STATE_CHECK_SUCCESS:
                [self.socketManager receiveMessageWithTimeOut:-1];
                [self updateLabelWithString:NSLocalizedString(@"Verified", nil)];
                
                break;
                
            case SDB_STATE_CHECK_FAILED:
                [self updateLabelWithString:NSLocalizedString(@"Verify Failed", nil)];
                [self prepareReupdate];
                //[self prepareDismiss];
                break;
                
            case SDB_STATE_SAVING:
                [self.socketManager receiveMessageWithTimeOut:-1];
                [self updateLabelWithString:NSLocalizedString(@"Saving", nil)];
                
                break;
                
            case SDB_STATE_SAVE_SUCCESS:
                [self.socketManager receiveMessageWithTimeOut:-1];
                [self updateLabelWithString:NSLocalizedString(@"Saved", nil)];
                
                break;
                
            case SDB_STATE_SAVE_FAILED:
                [self updateLabelWithString:NSLocalizedString(@"Save Failed", nil)];
                [self prepareReupdate];
                //[self prepareDismiss];
                break;
                
            case SDB_STATE_RECHECKING:
                [self.socketManager receiveMessageWithTimeOut:-1];
                [self updateLabelWithString:NSLocalizedString(@"Re-verifying", nil)];
                
                break;
                
            case SDB_STATE_RECHECK_SUCCESS:
                [self.socketManager receiveMessageWithTimeOut:-1];
                [self updateLabelWithString:NSLocalizedString(@"Re-verified", nil)];
                
                break;
                
            case SDB_STATE_RECHECK_FAILED:
                [self.socketManager receiveMessageWithTimeOut:-1];
                [self updateLabelWithString:NSLocalizedString(@"Re-verify Failed", nil)];
                //[self prepareReupdate];
                [self prepareDismiss];
                break;
                
            case SDB_STATE_UPLOAD_SUCCESS:
                [self.socketManager receiveMessageWithTimeOut:-1];
                [self updateLabelWithString:NSLocalizedString(@"Updated", nil)];
                [self prepareDismiss];
                
                break;
                
            case SDB_STATE_UPLOAD_RESET:
                [self updateLabelWithString:NSLocalizedString(@"Restarting", nil)];
                [[FirmwareManager sharedFirmwareManager] submitToNewestFirmware];
                [[FirmwareManager sharedFirmwareManager] saveFirmware];
                [self prepareDismiss];
                
                break;
                
            default:
                break;
        }
    }
}

- (void)didReceiveLensStatus:(LENS_PARAMS)lensStatus
{
}
- (void)didReceiveDebugInfo:(DEBUG_INFO)info
{
    
}
- (void)didLoseAlive
{}

- (void)didReceiveDevInfo:(DEV_INFO)decInfo
{}

- (void)didSendData
{
    [self.timeoutManager setFinishTransfering];
    //if (self.currentVersion < 1.13f) {
//        [self updateLabelWithString:@"即将重启相机"];
//        [self prepareDismiss];
    //}
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button index :%ld",(long)buttonIndex);
    if (buttonIndex == 0) {
        [self dismissController];
    }
    if (buttonIndex == 1) {
        
        //dispatch_async(dispatch_get_main_queue(), ^(){
            NSArray *colors = @[
                                //[UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1],
                                //[UIColor colorWithRed:70/255.0 green:70/255.0 blue:80/255.0 alpha:1],
                                //[UIColor grayColor],
                                
                                [UIColor colorWithRed:0.89 green:0.8 blue:0 alpha:1],

                                [UIColor redColor],
                                //[UIColor colorWithRed:170/255.0 green:32/255.0 blue:7/255.0 alpha:1],
                                //[UIColor colorWithRed:251/255.0 green:32/255.0 blue:7/255.0 alpha:1],
                                ];
            
            self.progressView = [[LZProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50) andLineWidth:3.0 andLineColor:colors];
            CGPoint center0 = CGPointMake(self.view.center.x, self.view.center.y - 20.0);
            self.progressView.center = center0;
            [self.view addSubview:self.progressView];
            
            self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
            self.hintLabel.center = CGPointMake(self.view.center.x, self.view.center.y + 25);
            self.hintLabel.textColor = [UIColor lightGrayColor];
            self.hintLabel.text = NSLocalizedString(@"Checking Firmware", nil);
            self.hintLabel.font = [UIFont systemFontOfSize:14.0f];
            self.hintLabel.textAlignment = NSTextAlignmentCenter;
            [self.view addSubview:self.hintLabel];
            
            [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(startUpdating) userInfo:nil repeats:NO];
        //});
    }
}

- (void)startUpdating
{
    [self updateCamera];
    
//    FirmwareManager *manager = [FirmwareManager sharedFirmwareManager];
//    if (manager.firmwareFileName && [[manager.latestUpdateURL substringWithRange:NSMakeRange(37 + 13, 14)] isEqualToString:manager.firmwareFileName]) {
//        [self updateCameraWithFirmwarePath:manager.firmwarePathURL];
//        NSLog(@"已有更新包，确认上传");
//    }
//    else {
//        self.hintLabel.text = @"正在下载更新包...";
//        NSLog(@"没有检测到最新更新包，开始下载");
//        [manager downloadLatestFirmwareWithURL:manager.latestUpdateURL progress:^(NSProgress *downloadProgress){
//            dispatch_async(dispatch_get_main_queue(), ^(){
//                self.hintLabel.text = [NSString stringWithFormat:@"正在下载...%.1f％", (downloadProgress.fractionCompleted) * 100];
//            });
//        } completeHandler:^(NSURL *filePath, NSError *error){
//            [self updateCameraWithFirmwarePath:filePath];
//        }];
//    }
}

#pragma mark - Time out handle delegate
- (void)didTimeoutWithInfo:(id)userInfo
{
    NSLog(@"transfer data is timing out");
    [self updateLabelWithString:NSLocalizedString(@"Connection Lost", nil)];
    [self prepareDismiss];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

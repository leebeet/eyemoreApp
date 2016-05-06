//
//  ImageRecorder.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/23.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import "ImageRecorder.h"

@implementation ImageRecorder

+ (ImageRecorder *)sharedImageRecorder
{
    static ImageRecorder *instance;
    if (instance == nil) {
        instance = [ImageRecorder sharedImageRecorder];
    }
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.socketManager = [TCPSocketManager sharedTCPSocketManager];
        self.socketManager.delegate = self;
    }
    return self;
}

- (void)takeSinglePhoto
{
    [self.socketManager receiveMessageWithTimeOut:-1];
}

#pragma mark - Socket Manager delegate

- (void)didFinishSingleFileDownloadingWithImageData:(NSData *)imageData
{
//    NSLog(@"did finish download image and display : %lu", (unsigned long)[imageData length]);
//    
//    [self.imgClient storeSingleImageWithData:imageData];
//    NSLog(@"img path :%@", self.imgClient.imgPath);
//    //[self.imageButtom updateWithImage:[UIImage imageWithData:imageData] animated:YES];
//    
//    //self.imgClient.lastImageIndex = self.imgClient.syncImgPath.count - 1;
//    self.imgClient.lastImageIndex = self.imgClient.imgPath.count - 1;
//    self.imgClient.syncLeavingFlag = self.imgClient.lastImageIndex;
//    
//    dispatch_async(dispatch_get_main_queue(), ^(){
//        
//        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDReceiveOInMode(0)];
//        [self.socketManager receiveMessageWithTimeOut:-1];
//        [CameraSoundPlayer playSound];
//        [self showImage];
//    });
    
}

- (void)didDisconnectSocket
{
//    dispatch_async(dispatch_get_main_queue(), ^(){
//        [self stopBreathPulsing];
//        [self.irisFilter           setAlpha:0.5];
//        [self.irisFilter           setEnabled:NO];
//        [self.exposurevValueFilter setAlpha:0.5];
//        [self.exposurevValueFilter setEnabled:NO];
//        [self.shutterFilter        setAlpha:0.5];
//        [self.shutterFilter        setEnabled:NO];
//        [self.exposureSlider       setAlpha:0.5];
//        [self.exposureSlider       setEnabled:NO];
//        [self.shutterSlider        setAlpha:0.5];
//        [self.shutterSlider        setEnabled:NO];
//        [self.irisSlider           setAlpha:0.5];
//        [self.irisSlider           setEnabled:NO];
//    });
    
}

- (void)didFinishConnectToHost
{
    
//    NSLog(@"*****************************************************************");
//    dispatch_async(dispatch_get_main_queue(), ^(){
//        //[ProgressHUD showSuccess:@"连接成功" Interaction:NO];
//    });
//    if (self.imgClient.cameraMode == SYNCMODE && !self.socketManager.isLost) {
//        
//        //self.isConnectedHost = YES;
//        NSLog(@"did connect to host in sync controller");
//        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToDDR];
//        
//        dispatch_async(dispatch_get_main_queue(), ^(){
//            [self startBreathPulsing];
//            [self.popLinkLabel dismiss];
//        });
//    }
}
- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command
{
    [self.socketManager receiveMessageWithTimeOut:-1];
}

- (void)didReceiveACKWithState:(CTL_MESSAGE_PACKET)ACK
{
//    if (ACK.cmd == SDB_SET_DEV_WORK_MODE_ACK && ACK.param0 == DWM_FLASH_PHOTO) {
//        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetLensStatus];
//    }
//    
//    if (ACK.cmd == SDB_SET_EXPOSURE_PARAM_ACK || ACK.cmd == SDB_SET_IRIS_PARAM_ACK || ACK.cmd == SDB_SET_SHUTTER_PARAM_ACK) {
//        if (ACK.state != SDB_STATE_SUCCESS) {
//            dispatch_async(dispatch_get_main_queue(), ^(){
//                [ProgressHUD showError:@"设置失败"];
//            });
//        }
//    }
//    
//    if (ACK.cmd == SDB_SET_RECV_OK_ACK) {
//        NSLog(@"确认已接收图片");
//    }
    
}

- (void)didReceiveLensStatus:(LENS_PARAMS)lensStatus
{
//    if (lensStatus.iris_min_value && lensStatus.iris_max_value) {
//        NSMutableArray *array = [[NSMutableArray alloc] init];
//        for (int i = lensStatus.iris_min_value; i <= lensStatus.iris_max_value - 10; i ++) {
//            [array addObject:[self decodeLensValueWith:i]];
//        }
//        self.irisArray = array;
//        self.irisMinValue = (NSUInteger)lensStatus.iris_min_value;
//        NSLog(@"len status: %lu", (unsigned long)lensStatus.current_iris_value);
//    }
//    
//    
//    dispatch_async(dispatch_get_main_queue(), ^(){
//        
//        [self.irisFilter           setAlpha:1];
//        [self.irisFilter           setEnabled:YES];
//        [self.exposurevValueFilter setAlpha:1];
//        [self.exposurevValueFilter setEnabled:YES];
//        [self.shutterFilter        setAlpha:1];
//        [self.shutterFilter        setEnabled:YES];
//        [self.exposureSlider       setAlpha:1];
//        [self.exposureSlider       setEnabled:YES];
//        [self.shutterSlider        setAlpha:1];
//        [self.shutterSlider        setEnabled:YES];
//        [self.irisSlider           setAlpha:1];
//        [self.irisSlider           setEnabled:YES];
//        
//        [self updateUIWithLensParam:lensStatus];
//    });
//    
//    //if (self.shootMode == SYNC_MODE) {
//    [self.socketManager receiveMessageWithTimeOut:-1];
//    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetDeviceInfo];
//    //}
}

- (void)didLoseAlive
{}

- (void)didReceiveDevInfo:(DEV_INFO)decInfo
{
//    static int i = 0;
//    if (i == 0) {
//        dispatch_async(dispatch_get_main_queue(), ^(){
//            
//            NSString *Version = [NSString stringWithFormat:@"version%s", decInfo.dev_version];
//            NSArray *array = [Version componentsSeparatedByString:@"V"];
//            float i = [array[1] floatValue];
//            
//            NSLog(@"detected version :%f", i);
//            //           if (!([[NSString stringWithFormat:@"version%s", decInfo.dev_version] isEqualToString:@"V1.12"])) {
//            if (!(i >= 1.17f)) {
//                
//                UpdateViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"updateController"];
//                controller.currentVersion = i;
//                [self presentViewController:controller animated:YES completion:nil];
//             }
//        });
//        i ++;
//    }
}

- (void)didSendData
{}

@end

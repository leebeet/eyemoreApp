//
//  RootViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/5/6.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "RootViewController.h"
#import "TCPSocketManager.h"
#import "Reachability.h"
#import "ProgressHUD.h"
#import "net_interface_params.h"
#import <arpa/inet.h>
#import "GCNetworkReachability.h"
#import "JRMessageView.h"
#import "WIFIDetector.h"

@interface RootViewController ()<UIAlertViewDelegate, JRMessageViewDelegate>
@property (strong, nonatomic) TCPSocketManager *socketManager;
@property (strong, nonatomic) UIBarButtonItem  *rightBarButtonItem;

@property (strong, nonatomic) UIAlertView      *connectAlert;
@property (strong, nonatomic) UIAlertView      *WIFIAlert;
@property (assign, nonatomic) BOOL              isConnectionAvailable;

@end

@implementation RootViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.socketManager.isLost) {
        [self.rightButton setIconConnected:NO];
    }
    else [self.rightButton setIconConnected:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    
    self.rightButton = [[Wifiicon alloc] init];
    if (self.socketManager.isLost) {
        [self.rightButton setIconConnected:NO];
    }
    else [self.rightButton setIconConnected:YES];
    [self.rightButton addTarget:self action:@selector(rightButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
     self.rightBarButtonItem.style = UIBarButtonItemStylePlain;
    
     self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    [self.navigationItem setRightBarButtonItem:self.rightBarButtonItem animated:YES];
    
    [self.socketManager addObserver:self forKeyPath:@"isLost" options:NSKeyValueObservingOptionNew context:nil];
    
    // setup background color
    self.view.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
    
    [self setUpwifiMessageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightButtonTapped:(id)sender
{
    //[NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(netWorkDetecting) userInfo:nil repeats:NO];
    [self showWifiMessage];
    
}

- (UIViewController *)appRootViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

- (void)showWifiMessage
{
    [self setUpwifiMessageView];
    if (self.socketManager.isLost) {
        [self.wifiMessageFail showMessageView];
    }
    else {
        self.wifiMessageSuccess.subTitleLabel.text = [NSString stringWithFormat:@"与%@相机连接中", [[WIFIDetector sharedWIFIDetector] getDeviceSSID]];
        [self.wifiMessageSuccess showMessageView];
    }

}

- (void)setUpwifiMessageView
{
    if (self.wifiMessageFail == nil) {
        self.wifiMessageFail = [[JRMessageView alloc] initWithTitle:@"未连接eyemore相机"
                                                           subTitle:@"点我跳转wifi设置"
                                                           iconName:@"11"
                                                        messageType:JRMessageViewTypeWarning
                                                    messagePosition:JRMessagePositionTop
                                                            superVC:[self appRootViewController]
                                                           duration:10];
    }

    if (self.wifiMessageSuccess == nil) {
        self.wifiMessageSuccess = [[JRMessageView alloc] initWithTitle:@"已连接"
                                                              subTitle:@"与eyemore相机正常通信中 "
                                                              iconName:@"11"
                                                           messageType:JRMessageViewTypeSuccess
                                                       messagePosition:JRMessagePositionTop
                                                               superVC:[self appRootViewController]
                                                              duration:3];

    }
    self.wifiMessageFail.delegate    = self;
    self.wifiMessageSuccess.delegate = self;
    
}

- (void)didTappedOnJRMessageView:(JRMessageView *)JRView
{
    if (JRView == self.wifiMessageFail) {
        [[WIFIDetector sharedWIFIDetector] openWIFISetting];
        [self.wifiMessageFail hidedMessageView];
    }
}

//- (void)netWorkDetecting
//{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^(){
//        
//        self.isConnectionAvailable = [self isConnectionAvailable];
//        
//        dispatch_async(dispatch_get_main_queue(), ^(){
//            
//            if (self.isConnectionAvailable) {
//                
//                [ProgressHUD dismiss];
//            }
//            else [ProgressHUD dismiss];
//            
//            if (self.socketManager.isLost && self.isConnectionAvailable) {
//                
//                self.connectAlert = [[UIAlertView alloc] initWithTitle:@"连接相机"
//                                     
//                                                               message:@"您的相机已经断开连接，点击确定进行重连"
//                                     
//                                                              delegate:self
//                                     
//                                                     cancelButtonTitle:@"取消"
//                                     
//                                                     otherButtonTitles:@"确定",nil];
//                
//                [self.connectAlert show];
//                
//            }
//            
//            else {
//                
//                self.WIFIAlert = [[UIAlertView alloc] initWithTitle:@"连接相机"
//                                  
//                                                            message:@"您的iPhone还没有连接网络，赶快点击设置进行连接吧"
//                                  
//                                                           delegate:self
//                                  
//                                                  cancelButtonTitle:@"取消"
//                                  
//                                                  otherButtonTitles:@"设置",nil];
//                
//                [self.WIFIAlert show];
//                
//            }
//            
//        });
//        
//    });
//}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    BOOL static isUdpChanged = YES;
    //BOOL static isTcpChanged = YES;
    if ([keyPath  isEqualToString: @"isLost"]) {
        if (self.socketManager.isLost) {
            [self.rightButton setIconConnected:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cameradDisconnected" object:nil];
            if (isUdpChanged) {
                NSLog(@"init long connection to udp socket");
                isUdpChanged = NO;
                [self.socketManager initLongConnectionToUdpSocket];
            }
        }
        else {
            isUdpChanged = YES;
            [self.rightButton setIconConnected:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cameraConnected" object:nil];
            NSLog(@" is udp lost changed");
        }
    }
}

-(void)dealloc
{
    [self.socketManager removeObserver:self forKeyPath:@"isLost"];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button tapped index :%ld", (long)buttonIndex);
    if (buttonIndex == 1 && alertView == self.connectAlert) {
        [self.socketManager.HBSocket enableBroadcast:NO  error:nil];
        [self.socketManager.HBSocket enableBroadcast:YES error:nil];
    }
    if (buttonIndex == 1 && alertView == self.WIFIAlert) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

-(BOOL) isConnectionAvailable{

    BOOL isExistenceNetwork = YES;
    
    GCNetworkReachability *reach = [GCNetworkReachability reachabilityWithInternetAddressString:[NSString stringWithFormat:@"%@", self.socketManager.socketHost]];
    NSLog(@"host: %@", self.socketManager.socketHost);
    //if (self.socketManager.socketHost) {
        switch ([reach currentReachabilityStatus]) {
            case GCNetworkReachabilityStatusNotReachable:
                isExistenceNetwork = NO;
                NSLog(@"notReachable");
                break;
            case GCNetworkReachabilityStatusWiFi:
                //isExistenceNetwork = YES;
    
                if (self.socketManager.socketHost) {
                    isExistenceNetwork = YES;
                }
                else isExistenceNetwork = NO;
                
                NSLog(@"WIFI");
                break;
            case GCNetworkReachabilityStatusWWAN:
                isExistenceNetwork = YES;
                NSLog(@"3G");
                break;
        }
    //}
    
    return isExistenceNetwork;
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

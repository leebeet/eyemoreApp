//
//  RootTableViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/5/22.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "RootTableViewController.h"
#import "TCPSocketManager.h"
#import "WIFIDetector.h"
#import "JRMessageView.h"
#import "Wifiicon.h"

@interface RootTableViewController ()<TCPSocketManagerDelegate, JRMessageViewDelegate>
@property (strong, nonatomic) TCPSocketManager *socketManager;
@property (strong, nonatomic) UIBarButtonItem  *rightBarButtonItem;
@property (strong, nonatomic) Wifiicon         *rightButton;
@property (strong, nonatomic) JRMessageView    *wifiMessageSuccess;
@property (strong, nonatomic) JRMessageView    *wifiMessageFail;

@end

@implementation RootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.socketManager = [TCPSocketManager sharedTCPSocketManager];
//    
//    self.rightButton = [[Wifiicon alloc] init];
//    if (self.socketManager.isLost) {
//        [self.rightButton setIconConnected:NO];
//    }
//    else [self.rightButton setIconConnected:YES];
//    [self.rightButton addTarget:self action:@selector(rightButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    
//    self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
//    self.rightBarButtonItem.style = UIBarButtonItemStylePlain;
//    
//    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
//    [self.navigationItem setRightBarButtonItem:self.rightBarButtonItem animated:YES];
//    
//    [self.socketManager addObserver:self forKeyPath:@"isLost" options:NSKeyValueObservingOptionNew context:nil];
    
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
        self.wifiMessageSuccess.subTitleLabel.text = [NSString stringWithFormat:@"%@ %@", [[WIFIDetector sharedWIFIDetector] getDeviceSSID], NSLocalizedString(@"Communicating", nil)];
        [self.wifiMessageSuccess showMessageView];
    }
    
}

- (void)setUpwifiMessageView
{
    if (self.wifiMessageFail == nil) {
        self.wifiMessageFail = [[JRMessageView alloc] initWithTitle:NSLocalizedString(@"Connect Eyemore Device", nil)
                                                           subTitle:NSLocalizedString(@"Tap To connect", nil)
                                                           iconName:@"11"
                                                        messageType:JRMessageViewTypeWarning
                                                    messagePosition:JRMessagePositionTop
                                                            superVC:[self appRootViewController]
                                                           duration:10];
    }
    
    if (self.wifiMessageSuccess == nil) {
        self.wifiMessageSuccess = [[JRMessageView alloc] initWithTitle:NSLocalizedString(@"Connected", nil)
                                                              subTitle:NSLocalizedString(@"Communicating", nil)
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath  isEqualToString: @"isLost"]) {
        if (self.socketManager.isLost) {
            [self.rightButton setIconConnected:NO];
        }
        else [self.rightButton setIconConnected:YES];
    }
}

-(void)dealloc
{
    [self.socketManager removeObserver:self forKeyPath:@"isLost"];
}

@end

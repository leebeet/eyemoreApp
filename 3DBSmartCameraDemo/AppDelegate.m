//
//  AppDelegate.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/3/23.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "AppDelegate.h"
#import "CMDManager.h"
#import "FirmwareManager.h"
#import "ImageClient.h"
#import "JRMessageView.h"
#import "ProgressHUD.h"
#import "SaveLoadInfoManager.h"
#import "TCPSocketManager.h"
#import "MRoundedButton.h"
#import "WIFIDetector.h"
#import "VideoClient.h"
#import "UpdateViewController.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

//腾讯SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

@interface AppDelegate ()<TCPSocketManagerDelegate, UIAlertViewDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"app did finish launching");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidFinishLaunch" object:nil];
    
    ImageClient *imageClient = [ImageClient sharedImageClient];
    imageClient.imgPath = [SaveLoadInfoManager loadInfoWithClient].imgPath;
    
    if (imageClient.imgPath.count) {
        imageClient.lastImageIndex = imageClient.imgPath.count - 1;
    }
    
    VideoClient *videoClient = [VideoClient sharedVideoClient];
    videoClient.videoList = [SaveLoadInfoManager loadAppInfoWithVideoClient].videoList;
    
    //注册第三方平台账号
    [ShareSDK registerApp:@"13914b4cec136"
          activePlatforms:@[@(SSDKPlatformTypeWechat), @(SSDKPlatformTypeQQ)]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;

             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
              
        switch (platformType)
        {
            case SSDKPlatformTypeWechat:
                //设置wechat应用信息
                [appInfo SSDKSetupWeChatByAppId:@"wx4823851a8f67a499" appSecret:@"59b0f55228055f6de23fecec6cd1ae45"];
                break;
                //设置qq应用信息
            case SSDKPlatformTypeQQ:
                [appInfo SSDKSetupQQByAppId:@"1105453260" appKey:@"LfBmdQn5UfPzWerT" authType:SSDKAuthTypeBoth];
                break;
                
            default:
                break;
        }
    }];
    //注册MRoundedButton外观
    NSDictionary *appearanceProxy1 = @{kMRoundedButtonCornerRadius : @40,
                                       kMRoundedButtonBorderWidth  : @3,
                                       kMRoundedButtonBorderColor  : [[UIColor whiteColor] colorWithAlphaComponent:0.8],
                                       kMRoundedButtonContentColor : [[UIColor whiteColor] colorWithAlphaComponent:0.8],
                                       kMRoundedButtonContentAnimateToColor : [[UIColor blackColor] colorWithAlphaComponent:0.5],
                                       kMRoundedButtonForegroundColor : [[UIColor blackColor] colorWithAlphaComponent:0.5],
                                       kMRoundedButtonForegroundAnimateToColor : [[UIColor whiteColor] colorWithAlphaComponent:1]};
    NSDictionary *appearanceProxy2 = @{kMRoundedButtonCornerRadius : @40,
                                       kMRoundedButtonBorderWidth  : @6,
                                       //kMRoundedButtonRestoreSelectedState : @NO,
                                       kMRoundedButtonBorderColor : [UIColor clearColor],
                                       kMRoundedButtonBorderAnimateToColor : [UIColor clearColor],
                                       kMRoundedButtonContentColor : [UIColor whiteColor],
                                       kMRoundedButtonContentAnimateToColor : [UIColor blackColor],
                                       kMRoundedButtonForegroundColor : [[UIColor whiteColor] colorWithAlphaComponent:1],
                                       kMRoundedButtonForegroundAnimateToColor : [[UIColor whiteColor] colorWithAlphaComponent:0.3]};
    NSDictionary *appearanceProxy3 = @{kMRoundedButtonCornerRadius : @40,
                                       kMRoundedButtonBorderWidth  : @2,
                                       kMRoundedButtonRestoreSelectedState : @NO,
                                       kMRoundedButtonBorderColor : [UIColor clearColor],
                                       kMRoundedButtonBorderAnimateToColor : [UIColor clearColor],
                                       kMRoundedButtonContentColor : [UIColor whiteColor],
                                       kMRoundedButtonContentAnimateToColor : [UIColor blackColor],
                                       kMRoundedButtonForegroundColor : [UIColor clearColor],
                                       kMRoundedButtonForegroundAnimateToColor : [UIColor colorWithRed:251/255.0 green:32/255.0 blue:7/255.0 alpha:0.9]};
    NSDictionary *appearanceProxy4 = @{kMRoundedButtonCornerRadius : @45,
                                       kMRoundedButtonBorderWidth  : @6,
                                       //kMRoundedButtonRestoreSelectedState : @NO,
                                       kMRoundedButtonBorderColor : [UIColor whiteColor],
                                       kMRoundedButtonBorderAnimateToColor : [UIColor clearColor],
                                       kMRoundedButtonContentColor : [UIColor clearColor],
                                       kMRoundedButtonContentAnimateToColor : [UIColor clearColor],
                                       kMRoundedButtonForegroundColor : [UIColor clearColor],
                                       kMRoundedButtonForegroundAnimateToColor : [UIColor colorWithRed:251/255.0 green:32/255.0 blue:7/255.0 alpha:0.9]};
    NSDictionary *appearanceProxy5 = @{kMRoundedButtonCornerRadius : @40,
                                       kMRoundedButtonBorderWidth  : @6,
                                       //kMRoundedButtonRestoreSelectedState : @NO,
                                       kMRoundedButtonBorderColor : [UIColor clearColor],
                                       kMRoundedButtonBorderAnimateToColor : [UIColor clearColor],
                                       kMRoundedButtonContentColor : [UIColor whiteColor],
                                       kMRoundedButtonContentAnimateToColor : [UIColor blackColor],
                                       kMRoundedButtonForegroundColor : [[UIColor redColor] colorWithAlphaComponent:1],
                                       kMRoundedButtonForegroundAnimateToColor : [[UIColor redColor] colorWithAlphaComponent:0.3]};
    
    
    [MRoundedButtonAppearanceManager registerAppearanceProxy:appearanceProxy1 forIdentifier:@"1"];
    [MRoundedButtonAppearanceManager registerAppearanceProxy:appearanceProxy2 forIdentifier:@"2"];
    [MRoundedButtonAppearanceManager registerAppearanceProxy:appearanceProxy3 forIdentifier:@"3"];
    [MRoundedButtonAppearanceManager registerAppearanceProxy:appearanceProxy4 forIdentifier:@"4"];
    [MRoundedButtonAppearanceManager registerAppearanceProxy:appearanceProxy5 forIdentifier:@"5"];
    
    //指定初始加载控制器
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"eyemoreLaunchScreen" bundle:nil];
    self.window.rootViewController = [storyBoard instantiateInitialViewController];
    
    //检查固件更新
    [NSTimer scheduledTimerWithTimeInterval:3.5f target:self selector:@selector(checkingCameraFirmware) userInfo:nil repeats:NO];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"ResignActive" object:nil];
    
        ImageClient *imageClient = [ImageClient sharedImageClient];
        [SaveLoadInfoManager saveAppInfoWithClient:imageClient];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"enter background");
    TCPSocketManager *manager = [TCPSocketManager sharedTCPSocketManager];
    //manager.delegate = self;
    if (!manager.isLost) {
        [manager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnterBackground" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnterForeground" object:nil];
    TCPSocketManager *manager = [TCPSocketManager sharedTCPSocketManager];
    [manager.lingSocket disconnect];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"BecomeActive" object:nil];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"Terminate APP");
    TCPSocketManager *manager = [TCPSocketManager sharedTCPSocketManager];
    //manager.delegate = self;
    if (!manager.isLost) {
        [manager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
    }
    
}

- (void)checkingCameraFirmware
{
    //检查固件更新
    FirmwareManager *manager = [FirmwareManager sharedFirmwareManager];
/* Desperated on R version, but works on beta version updation logic / OTA  */
    [manager getFirmwareJsonDescriptionSuccess:^(NSArray *descriptions){
        if (descriptions != nil) {
            [manager checkingLatestUpdateWithArray:descriptions];
        }
        if ([manager checkingCameraShouldUpdateWithCamVer:manager.camVerison]) {
            if (manager.firmwareFileName && [[manager.latestUpdateURL substringWithRange:NSMakeRange(37 + 13, 14)] isEqualToString:manager.firmwareFileName]) {
                NSLog(@"已有更新包");
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFirmware) name:@"cameraConnected" object:nil];
                [self updateFirmware];
            }
            else {
                NSLog(@"没有检测到最新更新包，开始下载");
                
                JRMessageView *downloadingMessage = [[JRMessageView alloc] initWithTitle:@"发现新固件"
                                                                                subTitle:@"正在准备下载...0％"
                                                                                iconName:@"firmwareiconWhite"
                                                                             messageType:JRMessageViewTypeCustom
                                                                         messagePosition:BLMessagePositionAfterStatuBar
                                                                                 superVC:[self appRootViewController]
                                                                                duration:100];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [downloadingMessage showMessageView];
                });
                [manager downloadLatestFirmwareWithURL:manager.latestUpdateURL
                                              progress:^(NSProgress *downloadProgress){
                                                  dispatch_async(dispatch_get_main_queue(), ^(){
                                                      NSLog(@"download progressing : %.2f", downloadProgress.fractionCompleted * 100);
                                                      downloadingMessage.subTitleLabel.text = [NSString stringWithFormat:@"正在下载...%.1f％", downloadProgress.fractionCompleted * 100];
                                                  });
                                                  
                                              }
                                       completeHandler:^(NSURL *filePath, NSError *error){
                                           if (error) {
                                               dispatch_async(dispatch_get_main_queue(), ^(){
                                                   downloadingMessage.subTitleLabel.text = @"下载出错";
                                                   downloadingMessage.duration = 3.0f;
                                               });
                                           }
                                           
                                           else {
                                               dispatch_async(dispatch_get_main_queue(), ^(){
                                                   downloadingMessage.subTitleLabel.text = @"下载完成";
                                                   downloadingMessage.duration = 3.0f;
                                               });
                                               [manager.downloadingProgress removeObserver:self forKeyPath:@"fractionCompleted"];
                                               [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFirmware) name:@"cameraConnected" object:nil];
                                               [self updateFirmware];
                                           }
                                       }];
            }
        }
    }];
///* R version firmware updation logic / offline */
//    float     camValue     = [[manager.camVerison substringFromIndex:1] floatValue];
//    float     updateValue  = [[kFirmwareVersion substringFromIndex:1] floatValue];
//    NSString *camLetter    = [manager.camVerison substringWithRange:NSMakeRange(0, 1)];
//    NSString *updateLetter = [kFirmwareVersion substringWithRange:NSMakeRange(0, 1)];
//    NSComparisonResult result = [camLetter compare:updateLetter];
//    if (result == NSOrderedSame) {
//        if (camValue < updateValue) {
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFirmware) name:@"cameraConnected" object:nil];
//            [self updateFirmware];
//        }
//    }

}

- (void)updateFirmware
{
    if (![TCPSocketManager sharedTCPSocketManager].isLost) {
        //保证只提醒更新一次
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            FirmwareManager *manager = [FirmwareManager sharedFirmwareManager];
            /* Desperated on R version, but works on beta version updation logic / OTA  */
            //由于在下载固件时不能确定相机和app发生什么操作，所以下载完成后，对比固件版本，确认升级
            if ([manager checkingCameraShouldUpdateWithCamVer:manager.camVerison]) {
                UpdateViewController *controller = [[UpdateViewController alloc] init];
                controller.currentVersion = [[manager.camVerison substringFromIndex:1] floatValue];
                controller.message = [NSString stringWithFormat:@"您的设备:%@有新固件:%@更新, 是否立即更新？ \n更新说明: \n%@",[[WIFIDetector sharedWIFIDetector] getDeviceSSID], manager.latestUpdate, manager.latestUpdateInfo];
                //controller.message = [NSString stringWithFormat:@"您的设备:%@有新固件:%@更新, 是否立即更新？ \n",[[WIFIDetector sharedWIFIDetector] getDeviceSSID], kFirmwareVersion];
            
                //让controller以模态视图展现
                UIViewController *rootVC = [self appRootViewController];
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                    controller.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                    controller.modalTransitionStyle   = UIModalTransitionStyleCrossDissolve;
                }else{
                    rootVC.modalPresentationStyle     = UIModalPresentationCurrentContext;
                }
                [rootVC presentViewController:controller animated:YES completion:nil];
            }
        });
    }
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    NSLog(@" [[UIApplication sharedApplication] keyWindow] = %@", window);
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    NSLog(@"[window subviews] objectAtIndex:0] = %@", [[window subviews] objectAtIndex:0]);
    id nextResponder = [frontView nextResponder];
    NSLog(@" nextResponder = [frontView nextResponder] = %@", nextResponder);
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
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

@end

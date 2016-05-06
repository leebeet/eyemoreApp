//
//  RootTabBarViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/4/15.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "RootTabBarViewController.h"
#import "ImageClient.h"
#import "SaveLoadInfoManager.h"
#import "JTMaterialTransition.h"
#import "BLAnimation.h"
#import "PulseWaveController.h"

@interface RootTabBarViewController ()<TCPSocketManagerDelegate>

@property (nonatomic, strong) TCPSocketManager  *socketManager;
@property (nonatomic, strong) ImageClient       *imageClient;
//@property (nonatomic) JTMaterialTransition      *transition;


@end

@implementation RootTabBarViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    
    self.view.alpha = 0;
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         self.view.alpha = 1;
                     }
                     completion:^(BOOL finished){}];
    
    //self.tabBar.tintColor = [UIColor colorWithRed:95/255.0 green:200/255.0 blue:75/255.0 alpha:1];
    self.tabBar.tintColor = [UIColor colorWithRed:251/255.0 green:32/255.0 blue:7/255.0 alpha:1];
    //self.tabBar.barTintColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1];
    //self.tabBar.barTintColor = [UIColor colorWithRed:8/255.0 green:8/255.0 blue:12/255.0 alpha:1];
    self.tabBar.translucent = YES;
    self.tabBar.barStyle = UIBarStyleBlack;
    [self wipeNaviBarBottomBaseLine];
    
    [self addCenterButtonWithImage:[UIImage imageNamed:@"11-photos_meitu_9"] highlightImage:nil];
    
    
     self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    [self.socketManager UdpSocketConnet];
    [self.socketManager initLongConnectionToUdpSocket];
    
    //取消屏幕锁屏 --> 恢复屏幕锁屏
    //[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideCenterButton) name:@"MeTableViewControllerWillAppear" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCenterButton) name:@"MeTableViewControllerWillDisappear" object:nil];
    
    //[self createTransition];
    //NSLog(@"%@",[UIDevice currentDevice].localizedModel);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSyncButtonEnable) name:@"SetCenterButtonEnable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSyncButtonDisable) name:@"SetCenterButtonDisable" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideCenterButton) name:@"SetCenterButtonHiden" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCenterButton) name:@"SetCenterButtonShow" object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)wipeNaviBarBottomBaseLine
{
    //NavigationBar底部的黑线是一个UIImageView上的UIImageView
    [self.tabBar setValue:@(YES) forKeyPath:@"_hidesShadow"];
}

- (void)setSyncButtonDisable
{
    [self.syncButton setUserInteractionEnabled:NO];
}

- (void)setSyncButtonEnable
{
    [self.syncButton setUserInteractionEnabled:YES];
}

-(void)addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    self.syncButton         = [UIButton buttonWithType:UIButtonTypeCustom];
     self.syncButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
     self.syncButton.frame            = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [self.syncButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.syncButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0){
        self.syncButton.center = self.tabBar.center;
//        CGPoint center = self.tabBar.center;
//        center.x = (center.x * 2 / 8 ) * 5;
//        button.center = center;
    }
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        self.syncButton.center = center;
    }
    [self.syncButton addTarget:self action:@selector(presentController:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.syncButton];
}

- (void)presentController:(id)sender
{
    PulseWaveController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PulseWaveController"];
    
    
//    controller.modalPresentationStyle = UIModalPresentationCustom;
//    controller.transitioningDelegate = self;
    
    [self presentViewController:controller animated:YES completion:^(){
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"setShootModeToSync" object:nil];
    }];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    //return (toInterfaceOrientation == UIInterfaceOrientationMaskPortrait);
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotate
{
    return YES;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)showCenterButton
{
    //    [self.syncButton setHidden:NO];
    //    [BLAnimation revealView:self.syncButton WithBLAnimation:BLEffectFadeIn completion:^(BOOL finish){
    //        [self.syncButton setHidden:NO];
    [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(showSyncButton) userInfo:nil repeats:NO];
    //        [self.syncButton removeFromSuperview];
    //        [self addCenterButtonWithImage:[UIImage imageNamed:@"11-photos_meitu_9"] highlightImage:nil];
    //
    //    }];
}

- (void)hideCenterButton
{
    [BLAnimation revealView:self.syncButton WithBLAnimation:BLEffectFadeOut completion:^(BOOL finish){
        self.syncButton.alpha = 0;
    }];
}

- (void)showSyncButton
{
    [BLAnimation revealView:self.syncButton WithBLAnimation:BLEffectFadeIn completion:^(BOOL finish){
        self.syncButton.alpha = 1;
        [self.view addSubview:self.syncButton];
    }];
    
}

//#pragma mark -  UIViewController Transitioning Delegate
//// Initialize the tansition
//- (void)createTransition
//{
//    // self.presentControllerButton is the animatedView used for the transition
//    self.transition = [[JTMaterialTransition alloc] initWithAnimatedView:self.syncButton];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  RootSyncPageController.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/7.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "RootSyncPageController.h"
#import "TCPSocketManager.h"
#import "JRMessageView.h"
#import "WIFIDetector.h"
#import "Wifiicon.h"
#import "VideoBrowserController.h"
@interface RootSyncPageController ()<JRMessageViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *Segment;
@property (strong, nonatomic) TCPSocketManager *socketManager;
@property (strong, nonatomic) UIBarButtonItem  *rightBarButtonItem;
@property (strong, nonatomic) Wifiicon         *rightButton;
@property (strong, nonatomic) JRMessageView    *wifiMessageSuccess;
@property (strong, nonatomic) JRMessageView    *wifiMessageFail;
@property (strong, nonatomic) NSArray          *pages;

@end

@implementation RootSyncPageController

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
    
    self.pages = @[[self.storyboard instantiateViewControllerWithIdentifier:@"DownloadViewController"], [[VideoBrowserController alloc] init]];
    [self setViewControllers:@[self.pages[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    self.dataSource = self;
    self.delegate = self;
    [self setUpSyncButtonItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncingNotiHandling:) name:@"SyncingNotification" object:nil];
}

- (void)setUpSyncButtonItem
{
    if (self.navigationItem.leftBarButtonItem == nil) {
        UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu1_small.png"] style:UIBarButtonItemStyleDone target:self action:@selector(menuButtonTapped)];
        [self.navigationItem setLeftBarButtonItem:btn];
    }
}

- (void)unSetUpSyncButtonItem
{
    [self.navigationItem setLeftBarButtonItem:nil];
}

- (void)rightButtonTapped:(id)sender
{
    //[NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(netWorkDetecting) userInfo:nil repeats:NO];
    [self showWifiMessage];
}

- (void)menuButtonTapped
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"menuButtonTapped" object:nil];
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

- (void)syncingNotiHandling:(NSNotification *)noti
{
    BOOL isSyncing = [[noti object] boolValue];
    if (isSyncing ) {
        [self.view setUserInteractionEnabled:NO];
    }
    else {
        [self.view setUserInteractionEnabled:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)segmentValueChanged:(id)sender {
    
    if (self.Segment.selectedSegmentIndex == 0) {
        [self setUpSyncButtonItem];
        [self setViewControllers:@[self.pages[0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }
    else if (self.Segment.selectedSegmentIndex == 1) {
        [self unSetUpSyncButtonItem];
        [self setViewControllers:@[self.pages[1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}

#pragma mark - UIPage View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (viewController == self.pages[0]) {
        return nil;
    }
    else return self.pages[0];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if (viewController == self.pages[0]) {
        return self.pages[1];
    }
    else return nil;
}

#pragma mark - UIPage View Controller Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        if ([previousViewControllers  isEqual: @[self.pages[0]]]) {
            [self.Segment setSelectedSegmentIndex:1];
            [self unSetUpSyncButtonItem];
            
        }
        else if ([previousViewControllers  isEqual: @[self.pages[1]]]) {
            [self.Segment setSelectedSegmentIndex:0];
            [self setUpSyncButtonItem];
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

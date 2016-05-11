//
//  DeviceViewController.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/17.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "DeviceViewController.h"
#import "TCPSocketManager.h"
#import "CMDManager.h"
#import "FirmwareManager.h"
#import "CamParasConverter.h"
#import "WIFIDetector.h"
#import "JTWavePulser.h"
#import "SettingCamTableViewController.h"
#import "PulseWaveController.h"
#import "HowToConnectController.h"

@interface DeviceViewController ()<TCPSocketManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSString *_camVer;
    BOOL _firstTimeload;
}
@property (nonatomic, strong) TCPSocketManager *socketManager;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *collectionItems;
@property (nonatomic, strong) UIView  *wavePulser;
@property (strong, nonatomic)JTWavePulserAnimation *animation;
@property (strong, nonatomic) UIButton *linkQuestButton;
@property (strong, nonatomic) BLBatteryView *batteryIndicator;

@end

@implementation DeviceViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setCameraWorkingState];
    [self refeshCameraState];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setUpDeviceImageView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraConnected) name:@"cameraConnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraDisconnected) name:@"cameradDisconnected" object:nil];
    _firstTimeload = YES;
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(cancelFirstTimeLoad) userInfo:nil repeats:NO];
}

- (void)cancelFirstTimeLoad
{
    _firstTimeload = NO;
}

- (void)refeshCameraState
{
    if (!self.socketManager.isLost) {
        [self updateUIWithConnected:YES];
    }
}

- (void)setCameraWorkingState
{
    //self.imgClient = [ImageClient sharedImageClient];
    //self.imgClient.delegate = self;
    //self.imgClient.cameraMode = DOWNLOADMODE;
    self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    self.socketManager.delegate = self;
    //设置相机工作模式
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
}
- (void)setUpcollectionView
{
    if (self.collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        flowLayout.minimumLineSpacing = 2;
        flowLayout.minimumInteritemSpacing = 1;
        
        CGFloat height = 0;
        //6p,6sp界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 414) {
            height = 136 * 2 + 4 + 50;
        }
        //5,5s界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 320) {
            height = 105 * 2 + 4 + 50;
        }
        //6,6s界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 375) {
            height = 123 * 2 + 4 + 50;
        }
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - height, self.view.frame.size.width, height) collectionViewLayout:flowLayout];
        self.collectionView.dataSource = self;
        self.collectionView.delegate   = self;
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
        self.collectionView.scrollEnabled = YES;
        self.collectionView.alwaysBounceVertical = YES;
        //[self.collectionView setContentSize:CGSizeMake(self.view.frame.size.width, 82 * self.imgClient.imgPath.count / 4 + 3000)];
        NSLog(@"[self.collectionView setContentSize : %f", self.collectionView.contentSize.height);
        //注册Cell，必须要有
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
        self.collectionView.alpha = 0;
        [self.view addSubview:self.collectionView];
        
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(){ self.collectionView.alpha = 1; } completion:nil];
    }
    else {
        [self.collectionView reloadData];
    }
}

- (void)setUpWavePulser
{
    if (self.wavePulser == nil) {
        //初始化wave动画效果
        self.wavePulser = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        self.wavePulser.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.0];
        CGPoint viewCenter = CGPointMake(self.DeviceImageView.center.x, self.DeviceImageView.center.y);
        self.wavePulser.center = viewCenter;
        self.wavePulser.layer.cornerRadius = 50;//self.wavePulser.layer.bounds.size.width / 2;
        self.wavePulser.layer.borderColor = [[UIColor greenColor] CGColor];
        [self.view insertSubview:self.wavePulser belowSubview:self.connectHintLabel];
        
        self.animation = [JTWavePulser animationWithView:self.wavePulser];
        self.animation.pulseAnimationDuration = 5.0f;
        self.animation.pulseAnimationInterval = 7.0f;
        self.animation.pulseRingWidth = 0;
        self.animation.pulseRingScale = 15.0;
        self.animation.pulseRingColor = [UIColor colorWithRed:251/255.0 green:32/255.0 blue:7/255.0 alpha:1.0];
        self.animation.pulseRingBackgroundColor = [UIColor colorWithRed:251/255.0 green:32/255.0 blue:7/255.0 alpha:0.85];
    }
    [self.view bringSubviewToFront:self.DeviceImageView];
    [self.animation startPulsing];
}

- (void)setUpLinkQuestButton
{
    if (self.linkQuestButton == nil) {
        self.linkQuestButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 45 / 2 - 44 - 10 - 64, self.view.frame.size.width - 50, 45)];
        self.linkQuestButton.center = CGPointMake(self.view.center.x, self.linkQuestButton.center.y);
        [self.linkQuestButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.linkQuestButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [self.linkQuestButton setTitle:@"连接／使用指南" forState:UIControlStateNormal];
        self.linkQuestButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.linkQuestButton.layer.masksToBounds = YES;
        self.linkQuestButton.layer.cornerRadius = 10;
        self.linkQuestButton.layer.borderWidth = 1.5;
        self.linkQuestButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
        [self.linkQuestButton addTarget:self action:@selector(linkQuestButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:self.linkQuestButton];

}

- (void)setUpDeviceImageView
{
    if (self.DeviceImageView == nil) {
        CGFloat height = 0;
        //6p,6sp界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 414) {
            height = 115;
        }
        //5,5s界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 320) {
            height = 85;
        }
        //6,6s界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 375) {
            height = 100;
        }

        self.DeviceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width / 2.3 , self.view.frame.size.width / 2.3)];
        self.DeviceImageView.center = CGPointMake(self.view.center.x, height + self.DeviceImageView.frame.size.height / 2 + 64);
        self.DeviceImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.DeviceImageView setImage:[UIImage imageNamed:@"exper_front"]];
        //self.DeviceImageView.backgroundColor = [UIColor darkGrayColor];
        self.DeviceImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DeviceImageViewTapped)];
        tap.numberOfTapsRequired = 1;
        [self.DeviceImageView addGestureRecognizer:tap];
    }
    [self.view addSubview:self.DeviceImageView];
    
}

- (void)setUpBatteryIndicatorWithValue:(float)value
{
    if (self.navigationItem.leftBarButtonItem == nil) {
        self.batteryIndicator = [[BLBatteryView alloc] initWithFrame:CGRectMake(0, 0, 30, 15)];
        UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithCustomView:self.batteryIndicator];
        [self.navigationItem setLeftBarButtonItem:btn];
    }
    [self.batteryIndicator setBatteryPowerProcessing:value];
}

- (void)unSetUpBatteryIndicator
{
    [self.navigationItem setLeftBarButtonItem:nil];
}

- (void)unSetUpLinkQuestButton
{
    [self.linkQuestButton removeFromSuperview];
    self.linkQuestButton = nil;
}

- (void)unSetUpWavePulser
{
    [self.animation stopPulsing];
    self.animation = nil;
    self.wavePulser = nil;
}

- (void)unSetUpCollectionView
{
    if (self.collectionView != nil) {
        [UIView animateWithDuration:0.2f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^(){ self.collectionView.alpha = 0; }
                         completion:^(BOOL finished){
                             if (finished) {
                                 [self.collectionView removeFromSuperview];
                                 self.collectionView = nil;
                             }
                         }
         ];
    }
}

- (void)DeviceImageViewTapped
{
    //if (!self.socketManager.isLost) {
        SettingCamTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingCamTableViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    //}
}

- (void)linkQuestButtonTapped
{
    HowToConnectController *controller = [[HowToConnectController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Notification

- (void)cameraDisconnected
{
    [self updateUIWithConnected:NO];
}

- (void)cameraConnected
{
    [self updateUIWithConnected:YES];
}

- (void)updateUIWithConnected:(BOOL)isConnected
{
    if (isConnected) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            self.connectHintLabel.text = @"已连接eyemore设备:";
            self.DeviceNameLabel.text = [[WIFIDetector sharedWIFIDetector] getDeviceSSID];
            //[self.DeviceImageView setImage:[UIImage imageNamed:@""]];
            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetDeviceInfo];
            [self setUpWavePulser];
            [self unSetUpLinkQuestButton];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^(){
            self.connectHintLabel.text = @"连接你的eyemore设备";
            self.DeviceNameLabel.text = @"无设备";
            //[self.DeviceImageView setImage:[UIImage imageNamed:@""]];
            [self unSetUpCollectionView];
            [self unSetUpWavePulser];
            [self unSetUpBatteryIndicator];
            [self setUpLinkQuestButton];
        });
    }
}
#pragma mark - UICollectionView Delegate FlowLayout

//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //6p,6sp界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 414) {
        return CGSizeMake(136, 136);
    }
    //5,5s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 320) {
        return CGSizeMake(105, 105);
    }
    //6,6s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 375) {
        return CGSizeMake(123, 123);
    }
    else return CGSizeMake(123, 123);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //6p,6sp界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 414) {
        return UIEdgeInsetsMake(1, 1, 1, 1);
    }
    //5,5s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 320) {
        return UIEdgeInsetsMake(1, 1, 1, 1);
    }
    //6,6s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 375) {
        return UIEdgeInsetsMake(1, 1, 1, 1);
    }
    else return UIEdgeInsetsMake(2, 2,2, 2);;
}

#pragma mark - UICollectionView Delegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //临时改变个颜色，看好，只是临时改变的。如果要永久改变，可以先改数据源，然后在cellForItemAtIndexPath中控制。（和UITableView差不多吧！O(∩_∩)O~）
    //cell.backgroundColor = [UIColor greenColor];
    NSLog(@"item======%ld",(long)indexPath.item);
    NSLog(@"row=======%ld",(long)indexPath.row);
    NSLog(@"section===%ld",(long)indexPath.section);
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - UICollectionView Data Source

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 6;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UICollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *buttonString = [self.collectionItems[indexPath.row] objectForKey:@"itemName"];
    NSString *buttonImageName = [self.collectionItems[indexPath.row] objectForKey:@"itemImage"];
//    UIButton *button = [[UIButton alloc] initWithFrame:cell.contentView.frame];
//    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    [button setTitle:buttonString forState:UIControlStateNormal];
//    [button setImage:[UIImage imageNamed:buttonImageName] forState:UIControlStateNormal];
//    //button.contentHorizontalAlignment = NSTextAlignmentCenter;
//    button.titleEdgeInsets = UIEdgeInsetsMake(button.frame.size.height / 2 - button.titleLabel.frame.size.height / 2, 0, 0, 0);
//    button.imageEdgeInsets = UIEdgeInsetsMake(-(button.frame.size.height / 2 - button.titleLabel.frame.size.height / 2), 0, 0, 0);
    //cell.contentView.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:34/255.0 alpha:1];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = cell.contentView.frame;
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 24)];
    [title setTextColor:[UIColor grayColor]];
    [title setText:buttonString];
    title.textAlignment = NSTextAlignmentCenter;
    title.center = CGPointMake(title.center.x, cell.contentView.center.y + title.frame.size.height / 2 + 10);
    
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:buttonImageName]];
    imageview.center = CGPointMake(cell.contentView.center.x ,cell.contentView.center.y - title.frame.size.height / 2 - 10);
    
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    [cell.contentView addSubview:blurView];
    [cell.contentView addSubview:imageview];
    [cell.contentView addSubview:title];
    return cell;
}


#pragma mark - Socket Manager Delegate

- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command
{
    [self.socketManager receiveMessageWithTimeOut:-1];
}

- (void)didReceiveACKWithState:(CTL_MESSAGE_PACKET)ACK
{
    if (ACK.cmd == SDB_SET_DEV_WORK_MODE_ACK && ACK.param0 == DWM_NORMAL) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetDeviceInfo];
    }
    
    if (ACK.cmd == SDB_SET_STANDBY_EN_ACK && ACK.param0 == STADNDBY_DISABLE) {
        
    }
    
    if (ACK.cmd == SDB_GET_NORMAL_PHOTO_COUNT_ACK) {
        
    }
    
    if (ACK.cmd == SDB_GET_BLOCK_NORMAL_PHOTOS_ACK) {
        
     }
    if (ACK.cmd == SDB_SET_RECV_OK_ACK) {
        
    }
}

- (void)didFinishConnectToHost
{
    if (_firstTimeload) {
        _firstTimeload = NO;
        dispatch_async(dispatch_get_main_queue(), ^(){
            PulseWaveController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PulseWaveController"];
            [self presentViewController:controller animated:YES completion:nil];
        });
    }
    else {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
    }
}

- (void)didDisconnectSocket
{
}

- (void)didReceiveDevInfo:(DEV_INFO)decInfo
{    
    _camVer = [NSString stringWithFormat:@"%s", decInfo.dev_version];
    FirmwareManager *manager = [FirmwareManager sharedFirmwareManager];
    manager.camVerison = [NSString stringWithString:_camVer];
    [manager saveFirmware];
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetLensStatus];
}

- (void)didReceiveLensStatus:(LENS_PARAMS)lensStatus
{
    NSDictionary *item1 = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@镜头", [CamParasConverter decodeLensTypeWith:lensStatus.lens_type]], @"itemName", @"lensType", @"itemImage", nil];
    NSDictionary *item2 = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@对焦", [CamParasConverter decodeLensFocusStateWith:lensStatus.focus_mode]], @"itemName", @"focusMode", @"itemImage", nil];
    NSDictionary *item3 = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"光圈 %@", [CamParasConverter decodeLensValueWith:lensStatus.current_iris_value]], @"itemName", @"irisicon", @"itemImage", nil];
    NSDictionary *item4 = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"快门 %@", [CamParasConverter decodeLensShutterValueWith:lensStatus.current_shutter_value]], @"itemName", @"shutter", @"itemImage", nil];
    NSDictionary *item5 = [NSDictionary dictionaryWithObjectsAndKeys:[CamParasConverter decodeLensExposureValueWith:lensStatus.current_exposure_value], @"itemName", @"irisicon", @"itemImage", nil];
    NSDictionary *item6 = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"固件 %@", _camVer], @"itemName", @"firmwareicon", @"itemImage", nil];
    self.collectionItems = [NSArray arrayWithObjects:item1, item2, item3, item4, item5, item6, nil];
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetDebugInfo];

    dispatch_async(dispatch_get_main_queue(), ^(){
        [self setUpcollectionView];
    });
    
}

- (void)didReceiveDebugInfo:(DEBUG_INFO)info
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self setUpBatteryIndicatorWithValue:info.StateOfCharge / 100.0];
    });
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFileList];
    
}
- (void)didFinishSingleFileDownloadingWithImageData:(NSData *)imageData
{}

- (void)didLoseAlive
{}


@end

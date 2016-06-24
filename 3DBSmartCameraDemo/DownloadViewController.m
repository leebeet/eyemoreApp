//
//  DownloadViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/3/24.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "DownloadViewController.h"

#import "ImageClient.h"
#import "SDWebImageManager.h"
#import "RootScrollViewController.h"
#import "MZTimerLabel.h"
#import "ImageAlbumManager.h"
#import "TCPSocketManager.h"
#import "ProgressHUD.h"
#import "SaveLoadInfoManager.h"
#import "CMDManager.h"
#import "BLAnimation.h"
#import "UpdateViewController.h"
#import "MMPopLabel.h"
#import "WIFIDetector.h"
#import "DeformationButton.h"
#import "FirmwareManager.h"
#import "BLUIkitTool.h"

#define kMaxNumber 20

typedef enum _downloadButtonStatus{

    DOWNLOADING = 0,
    DOWNLOADED,
    UNDOWNLOADED,
    NONEDOWNLOAD

}downloadButtonStatus;

@interface DownloadViewController ()<SDWebImageManagerDelegate,imageClientDelegate, TCPSocketManagerDelegate, UIAlertViewDelegate, MMPopLabelDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSData *_imageData;
    NSDate *_finishDate;
    NSDate *_startDate;
    UIProgressView *_savingProgress;
    BOOL _firstTimeload;
    float _progressValueUnit;
}

@property (strong, nonatomic)          ProgressHUD         *progressHUD;
@property (strong, nonatomic)          UIAlertView         *alertView;

@property (strong, nonatomic)          ImageClient         *imgClient;
@property (strong, nonatomic)          ImageAlbumManager   *albumManager;
@property (strong, nonatomic)          TCPSocketManager    *socketManager;

@property (strong, nonatomic)          UIButton            *imageButton;
@property (weak,   nonatomic) IBOutlet UIButton            *downloadButton;

@property (weak,   nonatomic) IBOutlet UILabel             *currentImageLabel;
@property (strong, nonatomic)          UILabel             *hintLabel;

@property (strong, nonatomic)          NSTimer             *playTimer;
@property (strong, nonatomic)          NSTimer             *timeOutTimer;
@property (strong, nonatomic)          NSDictionary        *timeOutInfo;
@property (strong, nonatomic)          dispatch_queue_t     savePhotoToAlbumQueue;
@property (assign, nonatomic)          NSInteger            imgPathBeforeDownloadedIndex;
@property (assign, nonatomic)          NSInteger            imgPathAfterDownloadedIndex;
@property (strong, nonatomic)          NSMutableArray      *insertIndexPaths;
@property (assign, nonatomic)          CameraMode           socketMode;
@property (assign, nonatomic)          NSInteger            animatingQueue;
@property (strong, nonatomic)          MMPopLabel          *popLinkLabel;

@property (strong, nonatomic)          UICollectionView    *collectionView;
@property (strong, nonatomic)          DeformationButton   *syncingButton;

@property (strong, nonatomic)          UIToolbar           *menuBar;



@end

@implementation DownloadViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setCameraWorkingState];    
    NSLog(@"DownloadViewController will appear...");
    if (self.imgClient.imgPath.count == 0) {
        //[self.imageButton setImage:nil forState:UIControlStateNormal];
        [self.hintLabel setHidden:NO];
    }
    else {
        [self.imageButton setHidden:NO];
        [self.hintLabel setHidden:YES];
    }
    //更新collection view
        //[self updateUIWithReloadCollectionView];
    
    //更新syncingButton动画
    if (self.socketMode == DOWNLOADMODE) {
        //[self setUpSyncingButton];
        [self updateUIWithSyncMode:DOWNLOADMODE];
    }
    
    //检查相机是否有照片需要同步，只运行一次
    static int oneTimeDownloadNoti = 0;
    if (oneTimeDownloadNoti == 0 && self.socketManager.fileList.paramn[0] > 0) {
        oneTimeDownloadNoti= 0;
        [self checkDownloading];
    }
    else {
        [self unSetUpItemBadgeValue];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.socketMode == DOWNLOADMODE) {
        [self updateUIWithSyncMode:NORMALMODE];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //首次加载时滑动collection至底部；
    static int i = 0;
    if (i == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            float offsetHeight = self.collectionView.contentSize.height - self.collectionView.bounds.size.height;
            if (offsetHeight > 0) {
                [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentSize.height - self.collectionView.bounds.size.height + 44) animated:NO];
            }
            i = 1;
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //setting image Button
    self.imageButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.width - 16)];
    [self.imageButton setImage:[UIImage imageNamed:@"3db_拍立得3"] forState:UIControlStateNormal];
    self.imageButton.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    self.imageButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageButton.layer.cornerRadius = 5;
    
    self.downloadButton.layer.cornerRadius = 5;
    [self.downloadButton setHidden:YES];
    [self.downloadButton setEnabled:NO];
    
//    [self.imageButton addTarget:self action:@selector(detailButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.imageButton];
//    [self.saveAllButton setHidden:YES];
    
    
//    self.downloadTimer.timerType = MZTimerLabelTypeStopWatch;
//    self.downloadTimer.timeFormat = @"HH:mm:ss SS";
    
    self.albumManager = [ImageAlbumManager sharedImageAlbumManager];
    self.savePhotoToAlbumQueue = dispatch_queue_create("com.dispatch.serial", DISPATCH_QUEUE_SERIAL);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modeDetecting)         name:@"EnterForeground"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncingStateChangged:) name:@"SyncState"        object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PhotoCountUpdate:)     name:@"PhotoCountUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumRefresh:)         name:@"AlbumUpdation"    object:nil];
    
    //[self initPoPLinkLabel];
    self.timeOutInfo = nil;
    
    //初始化指示label
    [self setUpHintLabel];
    
    //初始化collection view
    [self setUpImageCollection];
    //self.automaticallyAdjustsScrollViewInsets = NO;//    自动滚动调整，默认为YES
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //初始化同步buttonitem
    [self setUpMenuButtonItem];
    
    //初始化socket mode
    self.socketMode = NORMALMODE;
    
    // setup background color
    self.view.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
    
    _firstTimeload = YES;
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(cancelFirstTimeLoad) userInfo:nil repeats:NO];
}

- (void)cancelFirstTimeLoad
{
    _firstTimeload = NO;
}

- (void)setUIInteractionEnable:(BOOL)isEnable
{
    [self.tabBarController.tabBar setUserInteractionEnabled:isEnable];
    if (isEnable) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SetCenterButtonEnable" object:nil];
    }
    else [[NSNotificationCenter defaultCenter] postNotificationName:@"SetCenterButtonDisable" object:nil];
}

- (void)setCameraWorkingState
{
    self.imgClient = [ImageClient sharedImageClient];
    self.imgClient.delegate = self;
    self.imgClient.cameraMode = DOWNLOADMODE;
    self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    self.socketManager.delegate = self;
    //设置相机工作模式
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
}

#pragma mark - UI Initailization

- (void)setUpHintLabel
{
    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
    self.hintLabel.center = CGPointMake(self.view.center.x, self.view.center.y);
    self.hintLabel.text = NSLocalizedString(@"No Photos", nil);
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.textColor = [UIColor grayColor];
    [self.hintLabel setFont:[UIFont systemFontOfSize:25]];
    [self.view addSubview:self.hintLabel];
}

- (void)setUpImageCollection
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.minimumLineSpacing = 2;
    flowLayout.minimumInteritemSpacing = 0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:flowLayout];
    [self.collectionView setContentInset:UIEdgeInsetsMake(64, 0, 44, 0)];
    self.collectionView.dataSource = self;
    self.collectionView.delegate   = self;
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    self.collectionView.scrollEnabled = YES;
    self.collectionView.alwaysBounceVertical = YES;
    //[self.collectionView setContentSize:CGSizeMake(self.view.frame.size.width, 82 * self.imgClient.imgPath.count / 4 + 3000)];
    NSLog(@"[self.collectionView setContentSize : %f", self.collectionView.contentSize.height);
    //注册Cell，必须要有
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    
    [self.view addSubview:self.collectionView];

}

- (void)setUpMenuButtonItem
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuButtonTapped) name:@"menuButtonTapped" object:nil];
}

- (void)menuButtonTapped
{
    static BOOL shouldShow = YES;
    if (shouldShow) {
        [self setUpMenuBar];
        shouldShow = NO;
    }
    else {
        [self unSetUpMenuBar];
        shouldShow = YES;
    }
}

- (void)setUpMenuBar
{
    if (self.menuBar == nil) {
        self.menuBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        self.menuBar.barStyle = UIBarStyleBlack;
        self.menuBar.tintColor = [UIColor redColor];
        
        //UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"syncIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(downloadButtonTapped)];
        UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"syncIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(downloadButtonTapped)];
        UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"downloadBox_big.png"] style:UIBarButtonItemStylePlain target:self action:@selector(saveBarItemTapped)];
        UIBarButtonItem *btn3 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"trashBox.png"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteBarItemTapped)];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
        fixedSpace.width = 50;
        
        NSArray *arr1=[[NSArray alloc]initWithObjects:fixedSpace, btn1, flexibleSpace, btn2, flexibleSpace, btn3, fixedSpace, nil];
        [self.menuBar setItems:arr1 animated:YES];
    }
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    [self.view addSubview:self.menuBar];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         self.menuBar.center = CGPointMake(self.menuBar.center.x, self.menuBar.center.y + 64);
                     }
                     completion:^(BOOL finished){
                         [self.navigationItem.leftBarButtonItem setEnabled:YES];
                     }];
}

- (void)setUpSyncingButton
{
    self.syncingButton = [[DeformationButton alloc]initWithFrame:CGRectMake(0, 0, 50, 50) withColor:[UIColor redColor]];
    
    [self.syncingButton.forDisplayButton setTitle:@"   " forState:UIControlStateNormal];
    [self.syncingButton.forDisplayButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.syncingButton.forDisplayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.syncingButton.forDisplayButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
    self.syncingButton.transform = CGAffineTransformMakeScale(0.2, 0.2);
    self.syncingButton.isLoading = YES;
    [self.syncingButton setEnabled:YES];
    
    [self.syncingButton addTarget:self action:@selector(syncingButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^(){
        self.syncingButton.transform = CGAffineTransformMakeScale(1, 1);;
    } completion:^(BOOL finished){ }];
    
    CGFloat heightDifference = self.syncingButton.frame.size.height - self.tabBarController.tabBar.frame.size.height;
    if (heightDifference < 0){
        self.syncingButton.center = self.tabBarController.tabBar.center;
    }
    else
    {
        CGPoint center = self.tabBarController.tabBar.center;
        center.y = center.y - heightDifference/2.0 - 8;
        self.syncingButton.center = center;
    }
    [self.tabBarController.view addSubview:self.syncingButton];
}

- (void)setUpItemBadgeValueWithNumber:(NSNumber *)count
{
    UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:1];
    item.badgeValue= [NSString stringWithFormat:@"%@", count];
}

- (void)unSetUpSyncingButton
{
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^(){
        self.syncingButton.transform = CGAffineTransformMakeScale(0.4, 0.4);
    } completion:^(BOOL finished){
        [self.syncingButton removeFromSuperview];
        self.syncingButton = nil;
    }];
}

- (void)unSetUpHintLabel
{
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^(){
        self.hintLabel.transform = CGAffineTransformMakeScale(0.2, 0.2);
    } completion:^(BOOL finished){
        [self.hintLabel removeFromSuperview];
        self.hintLabel = nil;
    }];
}

- (void)unSetUpItemBadgeValue
{
    UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:1];
    item.badgeValue= nil;
}

- (void)unSetUpMenuBar
{
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         self.menuBar.center = CGPointMake(self.menuBar.center.x, self.menuBar.center.y - 64);
                     }
                     completion:^(BOOL finished){
                         [self.navigationItem.leftBarButtonItem setEnabled:YES];
                         [self.menuBar removeFromSuperview];
                         self.menuBar = nil;
                     }];
}
//- (void)initPoPLinkLabel
//{
//    [[MMPopLabel appearance] setLabelColor:[UIColor colorWithRed: 0.89 green: 0.6 blue: 0 alpha: 0.95]];
//    [[MMPopLabel appearance] setLabelTextColor:[UIColor whiteColor]];
//    [[MMPopLabel appearance] setLabelTextHighlightColor:[UIColor greenColor]];
//    [[MMPopLabel appearance] setLabelFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
//    [[MMPopLabel appearance] setButtonFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
//    
//    self.popLinkLabel = [MMPopLabel popLabelWithText:
//              @"iPhone未连接相机无线热点"];
//    
//    self.popLinkLabel.delegate = self;
//    
//    UIButton *skipButton = [[UIButton alloc] initWithFrame:CGRectZero];
//    [skipButton setTitle:NSLocalizedString(@"忽略", @"Skip Tutorial Button") forState:UIControlStateNormal];
//    [self.popLinkLabel addButton:skipButton];
//    
//    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectZero];
//    [okButton setTitle:NSLocalizedString(@"设置", @"Dismiss Button") forState:UIControlStateNormal];
//    [self.popLinkLabel addButton:okButton];
//    
//    [self.view insertSubview:self.popLinkLabel aboveSubview:self.imageButton];
//    //[self.popLinkLabel popAtView:self.downloadButton];
//}
//
//- (void)popingLinkLabel
//{
//    [self.navigationController.view insertSubview:self.popLinkLabel aboveSubview:self.imageButton];
//    [self.popLinkLabel popAtBarButtonItem:self.navigationItem.rightBarButtonItem];
//}

//#pragma mark - Lazy Loading / unloading
//
//- (NSMutableArray *)insertIndexPaths
//{
//    if (!_insertIndexPaths) {
//        _insertIndexPaths = [[NSMutableArray alloc] init];
//    }
//    return _insertIndexPaths;
//}
//
//- (void)releasingInsertIndexPaths
//{
//    [self.insertIndexPaths removeAllObjects];
//    self.insertIndexPaths = nil;
//}

#pragma mark - UI Updating

- (void)updateUIWithSyncingStateChangged
{
    //[self unSetUpSyncingButton];
    [self updateUIWithSyncMode:NORMALMODE];
}

- (void)updateUIWithSyncMode:(CameraMode)mode
{
    if (mode == DOWNLOADMODE) {
        [self.navigationController.navigationBar setUserInteractionEnabled:NO];
        [self.tabBarController.tabBar setUserInteractionEnabled:NO];
        [self.collectionView setUserInteractionEnabled:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncingNotification" object:@(YES)];
        [self setUpSyncingButton];
    }
    if (mode == NORMALMODE) {
        [self.navigationController.navigationBar setUserInteractionEnabled:YES];
        [self.tabBarController.tabBar setUserInteractionEnabled:YES];
        [self.collectionView setUserInteractionEnabled:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncingNotification" object:@(NO)];
        [self unSetUpSyncingButton];
    }
}

- (void)updateCollectionViewWithNumber:(int)count
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (int i = count; i > 0; i --) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(NSInteger)(self.imgClient.imgPath.count - i) inSection:0];
        NSLog(@"indexpath.row : %ld/ self.imgclient.path.count: %lu", (long)indexPath.row, (unsigned long)self.imgClient.imgPath.count);
        [indexPaths addObject:indexPath];
    }
    
    //判断当前交互是否在self，若在更新cell
    if (self.imgClient.delegate == self) {
        
        [self.collectionView insertItemsAtIndexPaths:indexPaths];
        float offsetHeight = self.collectionView.contentSize.height - self.collectionView.bounds.size.height;
        if (offsetHeight > 0) {
            [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentSize.height - self.collectionView.bounds.size.height) animated:YES];
        }
        //更新后释放insertIndexpaths
        //[self releasingInsertIndexPaths];
    }
}

- (void)updateUIWithReloadCollectionView
{
    [self.collectionView reloadData];
    float offsetHeight = self.collectionView.contentSize.height - self.collectionView.bounds.size.height;
    if (offsetHeight > 0) {
        [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentSize.height - self.collectionView.bounds.size.height + 44) animated:YES];
    }
    NSLog(@"self.collectionView.contentSize.height - self.collectionView.bounds.size.height = %f",self.collectionView.contentSize.height - self.collectionView.bounds.size.height);
    //[self.collectionView reloadData];
}
#pragma mark - Button Tapping Event Actions

- (IBAction)downloadButtonTapped {
    
    NSLog(@"download button did tap");
    [self checkDownloading];
    [self menuButtonTapped];
}
- (void)saveBarItemTapped
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Save All", nil) message:NSLocalizedString(@"Save All Detail", nil) preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert's cancel action occured.");
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert's other action occured.");
        [self menuButtonTapped];
        
        _savingProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        _savingProgress.progressViewStyle = UIProgressViewStyleBar;
        _savingProgress.progressTintColor = [UIColor redColor];
        _savingProgress.trackTintColor = [UIColor grayColor];
        _savingProgress.progress = 0;
        _savingProgress.transform = CGAffineTransformMakeScale(1, 3);
        [ProgressHUD show:NSLocalizedString(@"Saving", nil) view:_savingProgress Interaction:NO];
        
        _progressValueUnit = (float)1.0 / self.imgClient.imgPath.count;
        [self batchSaveAllPhotos];
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)deleteBarItemTapped
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete All", nil)  message:NSLocalizedString(@"Delete All Detail", nil)  preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert's cancel action occured.");
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)  style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"The \"Okay/Cancel\" alert's other action occured.");
        [self menuButtonTapped];
        [self.imgClient.dataCache removeAllWithBlock:^(BOOL success){
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.imgClient.imgPath removeAllObjects];
                [SaveLoadInfoManager saveAppInfoWithClient:self.imgClient];
                
                //删除完成后ui刷新
                [ProgressHUD showSuccess:NSLocalizedString(@"Deleted", nil)];
                [self setUpHintLabel];
                [self updateUIWithReloadCollectionView];
            });
        }];
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)syncingButtonTapped
{
    NSLog(@"syncing button tapped");
    self.syncingButton.isLoading = YES;
}

- (IBAction)detailButtonTapped:(id)sender {
    
    if (self.imgClient.imgPath.count > 0) {
        RootScrollViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"root"];
        controller.scrollArray = self.imgClient.imgPath;
        
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
        //controller.presentingDirection = nil;
        if (self.imgClient.lastImageIndex >= self.imgClient.imgPath.count) {
            self.imgClient.lastImageIndex = self.imgClient.imgPath.count - 1;
        }
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - Saving & Deleting Manage

- (void)batchSaveAllPhotos
{
    static float progress = 0;
    if (self.imgClient.imgPath.count) {
        NSLog(@"self.imageClient.imagePath: %@", self.imgClient.imgPath[0] );
        NSData *imageData = [self.imgClient getImageDataForKey:self.imgClient.imgPath[0]];
        
        //老设备无法创建相册，此处做兼容，直接保存到本地相册
        if ([[BLUIkitTool deviceVersion] isEqualToString:@"iPad mini (WiFi)"]) {
            UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
        else [self.albumManager saveToAlbumWithMetadata:nil
                                              imageData:imageData
                                        customAlbumName:@"eyemore Album"
                                        completionBlock:^(){
                                            
                                            [self.imgClient removeImageDataWithPath:self.imgClient.imgPath[0] WithCameraMode:DOWNLOADMODE];
                                            [self.imgClient.imgPath removeObjectAtIndex:0];
                                            [SaveLoadInfoManager saveAppInfoWithClient:self.imgClient];
                                            
                                            [self batchSaveAllPhotos];
                                            //dispatch_async(dispatch_get_main_queue(), ^(){
                                            progress += _progressValueUnit;
                                            [_savingProgress setProgress:progress animated:YES];
                                            
                                            // });
                                        }
                                           failureBlock:^(NSError *error){
                                               //处理添加失败的方法显示alert让它回到主线程执行，不然那个框框死活不肯弹出来
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   
                                                   //添加失败一般是由用户不允许应用访问相册造成的，这边可以取出这种情况加以判断一下
                                                   if([error.localizedDescription rangeOfString:@"User denied access"].location != NSNotFound ||[error.localizedDescription rangeOfString:@"用户拒绝访问"].location!=NSNotFound){
                                                       
                                                       UIAlertView *alert=[[UIAlertView alloc]initWithTitle:error.localizedDescription
                                                                                                    message:error.localizedFailureReason
                                                                                                   delegate:nil
                                                                                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                                                          otherButtonTitles:nil];
                                                       
                                                       [alert show];
                                                   }
                                               });
                                           }];
    }
    else {
        [ProgressHUD showSuccess:NSLocalizedString(@"Saved", nil) Interaction: NO];
        [self setUpHintLabel];
        [self updateUIWithReloadCollectionView];
        progress = 0;
    }
}

//有些型号的设备无法创建自定义相册，所以只能保存到胶卷，此时每存完一张都会掉用一下通知回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    static float progress = 0;
    
    [self.imgClient removeImageDataWithPath:self.imgClient.imgPath[0] WithCameraMode:DOWNLOADMODE];
    [self.imgClient.imgPath removeObjectAtIndex:0];
    [SaveLoadInfoManager saveAppInfoWithClient:self.imgClient];
    
    [self batchSaveAllPhotos];
    progress += _progressValueUnit;
    [_savingProgress setProgress:progress animated:YES];
    
    if (self.imgClient.imgPath.count == 0) {
        progress = 0;
        [self setUpHintLabel];
        [self updateUIWithReloadCollectionView];
    }
}


#pragma mark - Downloading & Progress Manage Methods

- (void)checkDownloading
{
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFileList];
    _finishDate = nil;
    if (self.socketManager.isLost) {
        //[ProgressHUD showError:@"连接已断开, 请连接相机后再试一次！" Interaction:NO];
        [self.wifiMessageFail showMessageView];
    }
    [self.hintLabel setHidden:YES];
}

- (void)startDownloading
{
    self.socketMode = DOWNLOADMODE;
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFileList];
}


#pragma mark - Notification Center

- (void)modeDetecting
{
    if (self.imgClient.cameraMode == DOWNLOADMODE) {
        self.socketMode = NORMALMODE;
        [self updateUIWithSyncMode:NORMALMODE];
    }
    //[self detect3dbNetWork];
}

- (void)syncingStateChangged:(NSNotification *)noti
{
    NSString *notiString = [noti object];
    if ([notiString isEqualToString:NSLocalizedString(@"Synced", nil)]) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [ProgressHUD showSuccess:notiString];
        });
    }
    else
        dispatch_async(dispatch_get_main_queue(), ^(){
            [ProgressHUD showError:notiString Interaction:NO];
        });

    //无论当前交互界面在哪，停止下载状态
    if (notiString) {
        self.socketMode = NORMALMODE;
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self updateUIWithSyncingStateChangged];
        });
    }
}

- (void)PhotoCountUpdate:(NSNotification *)noti
{
    NSNumber *count = [noti object];
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self setUpItemBadgeValueWithNumber:count];
    });
}

- (void)albumRefresh:(NSNotification *)noti
{
    [self updateUIWithReloadCollectionView];
}

#pragma mark - UICollectionView Data Source

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imgClient.imgPath.count;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"UICollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    UIImageView *cellImage = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
    cellImage.contentMode = UIViewContentModeScaleAspectFit;
    cellImage.alpha = 0;
    //cell.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:34/255.0 alpha:1];
    
    if ([[UIScreen mainScreen] bounds].size.width == 320) {
        //小屏幕／5，5s设备滑动卡顿优化
        [self.imgClient.dataCache dataForKey:self.imgClient.imgPath[indexPath.row] block:^(NSData *data){
            dispatch_async(dispatch_get_global_queue(0, 0), ^(){
                NSData *datan = UIImageJPEGRepresentation([UIImage imageWithData:data], 0.1);
                UIImage *image = [UIImage imageWithData:datan];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    
                    [UIView animateWithDuration:0.3f delay:0.4f options:UIViewAnimationOptionAllowAnimatedContent animations:^(){
                        cellImage.alpha = 1;
                        [cellImage setImage:image];
                    } completion:^(BOOL finished){}];
                });
            });
        }];
 
    }
    else{
        //小屏幕／6，6s, 6p, 6sp设备滑动卡顿优化
        [self.imgClient.dataCache dataForKey:self.imgClient.imgPath[indexPath.row] block:^(NSData *data){
            dispatch_async(dispatch_get_global_queue(0, 0), ^(){
                //NSData *datan = UIImageJPEGRepresentation([UIImage imageWithData:data], 0.1);
                UIImage *image = [UIImage imageWithData:data];
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [cell.contentView addSubview:cellImage];
                    [UIView animateWithDuration:0.3f delay:0.2f options:UIViewAnimationOptionAllowAnimatedContent animations:^(){
                        cellImage.alpha = 1;
                        [cellImage setImage:image];
                    } completion:^(BOOL finished){}];
                });
            });
        }];
    }
    
//    if (self.collectionView.dragging == NO && self.collectionView.decelerating == NO)
//    {
//        [self startIconDownloadforIndexPath:indexPath];
//    }
    
    for (id subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    if ([[UIScreen mainScreen] bounds].size.width == 320) {
          [cell.contentView addSubview:cellImage];
    }
   
    return cell;
}
//
//// -------------------------------------------------------------------------------
////	startIconDownload:forIndexPath:
//// -------------------------------------------------------------------------------
//- (void)startIconDownloadforIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
//    UIImageView *cellImage = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
//    cellImage.contentMode = UIViewContentModeScaleAspectFit;
//    cellImage.alpha = 0;
//    
//    if ([[UIScreen mainScreen] bounds].size.width == 320) {
//        //小屏幕／5，5s设备滑动卡顿优化
//        [self.imgClient.dataCache dataForKey:self.imgClient.imgPath[indexPath.row] block:^(NSData *data){
//            dispatch_async(dispatch_get_global_queue(0, 0), ^(){
//                NSData *datan = UIImageJPEGRepresentation([UIImage imageWithData:data], 0.1);
//                UIImage *image = [UIImage imageWithData:datan];
//                dispatch_async(dispatch_get_main_queue(), ^(){
//                    [cell.contentView addSubview:cellImage];
//                    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^(){
//                        cellImage.alpha = 1;
//                        [cellImage setImage:image];
//                    } completion:^(BOOL finished){}];
//                });
//            });
//        }];
//        
//    }
//    else{
//        //小屏幕／6，6s, 6p, 6sp设备滑动卡顿优化
//        [self.imgClient.dataCache dataForKey:self.imgClient.imgPath[indexPath.row] block:^(NSData *data){
//            dispatch_async(dispatch_get_global_queue(0, 0), ^(){
//                //NSData *datan = UIImageJPEGRepresentation([UIImage imageWithData:data], 0.1);
//                UIImage *image = [UIImage imageWithData:data];
//                
//                dispatch_async(dispatch_get_main_queue(), ^(){
//                    [cell.contentView addSubview:cellImage];
//                    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^(){
//                        cellImage.alpha = 1;
//                        [cellImage setImage:image];
//                    } completion:^(BOOL finished){}];
//                });
//            });
//        }];
//    }
//}
//
//// -------------------------------------------------------------------------------
////	loadImagesForOnscreenRows
////  This method is used in case the user scrolled into a set of cells that don't
////  have their app icons yet.
//// -------------------------------------------------------------------------------
//- (void)loadImagesForOnscreenRows
//{
//    if (self.imgClient.imgPath.count > 0)
//    {
//        NSArray *visiblePaths = [self.collectionView indexPathsForVisibleItems];
//        for (NSIndexPath *indexPath in visiblePaths)
//        {
//            [self startIconDownloadforIndexPath:indexPath];
//        }
//    }
//}
//
//
#pragma mark - UIScrollViewDelegate

//
//// -------------------------------------------------------------------------------
////	scrollViewDidEndDragging:willDecelerate:
////  Load images for all onscreen rows when scrolling is finished.
//// -------------------------------------------------------------------------------
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if (!decelerate)
//    {
//        [self loadImagesForOnscreenRows];
//    }
//}
//
//// -------------------------------------------------------------------------------
////	scrollViewDidEndDecelerating:scrollView
////  When scrolling stops, proceed to load the app icons that are on screen.
//// -------------------------------------------------------------------------------
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    [self loadImagesForOnscreenRows];
//}
#pragma mark - UICollectionView Delegate FlowLayout

//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //iPad界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 768) {
        return CGSizeMake(150, 150);
    }
    
    //6p,6sp界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 414) {
        return CGSizeMake(102, 102);
    }
    //5,5s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 320) {
        return CGSizeMake(105, 102);
    }
    //6,6s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 375) {
        return CGSizeMake(92, 90);
    }
    else return CGSizeMake(101, 58);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //6p,6sp界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 414) {
        return UIEdgeInsetsMake(1.5, 0, 1.5, 0);
    }
    //5,5s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 320) {
        return UIEdgeInsetsMake(1.5, 0, 1.5, 0);
    }
    //6,6s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 375) {
        return UIEdgeInsetsMake(1.5, 0, 1.5, 0);
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
    RootScrollViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"root"];
    controller.scrollArray = self.imgClient.imgPath;
    //if (self.imgClient.lastImageIndex >= self.imgClient.imgPath.count) {
        self.imgClient.lastImageIndex = indexPath.row;
    //}
    controller.shootMode = DOWNLOAD_SYNCING_MODE;
    [self presentViewController:controller animated:YES completion:^(){}];
    //self.wasExistByItemTapping = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

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

//- (void)displayImages
//{
//    static int i = 0;
//    if (i < self.imgClient.imgPath.count) {
//        [self.imageButton setImage:[self.imgClient getImageForKey:self.imgClient.imgPath[i]] forState:UIControlStateNormal];
//        [self progressWithRunning:YES];
//        i++;
//    }
//    //此处还需添加重置临时变量 i 的代码
//    if (i == (int)self.socketManager.fileList.paramn[0]) {
//        i = 0;
//        [self changeDownloadButtonStatus:DOWNLOADED];
//        self.imgClient.currentPath = self.imgClient.imgPath[(int)self.socketManager.fileList.paramn[0] - 1];
//        //[self setInteraction:YES];
//    }
//}

#pragma mark - Socket Manager Delegate

- (void)didFinishBatchFilesDownloadingWithImageDataArray:(NSMutableArray *)imageDataArray
{
    NSLog(@"did finish download image and display : %lu", (unsigned long)[imageDataArray[0] length]);
    static int i = 0;
    //NSLog(@"i value :%d, self.batchcount: %lu", i, (unsigned long)self.socketManager.bacthCount);
    
    //finishdate赋值，未超时
    _finishDate = self.socketManager.connectTimer.fireDate;
    
    [self.imgClient storeAllImagesWithData:imageDataArray WithCameraMode:DOWNLOADMODE StartAtIndex:i * 4];
    self.animatingQueue ++;
    dispatch_async(dispatch_get_main_queue(), ^(){
    
        //[self.timeOutTimer invalidate];
        //[ProgressHUD show:@"正在下载" Interaction:NO];
        //[self.imageButton setImage:[self.imgClient getImageForKey:[self.imgClient.imgPath lastObject]] forState:UIControlStateNormal];
        [self updateCollectionViewWithNumber:(int)imageDataArray.count];
//        [self progressWithRunning:YES];
//        
//        if (self.couldAnimate) {
//            [self startAnimatingDisplay];
//            self.couldAnimate = NO;
//        }
    });
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDReceiveOInMode(1)];
    //[self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFileList];
    [SaveLoadInfoManager saveAppInfoWithClient:self.imgClient];
}


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
        
        self.socketMode = DOWNLOADMODE;
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            
            if (!self.socketManager.isLost) {
            
                
                if (self.socketManager.fileList.paramn[0] < kBatchNumber) {
                    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDDownloadRestFiles(self.socketManager.fileList.paramn[0])];
                    [self executeTimeOutCounterWithCMD:@"CMDDownloadRestFiles" withAmout:self.socketManager.fileList.paramn[0]];
                }
                else {
                    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDDownloadBatchFiles];
                    [self executeTimeOutCounterWithCMD:@"CMDDownloadBatchFiles" withAmout:0];
                }
                
                //[self progressWithRunning:NO];
                //[self changeDownloadButtonStatus:DOWNLOADING];
                //[ProgressHUD show:@"正在准备同步,请稍等..." Interaction:NO];
                //[BLAnimation revealView:self.imageButton WithBLAnimation:BLEffectFadeOut completion:nil];

            }
            else [ProgressHUD showError:@"连接已断开, 请连接相机后再试一次！" Interaction:NO];
        });
    }
    
    if (ACK.cmd == SDB_GET_NORMAL_PHOTO_COUNT_ACK) {
        
        if (self.socketMode == NORMALMODE) {
            [self ACKHandleWithCommand:ACK withCamMode:NORMALMODE];
                    }
        if (self.socketMode == DOWNLOADMODE) {
            [self ACKHandleWithCommand:ACK withCamMode:DOWNLOADMODE];
        }
    }
    
    if (ACK.cmd == SDB_GET_BLOCK_NORMAL_PHOTOS_ACK) {
        
        if (self.socketMode == NORMALMODE) {
            [self ACKHandleWithCommand:ACK withCamMode:NORMALMODE];
        }
        if (self.socketMode == DOWNLOADMODE) {
            [self ACKHandleWithCommand:ACK withCamMode:DOWNLOADMODE];
        }
    }
    if (ACK.cmd == SDB_SET_RECV_OK_ACK) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFileList];
    }
    [self.socketManager receiveMessageWithTimeOut:-1];
}

- (void)didFinishConnectToHost
{
    if (self.timeOutInfo) {
        if ([(NSString *)[self.timeOutInfo objectForKey:@"CMD"] isEqualToString:@"CMDDownloadBatchFiles"]) {
            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDDownloadBatchFiles];
            [self executeTimeOutCounterWithCMD:@"CMDDownloadBatchFiles" withAmout:0];
        }
        if ([(NSString *)[self.timeOutInfo objectForKey:@"CMD"] isEqualToString:@"CMDDownloadRestFiles"]) {
            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDDownloadRestFiles((int)[self.timeOutInfo objectForKey:@"Number"])];
            [self executeTimeOutCounterWithCMD:@"CMDDownloadRestFiles" withAmout:(int)[self.timeOutInfo objectForKey:@"Number"]];
        }
    }
    else {
        if (self.imgClient.cameraMode == DOWNLOADMODE) {
            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (_firstTimeload) {
                _firstTimeload = NO;
                dispatch_async(dispatch_get_main_queue(), ^(){
                    PulseWaveController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PulseWaveController"];
                    [self presentViewController:controller animated:YES completion:nil];
                });
            }
            else {
                [self checkDownloading];
            }
        });
    }
}

- (void)didDisconnectSocket
{
    if (self.socketMode == DOWNLOADMODE) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncState" object:@"下载错误:socket断开"];
    }
}

- (void)didReceiveDevInfo:(DEV_INFO)decInfo
{
    
    NSString *camVer = [NSString stringWithFormat:@"%s", decInfo.dev_version];
    FirmwareManager *manager = [FirmwareManager sharedFirmwareManager];
    manager.camVerison = [NSString stringWithString:camVer];
    [manager saveFirmware];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    NSLog(@"download view controller received memory warning!");
}

- (void)didFinishSingleFileDownloadingWithImageData:(NSData *)imageData
{}

- (void)didLoseAlive
{}

- (void)didReceiveLensStatus:(LENS_PARAMS)lensStatus
{}

#pragma mark - ACK Handling

- (void)ACKHandleWithCommand:(CTL_MESSAGE_PACKET)command withCamMode:(CameraMode)cammode
{
    switch (command.state) {
            
        case SDB_STATE_UNKNOWN:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncState" object:@"下载错误:Unknown"];
            
            break;
            
        case SDB_STATE_SUCCESS:
            
            if (cammode == DOWNLOADMODE  && command.cmd == SDB_GET_NORMAL_PHOTO_COUNT_ACK) {
                if (self.socketManager.fileList.paramn[0] >= kBatchNumber) {
                    
                    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDDownloadBatchFiles];
                    [self executeTimeOutCounterWithCMD:@"CMDDownloadBatchFiles" withAmout:0];
                }
                if ( self.socketManager.fileList.paramn[0] < kBatchNumber && self.socketManager.fileList.paramn[0] > 0) {
                    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDDownloadRestFiles(self.socketManager.fileList.paramn[0])];
                    [self executeTimeOutCounterWithCMD:@"CMDDownloadRestFiles" withAmout:(int)self.socketManager.fileList.paramn[0]];
                }
                if (self.socketManager.fileList.paramn[0] == 0) {
                    NSLog(@"NO MORE PHOTOS");
                
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncState" object:NSLocalizedString(@"Synced", nil)];
                    
                    //下载完成后，清空超时信息
                    self.timeOutInfo = nil;
                    [self.timeOutTimer setFireDate:[NSDate distantFuture]];
                    [self.timeOutTimer invalidate];
                }
            }
            if (cammode == NORMALMODE && command.cmd == SDB_GET_NORMAL_PHOTO_COUNT_ACK) {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    
                    if (self.socketManager.fileList.paramn[0] == 0) {
                        if (self.menuBar) {
                            [ProgressHUD showError:NSLocalizedString(@"No Sync", nil) Interaction:YES];
                        }
                    }
                    else if (self.socketManager.fileList.paramn[0] != 0) {
                        
                        if (self.imgClient.imgPath.count > 0) {
                            self.imgPathBeforeDownloadedIndex = self.imgClient.imgPath.count;
                        }
                        else self.imgPathBeforeDownloadedIndex = self.imgClient.imgPath.count;
                        self.imgPathAfterDownloadedIndex = (NSUInteger)self.socketManager.fileList.paramn[0] + self.imgPathBeforeDownloadedIndex;
                        
                        NSString *msgString = [NSString stringWithFormat:@"%d %@？", (int)self.socketManager.fileList.paramn[0], NSLocalizedString(@"New Sync", nil)];
                        UIAlertView *syncAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New Photos", nil) message:msgString delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
                        [syncAlert show];
                        [self setUpItemBadgeValueWithNumber:[NSNumber numberWithInt:self.socketManager.fileList.paramn[0]]];
                    }
                });
            }
            
            break;
            
        case SDB_STATE_FAILED:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncState" object:@"下载错误:Failed"];
            
            break;
            
        case SDB_STATE_PARAMS_ERROR:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncState" object:@"下载错误:Params_Error"];
            break;
            
        case SDB_STATE_FILE_NOT_EXIST:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncState" object:@"下载错误:File_Not_Exist"];
            break;
            
        case SDB_DATA_SOCKET_NOT_EXIST:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncState" object:@"下载错误:Socket_Not_Exist"];
            break;
            
        case SDB_DATA_TRANSFOR_NOT_END:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncState" object:@"下载错误:Data_Transfor_Not_End"];
            break;
            
        case SDB_SERVER_NOT_READY:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncState" object:@"下载错误:Server_Not_Ready"];
            break;
            
        case SDB_STATE_NOT_SUPPT_IRIS_VALUE:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncState" object:@"下载错误:Not_Support_IRIS_Value"];
            break;
            
        default:
            break;
    }

}
#pragma mark - Time Out System

- (void)executeTimeOutCounterWithCMD:(NSString *)cmd withAmout:(int)amout
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
        [dict setObject:[NSString stringWithFormat:@"%d",amout] forKey:@"Number"];
        
        self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                             target:self
                                                           selector:@selector(timeOutHandle:)
                                                           userInfo:[dict copy]
                                                        repeats:NO];    
    });
}

- (void)timeOutHandle:(NSTimer *)timer
{
    if (!_finishDate) {
        
        if (!self.socketManager.isLost) {
            [self.socketManager tcpLingSocketConnectToHost];
            self.timeOutInfo = (NSDictionary *)[timer userInfo];
            //            [self.timeOutTimer setFireDate:[NSDate distantFuture]];
            //            [self.timeOutTimer invalidate];
        }
        else {
            [ProgressHUD showError:@"同步超时" Interaction:NO];
            [self.timeOutTimer invalidate];
        }
    }
}


#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button tapped index :%ld", (long)buttonIndex);
    if (buttonIndex == 1) {
        [self startDownloading];
        [self updateUIWithSyncMode:DOWNLOADMODE];
        [self unSetUpItemBadgeValue];
        //为了避免当用户下载照片同时在浏览照片界面时，下载发生异常断开，后退到同步界面点击同步下载后闪退的问题
        //if (self.imgClient.delegate == self) {
            //[self releasingInsertIndexPaths];
        //}
    }
}

- (void)dismissAlertView:(NSTimer*)timer {
    
    NSLog(@"Dismiss alert view");
    
    [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
    [self.imageButton setImage:nil forState:UIControlStateNormal];
    //[self.socketManager getFileList];
}

#pragma mark - Rotation

- (BOOL)shouldAutorotate
{
    return NO;
}

@end

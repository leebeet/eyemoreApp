//
//  rootScrollViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/4/1.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "RootScrollViewController.h"
#import "TCPSocketManager.h"
#import "BLAnimation.h"
#import "ProgressHUD.h"
#import "CameraSoundPlayer.h"
#import "SaveLoadInfoManager.h"
#import "PulseWaveController.h"
#import "CMDManager.h"
#import "Config.h"
#import "LoginViewController.h"
#import "ShareViewController.h"

#define kSelfieTime


@interface RootScrollViewController ()<UINavigationBarDelegate, UIBarPositioningDelegate>

@property (weak,   nonatomic) IBOutlet UIView          *pictureIndexView;

@property (strong, nonatomic)          NSTimer         *shootTimer;
@property (strong, nonatomic)          UIDevice        *device;


@property (strong, nonatomic)          UILabel         *LSCurrentIndexLabel;
@property (strong, nonatomic)          UILabel         *LSTotalIndexLabel;
@property (strong, nonatomic)          UILabel         *LSSymbolLabel;
@property (strong, nonatomic)          UILabel         *symbolLabel;

@property (strong, nonatomic)          UILabel         *jpgIndexLabel;

@property (strong, nonatomic) MRoundedButton           *roundSaveButton;
@property (strong, nonatomic) MRoundedButton           *roundDelButton;
@property (strong, nonatomic) MRoundedButton           *backButton;

@property (assign, nonatomic) NSUInteger                doubleDismissFlag;
@property (assign, nonatomic) UIDeviceOrientation       lastOrientation;

@property (strong, nonatomic) UIToolbar                *topToolBar;
@property (strong, nonatomic) UIToolbar                *bottomToolBar;
@property (strong, nonatomic) UIView                   *detailView;

@end

@implementation RootScrollViewController

//static RootScrollViewController *instance = nil;
//+ (RootScrollViewController *)sharedRootScrollViewController
//{
////    static RootScrollViewController *instance = nil;
////    if (instance == nil) {
////        instance = [[RootScrollViewController alloc] init];
////    }
//    return instance;
//}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"root scroll view controller appear");
    [super viewWillAppear:YES];
    
    [self updateUI];

    //判断相机操作模式，开启／禁止相应功能
    if (self.shootMode != DOWNLOAD_SYNCING_MODE) {
        self.socketManager.delegate = self;
    }
    if (self.shootMode == SELFIE_MODE) {
        [self.shootTimer invalidate];
        self.shootTimer = [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector(antoSelfieShoot) userInfo:nil repeats:YES];
    }
    if (self.shootMode == LIVEVIEW_MODE) {
        //实时取景入口进入该页面时，禁止拍立得功能
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"view will disappear");
    [super viewWillDisappear:YES];
    //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    self.view.backgroundColor = [UIColor colorWithRed:251./255. green:32./255. blue:7./255. alpha:1];
    
    [self.imageView.timer invalidate];
    [self.device endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"RotateDetecting" object:nil];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"RootScrollViewConttrollerWillDisappear" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ImageAlbumManager *albumManager = [ImageAlbumManager sharedImageAlbumManager];
    [albumManager createCustomAlbumWithName:@"eyemore Album"];

    self.imgClient = [ImageClient sharedImageClient];
    self.imgClient.delegate = self;
    
    self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    
    if (self.shootMode != DOWNLOAD_SYNCING_MODE) {
        self.socketManager.delegate = self;
    }

    if (!self.socketManager.isLost && self.imgClient.cameraMode == SYNCMODE) {
        NSLog(@"fire timer root scroll view controller");

    }
    
    CGPoint center;
    center = self.view.center;
    if (center.x > center.y) {
        self.imageView = [[BLSeeImageView alloc] initWithDirection:UIDeviceOrientationLandscapeRight];
    }
    else self.imageView = [[BLSeeImageView alloc] initWithDirection:UIDeviceOrientationPortrait];
    self.imageView.center = center;
    NSLog(@"root view controller did load with last image index:%lu", (unsigned long)self.imgClient.lastImageIndex);
    [self.imageView scanImagesMode:self.scrollArray WithImageIndex:self.imgClient.lastImageIndex];
    [self.view addSubview:self.imageView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAllButtons)];
    [self.imageView addGestureRecognizer:singleTap];

    self.isHiden = YES;
    
    self.indexView = [[UIView alloc]init];
    
    CGRect labelRect2 = CGRectMake(self.view.bounds.size.width/10.0 * 9,
                                   self.view.bounds.size.height/10.0 * 0.5,
                                   104,
                                   34);
    self.indexView.frame = labelRect2;
    self.indexView.center = CGPointMake(self.view.bounds.size.width/10.0 * 8.6,
                                        self.view.bounds.size.height/10.0 * 0.5);
    
    self.LSCurrentIndexLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 8, 31, 20)];
    self.LSTotalIndexLabel   = [[UILabel alloc] initWithFrame:CGRectMake(58, 8, 31, 20)];
    self.LSSymbolLabel       = [[UILabel alloc] initWithFrame:CGRectMake(48, 8, 8, 18)];
    //BL modified
    self.symbolLabel         = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 50, 20, 100, 30)];
    
    self.LSCurrentIndexLabel.text = @"000";
    self.LSTotalIndexLabel.text   = @"000";
    self.LSSymbolLabel.text       = @"/";
    //BL modified
    self.symbolLabel.text         = @"0 of 0";
    
    self.LSCurrentIndexLabel.font = [UIFont systemFontOfSize:15.0];
    self.LSTotalIndexLabel.font   = [UIFont systemFontOfSize:15.0];
    self.LSSymbolLabel.font       = [UIFont systemFontOfSize:15.0];
    //BL modified
    self.symbolLabel.font         = [UIFont systemFontOfSize:17.0];
    
    self.LSCurrentIndexLabel.textAlignment = NSTextAlignmentRight;
    self.LSTotalIndexLabel.textAlignment    = NSTextAlignmentLeft;
    self.LSSymbolLabel.textAlignment       = NSTextAlignmentCenter;
    //BL modified
    self.symbolLabel.textAlignment       = NSTextAlignmentCenter;
    
    self.LSCurrentIndexLabel.textColor = [UIColor whiteColor];
    self.LSTotalIndexLabel.textColor = [UIColor whiteColor];
    self.LSSymbolLabel.textColor = [UIColor whiteColor];
    //BL modified
    self.symbolLabel.textColor = [UIColor whiteColor];
    
    [self.indexView addSubview:self.LSCurrentIndexLabel];
    [self.indexView addSubview:self.LSTotalIndexLabel];
    [self.indexView addSubview:self.LSSymbolLabel];
    
    //[self.view addSubview:self.indexView];
    //BL modified
    [self.view addSubview:self.symbolLabel];
    
    [self           addObserver:self forKeyPath:@"imgPathCount"     options:NSKeyValueObservingOptionNew context:nil];
    [self.imageView addObserver:self forKeyPath:@"currentIndex"     options:NSKeyValueObservingOptionNew context:nil];
    [self.imageView addObserver:self forKeyPath:@"shouldEnterSleep" options:NSKeyValueObservingOptionNew context:nil];
    
    self.totalIndexLabel.text        = [NSString stringWithFormat:@"%lu", (unsigned long)self.scrollArray.count];
    self.LSTotalIndexLabel.text      = [NSString stringWithFormat:@"%lu", (unsigned long)self.scrollArray.count];
    self.currentImageIndexLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[self.imageView returnCurrentImageIndex] + 1];
    self.LSCurrentIndexLabel.text    = [NSString stringWithFormat:@"%lu", (unsigned long)[self.imageView returnCurrentImageIndex] + 1];
    //BL modified
    self.symbolLabel.text            = [NSString stringWithFormat:@"%lu of %lu", (unsigned long)[self.imageView returnCurrentImageIndex] + 1, (unsigned long)self.scrollArray.count];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modeDetectingFore)     name:@"EnterForeground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modeDetectingBack)     name:@"EnterBackground" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncingStateChangged:) name:@"SyncState" object:nil];
    [self.takeButton setHidden:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(shouldAutorotateTimer) userInfo:nil repeats:NO];
        //[self initAllButton];
        [self setUpTopToolBar];
        [self setUpBottomToolBar];
        //[self setUpDetailView];
    });
    
}

- (void)setUpTopToolBar
{
    self.topToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 52)];
    [self.topToolBar setTranslucent:YES];
    self.topToolBar.barStyle = UIBarStyleBlack;
    self.topToolBar.tintColor = [UIColor whiteColor];
    [self.view addSubview:self.topToolBar];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissController)];
    UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *btn3 = [[UIBarButtonItem alloc] initWithCustomView:self.symbolLabel];
    UIBarButtonItem *btn4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    NSArray *arr1=[[NSArray alloc]initWithObjects:btn1, btn2, btn3, btn4, nil];
    [self.topToolBar setItems:arr1 animated:YES];
}

- (void)setUpBottomToolBar
{
    
    self.bottomToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 52, self.view.frame.size.width, 52)];
    //self.bottomToolBar.barTintColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1];
    self.bottomToolBar.tintColor = [UIColor whiteColor];
    [self.bottomToolBar setTranslucent:YES];
    self.bottomToolBar.barStyle = UIBarStyleBlack;
    //[self.bottomToolBar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.view addSubview:self.bottomToolBar];
    
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [saveBtn setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
    //[saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
//    UIButton *DeleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
//    [DeleBtn setImage:[UIImage imageNamed:@"deleteTrash"] forState:UIControlStateNormal];
//    [DeleBtn setTitle:@"删除" forState:UIControlStateNormal];
//    [DeleBtn addTarget:self action:@selector(removeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
    UIBarButtonItem *btn3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonTapped:)];
    UIBarButtonItem *btn2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *btn4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(removeButtonTapped:)];
    //UIBarButtonItem *btn4 = [[UIBarButtonItem alloc] initWithCustomView:DeleBtn];
    btn1.title = @"save";
    NSArray *arr1=[[NSArray alloc]initWithObjects:btn1, btn2, btn3, btn2, btn4, nil];
    [self.bottomToolBar setItems:arr1 animated:YES];

}

- (void)setUpDetailView
{
    self.detailView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 52 - 130, self.view.frame.size.width, 130)];
    self.detailView.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:0.7];
    self.detailView.alpha = 0.9;
    self.jpgIndexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 130)];
    self.jpgIndexLabel.textAlignment = NSTextAlignmentLeft;
    self.jpgIndexLabel.font = [UIFont systemFontOfSize:15.0];
    self.jpgIndexLabel.textColor = [UIColor whiteColor];
    self.jpgIndexLabel.text = [NSString stringWithFormat: @"      INFO\n      Name: %@\n      Index No.%@\n      Date: ...\n      Location: ...\n      Taken by Device: eyemore camera",[self.imageView returnCurrentImagePath],[self.imgClient extractImageIndexWithData:[self.imgClient getImageDataForKey:[self.imageView returnCurrentImagePath]]]];
    [self.jpgIndexLabel setNumberOfLines:6];
    [self.detailView addSubview:self.jpgIndexLabel];
    [self.view addSubview:self.detailView];
}

//- (void)initAllButton
//{
//
//    CGFloat buttonSize = 80;
//    CGRect buttonRect1 = CGRectMake(self.view.bounds.size.width/10.0 * 1,
//                                   self.view.bounds.size.height/10.0 * 8.5,
//                                   buttonSize,
//                                   buttonSize);
//    self.roundSaveButton = [[MRoundedButton alloc] initWithFrame:buttonRect1
//                                                       buttonStyle:MRoundedButtonDefault
//                                              appearanceIdentifier:[NSString stringWithFormat:@"%d", 1]];
//    self.roundSaveButton.backgroundColor = [UIColor clearColor];
//    self.roundSaveButton.textLabel.text = @"保存";
//    self.roundSaveButton.textLabel.font = [UIFont fontWithName:@"STHeitiJ-Light" size:25];
//    self.roundSaveButton.imageView.image = [UIImage imageNamed:@"download2"];
//    [self.roundSaveButton addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.roundSaveButton];
//    
//    
//    
//    
//    CGRect buttonRect2 = CGRectMake(self.view.bounds.size.width/10.0 * 7,
//                                    self.view.bounds.size.height/10.0 * 8.5,
//                                    buttonSize,
//                                    buttonSize);
//    self.roundDelButton = [[MRoundedButton alloc] initWithFrame:buttonRect2
//                                                     buttonStyle:MRoundedButtonDefault
//                                            appearanceIdentifier:[NSString stringWithFormat:@"%d", 1]];
//    self.roundDelButton.backgroundColor = [UIColor clearColor];
//    self.roundDelButton.textLabel.text = @"删除";
//    self.roundDelButton.textLabel.font = [UIFont fontWithName:@"STHeitiJ-Light" size:25];
//    self.roundDelButton.imageView.image = [UIImage imageNamed:@"12-delete"];
//    [self.roundDelButton addTarget:self action:@selector(removeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.roundDelButton];
//    
//    
//    
//    
//    CGFloat buttonSize2 = 40;
//    CGRect buttonRect3 = CGRectMake(self.view.bounds.size.width/10.0 * 1.0,
//                                    self.view.bounds.size.height/10.0 * 0.5,
//                                    buttonSize2,
//                                    buttonSize2);
//    self.backButton = [[MRoundedButton alloc] initWithFrame:buttonRect3
//                                                buttonStyle:MRoundedButtonCentralImage
//                                       appearanceIdentifier:[NSString stringWithFormat:@"%d", 3]];
//    self.backButton.center = CGPointMake(self.view.bounds.size.width/10.0 * 1.0,
//                                         self.view.bounds.size.height/10.0 * 0.5);
//    //self.roundDelButton.textLabel.text = @"返回";
//    //self.roundDelButton.textLabel.font = [UIFont fontWithName:@"STHeitiJ-Light" size:25];
//    self.backButton.imageView.image = [UIImage imageNamed:@"104-Back"];
//    [self.backButton addTarget:self action:@selector(returnButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view insertSubview:self.backButton aboveSubview:self.imageView];
//    
//    
//    if (self.imgClient.isShownJpgInfo) {
//        self.jpgIndexLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/10.0 * 1,
//                                                                       self.view.bounds.size.height/10.0 * 1,
//                                                                       200,
//                                                                       30)];
//        
//        self.jpgIndexLabel.center = CGPointMake(self.view.frame.size.width / 2, self.view.bounds.size.height/10.0 * 0.5);
//        self.jpgIndexLabel.text = [NSString stringWithFormat:@"当前图片索引: %@",[self.imgClient extractImageIndexWithData:
//                                                                            [self.imgClient getImageDataForKey:[self.imageView returnCurrentImagePath]]]];
//        self.jpgIndexLabel.textAlignment = NSTextAlignmentCenter;
//        self.jpgIndexLabel.font = [UIFont systemFontOfSize:15];
//        self.jpgIndexLabel.textColor = [UIColor whiteColor];
//        [self setUpShadowWithView:self.jpgIndexLabel];
//        [self.view addSubview:self.jpgIndexLabel];
//    }
//}

- (void)shouldAutorotateTimer
{
    NSLog(@"timer is in, started orientation : %ld", (long)self.device.orientation);
    
    self.autoRotate = YES; 
    self.device = [UIDevice currentDevice];
    [self.device beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    
        self.view.backgroundColor = [UIColor colorWithRed:26./255. green:26./255. blue:30./255. alpha:1];
        
    } completion:^(BOOL complete){}];
    [self deviceOrientationDidChange];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deviceOrientationDidChange
{
    NSLog(@"Orientation did change %ld ", (long)self.device.orientation);
        switch (self.device.orientation) {
            case UIDeviceOrientationFaceUp:
                NSLog(@"螢幕朝上平躺");
                if (self.view.center.x > self.view.center.y) {
                    
                    //[self setImageViewToScreenCenterWithView:self.imageView];
                    //self.imageView.transform = CGAffineTransformMakeRotation((CGFloat)(90 * M_PI / 180.0));
                    [self updateUIToLandscape];
                }
                break;
                
            case UIDeviceOrientationFaceDown:
                NSLog(@"螢幕朝下平躺");
                break;
                
            //系統無法判斷目前Device的方向，有可能是斜置
            case UIDeviceOrientationUnknown:
                NSLog(@"未知方向");
                break;
                
            case UIDeviceOrientationLandscapeLeft:
                NSLog(@"螢幕向左橫置");
                //[self setImageViewToScreenCenterWithView:self.imageView];
                //self.imageView.transform = CGAffineTransformMakeRotation((CGFloat)(90 * M_PI / 180.0));
                [self updateUIToLandscape];
                
                if (self.lastOrientation == UIDeviceOrientationPortrait || self.lastOrientation == UIDeviceOrientationLandscapeRight) {
                    [BLAnimation scaleRotationAnimationWithObject:self.roundSaveButton withAngle:2.5 * M_PI ];
                    [BLAnimation scaleRotationAnimationWithObject:self.roundDelButton withAngle:2.5 * M_PI ];
                    [BLAnimation scaleRotationAnimationWithObject:self.backButton withAngle:1.5 * M_PI ];
                    [BLAnimation scaleRotationAnimationWithObject:self.indexView withAngle:2.5 * M_PI];
                }
                self.lastOrientation = UIDeviceOrientationLandscapeLeft;
                
                break;
                
            case UIDeviceOrientationLandscapeRight:
                NSLog(@"螢幕向右橫置");
                //[self setImageViewToScreenCenterWithView:self.imageView];
                //self.imageView.transform = CGAffineTransformMakeRotation((CGFloat)(90 * M_PI / 180.0));
                [self updateUIToLandscape];
                //self.imageView.layer.transform = CATransform3DMakeRotation((M_PI* 180)/180,0,0,0);
                
                if (self.lastOrientation == UIDeviceOrientationLandscapeLeft || self.lastOrientation == UIDeviceOrientationPortrait) {
                    [BLAnimation scaleRotationAnimationWithObject:self.roundSaveButton withAngle:-2.5 * M_PI];
                    [BLAnimation scaleRotationAnimationWithObject:self.roundDelButton withAngle:-2.5 * M_PI];
                    [BLAnimation scaleRotationAnimationWithObject:self.backButton withAngle:-2.5 * M_PI];
                    [BLAnimation scaleRotationAnimationWithObject:self.indexView withAngle:-2.5 * M_PI];
                }
                self.lastOrientation = UIDeviceOrientationLandscapeRight;
                
                break;
                
            case UIDeviceOrientationPortrait:
                NSLog(@"螢幕直立");
                //self.imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
                //[self setImageViewToScreenCenterWithView:self.imageView];
                //self.imageView.transform = CGAffineTransformMakeRotation((CGFloat)(0 * M_PI / 180.0));
                [self updateUIToPortrait];
                
                if (self.lastOrientation == UIDeviceOrientationLandscapeLeft || self.lastOrientation == UIDeviceOrientationLandscapeRight) {
                    
                    [BLAnimation scaleRotationAnimationWithObject:self.roundSaveButton withAngle:2 * M_PI];
                    [BLAnimation scaleRotationAnimationWithObject:self.roundDelButton withAngle:2 * M_PI];
                    [BLAnimation scaleRotationAnimationWithObject:self.backButton withAngle:2 * M_PI];
                    [BLAnimation scaleRotationAnimationWithObject:self.indexView withAngle:2 * M_PI];
                }
                self.lastOrientation = UIDeviceOrientationPortrait;
                
                break;
                                
            case UIDeviceOrientationPortraitUpsideDown:
                NSLog(@"螢幕直立，上下顛倒");
                break;
                
            default:
                NSLog(@"無法辨識");    
                break;    
        }
}

- (void)setImageViewToScreenCenterWithView:(BLSeeImageView *)imgView
{
    CGPoint center;
    center = self.view.center;
    [imgView setCenter:center];
    NSLog(@"center : x = %f, y = %f", center.x, center.y);
}

- (void)updateUI
{
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/3, self.view.bounds.size.height/5, 50, 50)];
    [deleteButton setImage:[UIImage imageNamed:@"icon_del_gray"] forState:UIControlStateNormal];
    [deleteButton setHidden:YES];
    [self.view addSubview:deleteButton];
    self.roundSaveButton.imageView.image = [UIImage imageNamed:@"download2"];
    self.roundDelButton.imageView.image  = [UIImage imageNamed:@"12-delete"];
    
    if (self.imgClient.cameraMode == SYNCMODE) {
        //self.device = [UIDevice currentDevice];
        //[self deviceOrientationDidChange];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    //self.view.backgroundColor = [UIColor colorWithRed:251./255. green:32./255. blue:7./255. alpha:1];
    
    //[NSTimer scheduledTimerWithTimeInterval:0.8f target:self selector:@selector(hideAllButtons) userInfo:nil repeats:NO];
}

- (void)updateUIToLandscape
{
//    CGRect buttonRect1 = CGRectMake(self.view.bounds.size.width/10.0 * 1,
//                                    self.view.bounds.size.height/10.0 * 8.5,
//                                    80,
//                                    80);
//    self.roundSaveButton.frame  = buttonRect1;
//    self.roundSaveButton.center = CGPointMake(self.view.bounds.size.width/10.0 * 1,
//                                              self.view.bounds.size.height/10.0 * 8.5);
//    
//    CGRect buttonRect2 = CGRectMake(self.view.bounds.size.width/10.0 * 9,
//                                    self.view.bounds.size.height/10.0 * 8.5,
//                                    80,
//                                    80);
//    self.roundDelButton.frame  = buttonRect2;
//    self.roundDelButton.center = CGPointMake(self.view.bounds.size.width/10.0 * 9,
//                                             self.view.bounds.size.height/10.0 * 8.5);
//    
//    CGRect buttonRect3 = CGRectMake(self.view.bounds.size.width/10.0 * 0.5,
//                                    self.view.bounds.size.height/10.0 * 0.85,
//                                    40,
//                                    40);
//    self.backButton.frame  = buttonRect3;
//    self.backButton.center = CGPointMake(self.view.bounds.size.width/10.0 * 0.5,
//                                         self.view.bounds.size.height/10.0 * 0.85);
    
}

- (void)updateUIToPortrait
{
    CGRect buttonRect1 = CGRectMake(self.view.bounds.size.width/10.0 * 2,
                                    self.view.bounds.size.height/10.0 * 9,
                                    80,
                                    80);
    self.roundSaveButton.frame  = buttonRect1;
    self.roundSaveButton.center = CGPointMake(self.view.bounds.size.width/10.0 * 2,
                                              self.view.bounds.size.height/10.0 * 9);
    
    CGRect buttonRect2 = CGRectMake(self.view.bounds.size.width/10.0 * 8,
                                    self.view.bounds.size.height/10.0 * 9,
                                    80,
                                    80);
    self.roundDelButton.frame  = buttonRect2;
    self.roundDelButton.center = CGPointMake(self.view.bounds.size.width/10.0 * 8,
                                             self.view.bounds.size.height/10.0 * 9);
    
    CGRect buttonRect3 = CGRectMake(self.view.bounds.size.width/10.0 * 1,
                                    self.view.bounds.size.height/10.0 * 0.5,
                                    40,
                                    40);
    self.backButton.frame  = buttonRect3;
    self.backButton.center = CGPointMake(self.view.bounds.size.width/10.0 * 1,
                                         self.view.bounds.size.height/10.0 * 0.5);
    
//    CGRect labelRect1 = CGRectMake(self.view.bounds.size.width/10.0 * 9,
//                                    self.view.bounds.size.height/10.0 * 0.5,
//                                    40,
//                                    40);
//    self.totalIndexLabel.frame = labelRect1;
//    self.totalIndexLabel.center = CGPointMake(self.view.bounds.size.width/10.0 * 9,
//                                              self.view.bounds.size.height/10.0 * 0.5);
//    
//    CGRect labelRect2 = CGRectMake(self.view.bounds.size.width/10.0 * 9,
//                                   self.view.bounds.size.height/10.0 * 0.5,
//                                   104,
//                                   34);
//    self.indexView.frame = labelRect2;
//    self.indexView.center = CGPointMake(self.view.bounds.size.width/10.0 * 8.6,
//                                            self.view.bounds.size.height/10.0 * 0.5);
    
}

- (void)antoSelfieShoot
{
    static int i = 0;
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDRemoteSnapshot(1)];
    i ++;
    if (i == 14) {
        i = 0;
        [self.shootTimer invalidate];
        [CameraSoundPlayer playSound];
    }
}

#pragma mark - Buttons Tapping events

- (void)shareButtonTapped:(id)sender {
    
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"share" bundle:nil];
        ShareViewController *shareVC = [storyboard instantiateViewControllerWithIdentifier:@"ShareViewController"];
        shareVC.uploadData = [self.imgClient getImageDataForKey:[self.imageView  returnCurrentImagePath]];
        [self presentViewController:shareVC animated:YES completion:nil];
    }
}


- (IBAction)saveButtonTapped:(id)sender {
    
    [(UIButton *)sender setEnabled:NO];
    //UIImage *image = [UIImage imageWithContentsOfFile:[self.imageView returnCurrentImagePath]];
    //UIImage *image = [self.imgClient getImageForKey:[self.imageView returnCurrentImagePath]];
    ImageAlbumManager *albumManager = [ImageAlbumManager sharedImageAlbumManager];
    NSData *imageData = [self.imgClient getImageDataForKey:[self.imageView  returnCurrentImagePath]];
    
    //dispatch_async(dispatch_get_global_queue(0, 0), ^(){
        [albumManager saveToAlbumWithMetadata:nil
                                    imageData:imageData
                              customAlbumName:@"eyemore Album"
                              completionBlock:^{
                                  [(UIButton *)sender setEnabled:YES];
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"AlbumUpdation" object:nil];
                              }
                                 failureBlock:^(NSError *error)
         {
             //处理添加失败的方法显示alert让它回到主线程执行，不然那个框框死活不肯弹出来
             dispatch_async(dispatch_get_main_queue(), ^{
                 //添加失败一般是由用户不允许应用访问相册造成的，这边可以取出这种情况加以判断一下
                 if([error.localizedDescription rangeOfString:@"User denied access"].location != NSNotFound ||[error.localizedDescription rangeOfString:@"用户拒绝访问"].location!=NSNotFound){
                     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:error.localizedDescription
                                                                  message:error.localizedFailureReason
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                        otherButtonTitles: nil];
                     [alert show];
                 }
             });
         }];
    //});
    
    NSString *path = [self.imageView removeCurrentImage];
    //if (self.imgClient.cameraMode == SYNCMODE) {
        [self.imgClient.imgPath removeObject:path];
        self.imgPathCount = self.imgClient.imgPath.count;
        [SaveLoadInfoManager saveAppInfoWithClient:self.imgClient];
    
        if (self.imgClient.imgPath.count == 0) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    //}
    [self.imgClient removeImageDataWithPath:path WithCameraMode:SYNCMODE];
    
    [self.imageView reMonitoringSleeping];
    
    NSLog(@"remove image at path : %@", path);
}
- (IBAction)removeButtonTapped:(id)sender {
    
    NSString *path = [self.imageView removeCurrentImage];

    [self.imgClient.imgPath removeObject:path];
    self.imgPathCount = self.imgClient.imgPath.count;

    [self.imgClient removeImageDataWithPath:path WithCameraMode:SYNCMODE];
    [SaveLoadInfoManager saveAppInfoWithClient:self.imgClient];
    if (self.imgClient.imgPath.count == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AlbumUpdation" object:nil];
    [self.imageView reMonitoringSleeping];

}
- (IBAction)takeButtonTapped:(id)sender {

    //[self.socketManager downloadOneFile];
}
- (IBAction)returnButtonTapped:(id)sender {
    
    self.doubleDismissFlag = 0;
    [self dismissController];
}

- (void)dismissController
{
    self.imgClient.currentPath    = [self.imageView returnCurrentImagePath];
    self.imgClient.lastImageIndex = [self.imageView returnCurrentImageIndex];
    
    if (self.imgClient.cameraMode == SYNCMODE) {
        self.imgClient.syncLeavingFlag = [self.imageView returnCurrentImageIndex];
    }
    if (self.imgClient.cameraMode == DOWNLOADMODE) {
        self.imgClient.downloadLeavingFlag = [self.imageView returnCurrentImageIndex];
    }
    NSLog(@"dismiss view controller did load with last image index:%lu", (unsigned long)self.imgClient.lastImageIndex);
    
    [self dismissViewControllerAnimated:YES completion:(^(){
        if (self.shootMode == SELFIE_MODE) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setShootModeToSelfie" object:nil];
        }
    })];
}

- (void)hideAllButtons
{
    NSLog(@"single tapped，isHiden %@", self.isHiden ? @"Yes" : @"no");
    if (self.isHiden) {
        
        NSArray *array = [[NSArray alloc] initWithObjects:  (id)self.LSCurrentIndexLabel, (id)self.LSTotalIndexLabel,  (id)self.LSSymbolLabel, (id)self.roundSaveButton, (id)self.roundDelButton, (id)self.backButton, self.jpgIndexLabel, nil];
        [BLAnimation revealViews:array WithBLAnimation:BLEffectFadeOut completion:^(BOOL finish){
            
            [self.returnButton setHidden:YES];

            //Lanscape items
            [self.LSSymbolLabel          setHidden:YES];
            [self.LSTotalIndexLabel      setHidden:YES];
            [self.LSCurrentIndexLabel    setHidden:YES];
            
            [self.roundDelButton  setUserInteractionEnabled:NO];
            [self.roundSaveButton setUserInteractionEnabled:NO];
            [self.backButton      setUserInteractionEnabled:NO];
            
        }];
        [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
            self.topToolBar.alpha = 0.0;
            self.bottomToolBar.alpha = 0.0;
            self.detailView.alpha = 0;
            
        } completion:^(BOOL finished){
            [self.topToolBar setHidden:YES];
            [self.bottomToolBar setHidden:YES];
            
        }];
        self.isHiden = NO;
    }
    else {
        [self.returnButton           setHidden:NO];

        //Lanscape Items
        [self.LSSymbolLabel          setHidden:NO];
        [self.LSTotalIndexLabel      setHidden:NO];
        [self.LSCurrentIndexLabel    setHidden:NO];
        
        NSArray *array = [[NSArray alloc] initWithObjects: (id)self.LSCurrentIndexLabel, (id)self.LSTotalIndexLabel, (id)self.LSSymbolLabel, (id)self.roundSaveButton, (id)self.roundDelButton, (id)self.backButton, self.jpgIndexLabel,nil];
        [BLAnimation revealViews:array WithBLAnimation:BLEffectFadeIn completion:nil];
        
        [self.roundDelButton setUserInteractionEnabled:YES];
        [self.roundSaveButton setUserInteractionEnabled:YES];
        [self.backButton setUserInteractionEnabled:YES];
        
        [UIView animateWithDuration:0.3f delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(){
            self.topToolBar.alpha = 1.0;
            self.bottomToolBar.alpha = 1.0;
            self.detailView.alpha = 0.9;
            
        } completion:^(BOOL finished){
            
        }];
        [self.topToolBar setHidden:NO];
        [self.bottomToolBar setHidden:NO];
        self.isHiden = YES;
    }
}

- (void)scaleImageView:(id)sender
{
    if (self.imageView.zoomScale == self.imageView.minimumZoomScale) {
        // Zoom in
        CGPoint center = [(UITapGestureRecognizer *)sender locationInView:self.imageView];
        CGSize size = CGSizeMake(self.imageView.bounds.size.width / self.imageView.maximumZoomScale,
                                 self.imageView.bounds.size.height / self.imageView.maximumZoomScale);
        CGRect rect = CGRectMake(center.x - (size.width / 2.0), center.y - (size.height / 2.0), size.width, size.height);
        [self.imageView zoomToRect:rect animated:YES];
    }
    else {
        // Zoom out
        [self.imageView zoomToRect:self.imageView.bounds animated:YES];
    }
}

#pragma mark - UIAlert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *path = [self.imageView removeCurrentImage];
        if (self.imgClient.cameraMode == SYNCMODE) {
            [self.imgClient.syncImgPath removeObject:path];
            self.imgPathCount = self.imgClient.imgPath.count;
        }
        if (self.imgClient.cameraMode == DOWNLOADMODE) {
            [self.imgClient.imgPath removeObject:path];
            self.imgPathCount = self.imgClient.imgPath.count;
        }
        if (self.imgClient.cameraMode == SELFIEMODE) {
            [self.imgClient.selfieImgPath removeObject:path];
            self.imgPathCount = self.imgClient.imgPath.count;
        }
        [self.imgClient.imgCache removeImageForKey:path fromDisk:YES withCompletion:nil];
    }
    if (self.imgClient.syncImgPath.count == 0 && self.imgClient.cameraMode == SYNCMODE) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if (self.imgClient.imgPath.count == 0 && self.imgClient.cameraMode == DOWNLOADMODE) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if (self.imgClient.selfieImgPath.count == 0 && self.imgClient.cameraMode == SELFIEMODE) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dismissAlertView:(NSTimer*)timer {
    
    NSLog(@"Dismiss alert view");
    [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
    NSString *path = [self.imageView removeCurrentImage];
    if (self.imgClient.cameraMode == SYNCMODE) {
        [self.imgClient.syncImgPath removeObject:path];
        self.imgPathCount = self.imgClient.imgPath.count;
        if (self.imgClient.syncImgPath.count == 0) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    if (self.imgClient.cameraMode == DOWNLOADMODE) {
        [self.imgClient.imgPath removeObject:path];
        self.imgPathCount = self.imgClient.imgPath.count;
        if (self.imgClient.imgPath.count == 0) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    if (self.imgClient.cameraMode == SELFIEMODE) {
        [self.imgClient.selfieImgPath removeObject:path];
        self.imgPathCount = self.imgClient.imgPath.count;
        if (self.imgClient.selfieImgPath.count == 0) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    [self.imgClient.imgCache removeImageForKey:path fromDisk:YES withCompletion:nil];
    NSLog(@"remove image at path : %@", path);
}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"imgPathCount"]) {
        self.totalIndexLabel.text        = [NSString stringWithFormat:@"%lu", (unsigned long)self.imgPathCount];
        self.LSTotalIndexLabel.text      = [NSString stringWithFormat:@"%lu", (unsigned long)self.imgPathCount];
        //BL modified
        self.symbolLabel.text            = [NSString stringWithFormat:@"%lu of %lu", (unsigned long)self.imageView.currentIndex + 1, (unsigned long)self.imgPathCount ];

    }
    if ([keyPath isEqualToString:@"currentIndex"]) {
        self.currentImageIndexLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.imageView.currentIndex + 1];
        self.LSCurrentIndexLabel.text    = [NSString stringWithFormat:@"%lu", (unsigned long)self.imageView.currentIndex + 1];
        //BL modified
        self.symbolLabel.text            = [NSString stringWithFormat:@"%lu of %lu", (unsigned long)self.imageView.currentIndex + 1, (unsigned long)self.imgClient.imgPath.count ];
        //update jpg index label
        self.jpgIndexLabel.text = [NSString stringWithFormat: @"      INFO\n      Name: %@\n      Index No.%@\n      Date: ...\n      Location: ...\n      Taken by Device: eyemore camera",[self.imageView returnCurrentImagePath],[self.imgClient extractImageIndexWithData:[self.imgClient getImageDataForKey:[self.imageView returnCurrentImagePath]]]];
    }
    if ([keyPath isEqualToString:@"shouldEnterSleep"]) {
        if (self.imageView.shouldEnterSleep && self.imgClient.cameraMode == SYNCMODE) {
            [self dismissController];
        }
        else {
        }
    }
}

-(void)dealloc
{
    [self           removeObserver:self forKeyPath:@"imgPathCount"];
    [self.imageView removeObserver:self forKeyPath:@"currentIndex"];
    [self.imageView removeObserver:self forKeyPath:@"shouldEnterSleep"];
}

//- (void)viewWillAppearWithLanscape
//{
//    self.isPresentingInLanscape = YES;
//    NSLog(@"is presenting in lanscape");
//}

- (void)setUpShadowWithView:(UIView *)view
{
    //设置阴影
    view.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.8].CGColor;
    view.layer.shadowOffset= CGSizeMake(0, 0);
    view.layer.shadowOpacity = 0.8;
    view.layer.shadowRadius = 5;
}

#pragma mark - TCP Socket Manager Delegate

- (void)didFinishSingleFileDownloadingWithImageData:(NSData *)imageData
{
    
    [self.imgClient storeSingleImageWithData:imageData];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        if (self.imgClient.cameraMode == SYNCMODE) {
            //NSLog(@"sync image path count: %lu", (unsigned long)self.imgClient.syncImgPath.count);
            self.imgPathCount = self.imgClient.imgPath.count;
            [self.imageView addImageWithPath:self.imgClient.imgPath];
        }
        if (self.imgClient.cameraMode == DOWNLOADMODE) {
            
            self.imgPathCount = self.imgClient.imgPath.count;
            [self.imageView addImageWithPath:self.imgClient.imgPath];
        }
        if (self.imgClient.cameraMode == SELFIEMODE) {
            
            self.imgPathCount = self.imgClient.imgPath.count;
            [self.imageView addImageWithPath:self.imgClient.imgPath];
        }
        
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDReceiveOInMode(0)];
        [self.socketManager receiveMessageWithTimeOut:-1];
        
        if (self.shootMode == SYNC_MODE) {
            [CameraSoundPlayer playSound];
        }
        
        if (self.isHiden) {
            [self hideAllButtons];
        }
    });
    //[SaveLoadInfoManager saveAppInfoWithClient:self.imgClient];
    NSLog(@"did finish download image and display...");

}


- (void)didFinishConnectToHost
{

    //此界面下，如果连续滑动图片，导致心跳包超时，为不影响体验，去掉连接成功的提示。导致原因：初步认定滑动图片时，导致心跳包的线程阻塞而超时
    NSLog(@"*****************************************************************");
    dispatch_async(dispatch_get_main_queue(), ^(){
        //[ProgressHUD showSuccess:@"连接成功" Interaction:NO];
    });
    if (self.imgClient.cameraMode == SYNCMODE && !self.socketManager.isLost) {
        
        //self.isConnectedHost = YES;
        NSLog(@"did connect to host in root scroll controller");
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToDDR];
        
    }
}

- (void)didDisconnectSocket
{}

- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command
{
    [self.socketManager receiveMessageWithTimeOut:-1];
}

- (void)didReceiveACKWithState:(CTL_MESSAGE_PACKET)ACK
{
    if (ACK.cmd == SDB_SET_DEV_WORK_MODE_ACK && ACK.param0 == DWM_FLASH_PHOTO) {
        [self.socketManager receiveMessageWithTimeOut:-1];
    }
    
    if (ACK.cmd == SDB_SET_RECV_OK_ACK) {
        NSLog(@"确认已接收图片");
    }
}

- (void)didGetLensStatus:(LENS_PARAMS)status
{}

- (void)didSetIRISWithStatus:(SDB_STATE)state
{}

- (void)didFinishBatchFilesDownloadingWithImageDataArray:(NSMutableArray *)imageDataArray
{}

- (void)didLoseAlive
{
    NSLog(@"did lost alive in sroll view controller");
}

- (void)didReceiveDevInfo:(DEV_INFO)decInfo
{
}
- (void)didReceiveLensStatus
{
}

#pragma mark - Notification center

- (void)modeDetectingFore
{
    NSLog(@"notification detecting fore");
    if (self.imgClient.cameraMode == SYNCMODE) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToDDR];
    }
    else [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
}

- (void)modeDetectingBack
{
    NSLog(@"notification detecting back");
    if (self.imgClient.cameraMode == SYNCMODE) {

    }
}
//- (void)syncingStateChangged:(NSNotification *)noti
//{
//    NSString *notiString = [noti object];
//    if ([notiString isEqualToString:@"已同步所有照片"]) {
//        dispatch_async(dispatch_get_main_queue(), ^(){
//            [ProgressHUD showSuccess:notiString];
//        });
//    }
//    else
//        dispatch_async(dispatch_get_main_queue(), ^(){
//            [ProgressHUD showError:notiString Interaction:NO];
//            [self dismissController];
//        });
//}

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


@end

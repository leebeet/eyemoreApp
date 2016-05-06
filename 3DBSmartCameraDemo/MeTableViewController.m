//
//  MeTableViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/5/22.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "MeTableViewController.h"
#import "TCPSocketManager.h"
#import "ProgressHUD.h"
#import "GCNetworkReachability.h"
#import "CMDManager.h"
#import "ImageClient.h"
#import "ImageAlbumManager.h"
#import "PulseWaveController.h"
#import "SaveLoadInfoManager.h"
#import "BL32BitCheckSumValidator.h"
#import "LogViewController.h"
#import "JLResourcePath.h"
#import "UpdateViewController.h"
#import "SettingCamTableViewController.h"
#import "LTHPasscodeViewController.h"
#import "DevelopingTableViewController.h"
#import "sys/utsname.h"
#import "UserCenterView.h"
#import "eyemoreUser.h"
#import "Config.h"
#import "SDWebImageManager.h"
#import "AFNetworking.h"
#import "eyemoreAPI.h"
#import "ProgressHUD.h"
#import "LoginViewController.h"
#import "MyProfileTableController.h"
#import "UserCenterController.h"

@interface MeTableViewController () <TCPSocketManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate,LTHPasscodeViewControllerDelegate>
{
    float _progressValueUnit;
}
@property (strong, nonatomic) TCPSocketManager *socketManager;
@property (assign, nonatomic) BOOL             isConnectionAvailable;


@property (strong, nonatomic) UIAlertView      *resetAlert;
@property (strong, nonatomic) UIAlertView      *updateAlert;
@property (strong, nonatomic) UIAlertView      *saveAlert;
@property (strong, nonatomic) UIAlertView      *removeAlert;
@property (strong, nonatomic) UIAlertView      *formattingAlert;

@property (strong, nonatomic) ImageClient      *imgClient;
@property (strong, nonatomic) ImageAlbumManager *albumManager;
@property (weak, nonatomic)   IBOutlet UIView   *updateHintView;
@property (weak, nonatomic)   IBOutlet UILabel  *batterLabel;
@property (nonatomic, strong) NSString          *cameraVer;
@property (nonatomic, strong) NSString          *cameraChargeState;

@property (assign, nonatomic) BOOL               willUpdate;
@property (strong, nonatomic) NSTimer           *uploadCheckingTimer;
@property (assign, nonatomic) BOOL               isOldVersionHandle;
@property (assign, nonatomic) BOOL               isPassCodeCorrected;
@property (strong, nonatomic) UIProgressView    *savingProgress;

@property (nonatomic, assign) int64_t myID;
@property (nonatomic, strong) eyemoreUser *myProfile;
@property (nonatomic, strong) UserCenterView *myProfileView;

@end

@implementation MeTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    self.socketManager.delegate = self;
    
    //设置相机工作模式
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"MeTableViewControllerWillAppear" object:nil];
    UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:2];
    if ([item.badgeValue  isEqual: @"更新"]) {
        [self.updateHintView setHidden:NO];
    }
    else [self.updateHintView setHidden:YES];
    
    [self setUpTableViewAppearance];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"MeTableViewControllerWillDisappear" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.imgClient =[ImageClient sharedImageClient];
    
    self.albumManager = [ImageAlbumManager sharedImageAlbumManager];
    [self.albumManager createCustomAlbumWithName:@"eyemore Album"];
    
    self.updateHintView.layer.cornerRadius = 5 ;
    self.isOldVersionHandle = NO;
    
    //设置锁屏代理者
    [LTHPasscodeViewController sharedUser].delegate = self;
    
    [self wipeNaviBarBottomBaseLine];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRefreshHandler:)  name:@"userRefresh"     object:nil];
    
    self.myID = [Config getOwnID];
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//- (IBAction)updateButtonTapped:(id)sender {
//    
//    self.willUpdate = NO;
//    
//    [ProgressHUD show:@"正在校验相机固件..." Interaction:NO];
//    
//    //NSData *data = UIImageJPEGRepresentation([UIImage imageNamed:@"3db_拍立得3"], 1);
//    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"BOOT20151105" ofType:@"bin"];
//    NSData *data = [NSData dataWithContentsOfFile:filePath];
//    
//    self.socketManager.upLoadData = data;
//    unsigned int checksum;
//    checksum = [BL32BitCheckSumValidator calculateCheckSumWithData:data];
//    //[self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDUploadSingleFileWithData(data)];
//    [ProgressHUD show:@"正在上传最新固件至相机中..." Interaction:NO];
//    NSLog(@"checksum is :%u", checksum);
//    
//    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDUploadSingleFileWithDataWithCheckSum(checksum, data)];
//    //self.uploadCheckingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(checkingUploaState) userInfo:nil repeats:YES];
//    [self.socketManager receiveMessageWithTimeOut:-1];
//}

- (void)setUpTableViewAppearance
{
    self.tableView.separatorColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
}

- (void)wipeNaviBarBottomBaseLine
{
    //NavigationBar底部的黑线是一个UIImageView上的UIImageView
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        NSArray *list=self.navigationController.navigationBar.subviews;
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView=(UIImageView *)obj;
                NSArray *list2=imageView.subviews;
                for (id obj2 in list2) {
                    if ([obj2 isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView2=(UIImageView *)obj2;
                        imageView2.hidden=YES;
                    }
                }
            }
        }
    }

}

- (void)updateUIWithoutConnection
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        //self.batterLabel.text = [NSString stringWithFormat:@"版本: 3.14  相机: %@  剩余电量: %@％", self.cameraVer, self.cameraChargeState];
        self.batterLabel.text = [NSString stringWithFormat:@"软件版本: Beta 3.18"];
    });
}

- (void)checkingUploaState
{
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetUploadState];
}

- (BOOL)isConnectionAvailable{
    
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
            
            //if (self.socketManager.socketHost) {
                isExistenceNetwork = YES;
            //}
            //else isExistenceNetwork = NO;
            NSLog(@"WIFI");
            break;
            
        case GCNetworkReachabilityStatusWWAN:
            isExistenceNetwork = YES;
            NSLog(@"3G");
            break;
    }
    return isExistenceNetwork;
}

#pragma mark - Notification handling

- (void)userRefreshHandler:(NSNotification *)notification
{
    _myID = [Config getOwnID];
    
    [self refreshMyProfileView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


#pragma mark - User Data Refreshing

- (void)refreshMyProfileView
{
    if (self.myProfileView == nil) {
        self.myProfileView = [UserCenterView instantiateFromNib];
    }
    self.myProfile = [Config myProfile];
    BOOL isLogin = self.myID != 0;
    if (isLogin) {
        if (![self.myProfile.avatorURL.absoluteString isEqualToString:@""]) {
            [[SDWebImageManager sharedManager] downloadImageWithURL:self.myProfile.avatorURL
                                                            options:0
                                                           progress:nil
                                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
                                                              [self.myProfileView changeStateToLoginWithName:self.myProfile.nickName
                                                                                                       Image:image
                                                                                                  LeftString:[NSString stringWithFormat:@"人气  0"]
                                                                                                 RightString:[NSString stringWithFormat:@"喜欢  0"]];
                                                              [self.navigationItem setTitle:self.myProfile.nickName];
                                                          }];
        }
        else {
            [self.myProfileView changeStateToLoginWithName:self.myProfile.nickName
                                                     Image:nil
                                                LeftString:[NSString stringWithFormat:@"人气  0"]
                                               RightString:[NSString stringWithFormat:@"喜欢  0"]];
            [self.navigationItem setTitle:self.myProfile.nickName];

        }
    }
    else {
        [self.navigationItem setTitle:@"我"];
        [self.myProfileView changeStateToDefault];
    }
    [self.myProfileView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myProfileViewTapped)]];
}

- (void)refresh
{
    self.myID = [Config getOwnID];
    if (self.myID == 0) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self refreshMyProfileView];
            [self.tableView reloadData];
        });
    }
    else {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
        [manager GET:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_FETCH_PROFILE]
          parameters:nil
            progress:nil
             success:^(NSURLSessionDataTask *task, id responseObject){
                 NSDictionary *result = (NSDictionary *)responseObject;
                 NSInteger status = [[result objectForKey:@"status"] integerValue];
                 if (status == 1) {
                     NSLog(@"%@", [result objectForKey:@"results"]);
                     self.myProfile = [[eyemoreUser alloc] initWithProfileDict:result];
                     [Config updateProfile:self.myProfile];
                     [self refreshMyProfileView];
                     dispatch_async(dispatch_get_main_queue(), ^(){[self.tableView reloadData];});
                }
                 else {
                     [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
                     if ([[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] isEqualToString:@"token不存在"]) {
                         self.myID = 0;
                         self.myProfile.userID = 0;
                         [Config saveProfile:self.myProfile];
                         dispatch_async(dispatch_get_main_queue(), ^(){ [self refresh]; });
                     }
                 }
             }
             failure:^(NSURLSessionDataTask *task, NSError *error){
                 [ProgressHUD showError:@"无法获取用户信息" Interaction:YES];
                 NSLog(@"fetch profile error: %@", error);
             }];

    }
}

- (void)myProfileViewTapped
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    } else {

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserCenterController" bundle:nil];
        UserCenterController *controller = [storyboard instantiateViewControllerWithIdentifier:@"UserCenterController"];
        controller.myProfile = self.myProfile;
        controller.avatarImage = self.myProfileView.userAvarta.image;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addSubview:self.myProfileView];
        self.myProfileView.center = CGPointMake(cell.frame.size.width / 2, cell.frame.size.height / 2);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did selected row : %ld and section : %ld", (long)indexPath.row, (long)indexPath.section);
    
    if (indexPath.section == 1 && indexPath.row == 3) {
        self.removeAlert = [[UIAlertView alloc] initWithTitle:@"确定删除"
                                                     message:@"确定删除app内所有已同步的照片吗"
                                                    delegate:self
                                           cancelButtonTitle:@"取消"
                                           otherButtonTitles:@"确定",nil];
        
        [self.removeAlert show];
    }
//    if (indexPath.section == 1 &&indexPath.row == 3) {
//        self.formattingAlert = [[UIAlertView alloc] initWithTitle:@"格式化相机"
//                                                         message:@"相机格式化后，相机内所有照片会被删除，确定格式化相机并重启相机吗？"
//                                                        delegate:self
//                                               cancelButtonTitle:@"取消"
//                                               otherButtonTitles:@"确定", nil];
//        [self.formattingAlert show];
//    }
//    if (indexPath.row == 4) {
//        if (!self.socketManager.isLost) {
//            
//            self.updateAlert = [[UIAlertView alloc] initWithTitle:@"确定更新相机吗？"
//                                                         message:@"是否更新您的相机为最新固件？"
//                                                        delegate:self
//                                               cancelButtonTitle:@"取消"
//                                               otherButtonTitles:@"更新",nil];
//            
//            [self.updateAlert show];
//        }
//        else [ProgressHUD showError:@"连接已断开, 请连接相机后再试一次！" Interaction:NO];
//    }
    if (indexPath.row == 2 && indexPath.section == 1) {
    
        if (self.imgClient.imgPath.count > 0) {
            
            self.saveAlert = [[UIAlertView alloc] initWithTitle:@"确定保存全部照片吗？"
                                                          message:@"保存所有照片至本地相册同时清除app内的所有相片"
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                                otherButtonTitles:@"确定",nil];
            
            [self.saveAlert show];
        }
    }
    if (indexPath.section == 1 && indexPath.row == 4) {
        self.isPassCodeCorrected = NO;
        [[LTHPasscodeViewController sharedUser] showLockScreenWithAnimation:YES
                                                                 withLogout:NO
                                                             andLogoutTitle:nil];
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        
        if ([Config getOwnID] == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self presentViewController:loginVC animated:YES completion:nil];
        }
        else {
        MyProfileTableController  *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfileTableController"];
        [self.navigationController pushViewController:VC animated:YES];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 15)];
    header.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
    return header;
}

#pragma mark - TCP socket manager delegate

- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command
{
    [self.socketManager receiveMessageWithTimeOut:-1];
}
- (void)didSendData
{
    if (! self.isOldVersionHandle) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [ProgressHUD showSuccess:@"上传固件完毕,即将重启" Interaction:NO];
        });
        //[self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetStandbyEnable(STADNDBY_ENABLE)];
    }
    self.isOldVersionHandle = NO;
}
- (void)didReceiveACKWithState:(CTL_MESSAGE_PACKET)ACK
{
    if (ACK.cmd == SDB_SET_DEV_WORK_MODE_ACK && ACK.param0 == DWM_NORMAL) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetDebugInfo];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetDevInfo];
    }
}

- (void)didFinishConnectToHost {
    dispatch_async(dispatch_get_main_queue(), ^(){
        //[ProgressHUD showSuccess:@"连接成功" Interaction:NO];
    });
}

- (void)didDisconnectSocket
{}

- (void)didReceiveLensStatus:(LENS_PARAMS)lensStatus
{}

- (void)didSetIRISWithStatus:(SDB_STATE)state
{}

- (void)didReceiveDebugInfo:(DEBUG_INFO)info
{
    self.cameraChargeState = [NSString stringWithFormat:@"%d", info.StateOfCharge];
    [self updateUIWithoutConnection];
    
}

- (void)didLoseAlive
{}

- (void)didReceiveDevInfo:(DEV_INFO)decInfo
{
    self.cameraVer = [NSString stringWithFormat:@"%s", decInfo.dev_version];
    [self updateUIWithoutConnection];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button tapped index :%ld", (long)buttonIndex);
    if (buttonIndex == 1 && alertView == self.resetAlert) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDFactoryReset];
    }
    if (buttonIndex == 1 && alertView == self.updateAlert) {
        UpdateViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"updateController"];
        controller.message = [NSString stringWithFormat:@"点击确定更新以恢复相机至最新版本"];
        [self presentViewController:controller animated:YES completion:nil];
    }
    if (buttonIndex == 1 && alertView == self.saveAlert) {
        self.savingProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
        self.savingProgress.progressViewStyle = UIProgressViewStyleBar;
        self.savingProgress.progressTintColor = [UIColor redColor];
        self.savingProgress.trackTintColor = [UIColor grayColor];
        self.savingProgress.progress = 0;
        self.savingProgress.transform = CGAffineTransformMakeScale(1, 3);
        [ProgressHUD show:@"正在保存照片..." view:self.savingProgress Interaction:NO];
       
        _progressValueUnit = (float)1.0 / self.imgClient.imgPath.count;
        [self batchSaveAllPhotos];
    }
    
    if (buttonIndex == 1 && alertView == self.removeAlert) {
        [self.imgClient.dataCache removeAllWithBlock:^(BOOL success){
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.imgClient.imgPath removeAllObjects];
                [SaveLoadInfoManager saveAppInfoWithClient:self.imgClient];
                [ProgressHUD showSuccess:@"删除成功"];
            });
        }];
    }
    if (buttonIndex == 1 && alertView == self.formattingAlert) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDDeleteAllJPGs];
    }
}

- (void)batchSaveAllPhotos
{
    static float progress = 0;
    if (self.imgClient.imgPath.count) {
        NSLog(@"self.imageClient.imagePath: %@", self.imgClient.imgPath[0] );
        NSData *imageData = [self.imgClient getImageDataForKey:self.imgClient.imgPath[0]];

        //老设备无法创建相册，此处做兼容，直接保存到本地相册
        if ([[self deviceVersion] isEqualToString:@"iPad mini (WiFi)"]) {
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
                                           [self.savingProgress setProgress:progress animated:YES];

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
        [ProgressHUD showSuccess:@"保存成功" Interaction: NO];
        progress = 0;
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    static float progress = 0;
    
    [self.imgClient removeImageDataWithPath:self.imgClient.imgPath[0] WithCameraMode:DOWNLOADMODE];
    [self.imgClient.imgPath removeObjectAtIndex:0];
    [SaveLoadInfoManager saveAppInfoWithClient:self.imgClient];
    
    [self batchSaveAllPhotos];
    //dispatch_async(dispatch_get_main_queue(), ^(){
    progress += _progressValueUnit;
    [self.savingProgress setProgress:progress animated:YES];
    
    if (self.imgClient.imgPath.count == 0) {
        progress = 0;
    }
    // });
}

- (void)dismissAlertView:(NSTimer*)timer {
    
    NSLog(@"Dismiss save alert view");
    
    [self.saveAlert dismissWithClickedButtonIndex:0 animated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PartParameters"]) {
        
        SettingCamTableViewController *controller = segue.destinationViewController;
        controller.isDevelopUse = NO;
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

# pragma mark - LTHPasscodeViewController Delegates -

- (void)passcodeViewControllerWillClose {
    NSLog(@"Passcode View Controller Will Be Closed");
    if (self.isPassCodeCorrected) {
        DevelopingTableViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DevelopingTableViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)maxNumberOfFailedAttemptsReached {
    [LTHPasscodeViewController deletePasscodeAndClose];
    NSLog(@"Max Number of Failed Attemps Reached");
}

- (void)passcodeWasEnteredSuccessfully {
    NSLog(@"Passcode Was Entered Successfully");
    self.isPassCodeCorrected = YES;
}

- (void)logoutButtonWasPressed {
    NSLog(@"Logout Button Was Pressed");
}

/**
 *  设备版本
 *
 *  @return e.g. iPhone 5S
 */
- (NSString*)deviceVersion
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    
    //iPod
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    
    //iPad
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2 (32nm)";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad mini (CDMA)";
    
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3(WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3(CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3(4G)";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4 (4G)";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (CDMA)";
    
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    if ([deviceString isEqualToString:@"iPad4,4"]
        ||[deviceString isEqualToString:@"iPad4,5"]
        ||[deviceString isEqualToString:@"iPad4,6"])      return @"iPad mini 2";
    
    if ([deviceString isEqualToString:@"iPad4,7"]
        ||[deviceString isEqualToString:@"iPad4,8"]
        ||[deviceString isEqualToString:@"iPad4,9"])      return @"iPad mini 3";
    
    return deviceString;
}

@end

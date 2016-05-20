//
//  SettingCamTableViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/8/13.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "SettingCamTableViewController.h"
#import "MMPickerView.h"
#import "TCPSocketManager.h"
#import "ProgressHUD.h"
#import "CMDManager.h"
#import "MeTableViewController.h"
#import "ImageClient.h"
#import "UpdateViewController.h"

@interface SettingCamTableViewController ()<TCPSocketManagerDelegate, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel  *lensTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel  *camModeLabel;
@property (weak, nonatomic) IBOutlet UILabel  *devVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *batteryLabel;

@property (weak, nonatomic) IBOutlet UISwitch *focusModeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *BWModeSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *standbySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoPowerOffSwitcher;
@property (weak, nonatomic) IBOutlet UISwitch *muteCamEnableSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *jpgInfoSwitch;


@property (weak, nonatomic) IBOutlet UILabel  *exposureLabel;
@property (weak, nonatomic) IBOutlet UILabel  *setCamModeLabel;
@property (weak, nonatomic) IBOutlet UILabel  *shutterLabel;
@property (weak, nonatomic) IBOutlet UILabel  *irisLabel;
@property (weak, nonatomic) IBOutlet UILabel *autoPowerOffTimeLabel;


@property (weak, nonatomic) IBOutlet UISlider *EVFBackLightSlider;
@property (weak, nonatomic) IBOutlet UISlider *cameraVolumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *recordingVolumeSlider;

@property (strong, nonatomic) NSMutableArray  *exposureArray;
@property (strong, nonatomic) NSMutableArray  *camModeArray;
@property (strong, nonatomic) NSMutableArray  *shutterArray;
@property (strong, nonatomic) NSMutableArray  *irisArray;
@property (strong, nonatomic) NSMutableArray  *autoPowerOffTimeArray;

@property (assign, nonatomic) NSInteger        successTag;

@property (strong, nonatomic) TCPSocketManager*socketManager;
@property (strong, nonatomic) UIAlertView      *updateAlert;
@property (strong, nonatomic) UIAlertView      *formattingAlert;

@end

@implementation SettingCamTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    self.socketManager.delegate = self;
    
    //设置相机工作模式
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MeTableViewControllerWillAppear" object:nil];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.socketManager.isLost){
        [self.parentViewController.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MeTableViewControllerWillDisappear" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.delegate = self;
    self.exposureArray         = [@[@"EV -10.0", @"EV -9.0", @"EV -8.0", @"EV -7.0", @"EV -6.0", @"EV -5.0", @"EV -4.0", @"EV -3.0", @"EV -2.0", @"EV -1.0", @"EV 0.0", @"EV 1.0", @"EV 2.0", @"EV 3.0", @"EV 4.0", @"EV 5.0", @"EV 6.0", @"EV 7.0", @"EV 8.0", @"EV 9.0", @"EV 10.0"] mutableCopy];
    self.camModeArray          = [@[@"P", @"S", @"A", @"M"] mutableCopy];
    self.shutterArray          = [@[@"1/25", @"1/50", @"1/100", @"1/200", @"1/500", @"1/1000"] mutableCopy];
    self.irisArray             = [@[@"--",@"--",@"--",@"--",@"--",@"--",@"--",@"--",@"--",@"--", @"--",@"--",@"--",@"--",@"--"] mutableCopy];
    self.autoPowerOffTimeArray = [@[@"不自动关机", @"5 mins",@"10 mins",@"30 mins",@"60 mins",@"90 mins",@"120 mins"] mutableCopy];
    
    [self.focusModeSwitch       addTarget:self action:@selector(focusSwitchAction:)           forControlEvents:UIControlEventValueChanged];
    [self.BWModeSwitch          addTarget:self action:@selector(BWModeSwitchAction:)          forControlEvents:UIControlEventValueChanged];
    [self.standbySwitch         addTarget:self action:@selector(standbySwitchAction:)         forControlEvents:UIControlEventValueChanged];
    [self.EVFBackLightSlider    addTarget:self action:@selector(EVFBackLightValueChanged:)    forControlEvents:UIControlEventTouchUpInside];
    [self.muteCamEnableSwitch   addTarget:self action:@selector(muteCamEnableSwitchAction:)   forControlEvents:UIControlEventValueChanged];
    [self.cameraVolumeSlider    addTarget:self action:@selector(cameraVolumeValueChanged:)    forControlEvents:UIControlEventTouchUpInside];
    [self.recordingVolumeSlider addTarget:self action:@selector(recordingVolumeValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    // setup background color
    self.view.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
    
    if (self.isPresentingStyle) {
        [self setUpNaviBar];
    }
}

- (void)setUpNaviBar
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(DismissVideoBrowser)];
    btn1.tintColor = [UIColor whiteColor];
    NSArray *arr1=[[NSArray alloc]initWithObjects:btn1, nil];
    self.navigationItem.leftBarButtonItems = arr1;
}
- (void)DismissVideoBrowser
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)settingButtonTapped:(id)sender
{
//    [self.socketManager setIRISParams:[self recodeLensValueWith:self.setIRIS.text]];
}

- (void)focusSwitchAction:(id)sender
{
    if (self.focusModeSwitch.on) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetLensFocusState(FOCUS_MF)];
        if (self.socketManager.isLost) {
            [self.focusModeSwitch setOn:NO animated:YES];
        }
    }
    else
    {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetLensFocusState(FOCUS_AF)];
        if (self.socketManager.isLost) {
            [self.focusModeSwitch setOn:NO animated:YES];
        }
    };
}
- (void)BWModeSwitchAction:(id)sender
{
    if (self.BWModeSwitch.on) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetBWDisplayParam(DISPLAY_BLACKANDWHITE)];
        if (self.socketManager.isLost) {
            [self.BWModeSwitch setOn:NO animated:YES];
        }
    }
    else {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetBWDisplayParam(DISPLAY_COLOR)];
        if (self.socketManager.isLost) {
            [self.BWModeSwitch setOn:NO animated:YES];
        }
    }
}
- (void)standbySwitchAction:(id)sender
{
    if (self.standbySwitch.on) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetStandbyEnable(STADNDBY_ENABLE)];
        if (self.socketManager.isLost) {
            [self.standbySwitch setOn:NO animated:YES];
        }
    }
    else {
        if (self.socketManager.isLost) {
            [self.standbySwitch setOn:NO animated:YES];
        }
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetStandbyEnable(STADNDBY_DISABLE)];
    }
}
- (IBAction)poweroffSwitchAction:(id)sender {
    if (self.autoPowerOffSwitcher.on) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPowerOffTime(10)];
        if (self.socketManager.isLost) {
            [self.autoPowerOffSwitcher setOn:NO animated:YES];
        }
    }
    else {
        if (self.socketManager.isLost) {
            [self.autoPowerOffSwitcher setOn:NO animated:YES];
        }
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPowerOffTime(0)];
    }
}

- (void)EVFBackLightValueChanged:(id)sender
{
    int evf;
    evf = (int)self.EVFBackLightSlider.value;
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetEVFBackLight(evf)];
    if (self.socketManager.isLost) {
        [self.EVFBackLightSlider setValue:0 animated:YES];
    }
}

- (void)muteCamEnableSwitchAction:(id)sender
{
    if (self.muteCamEnableSwitch.on) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetSoundEnable(0)];
        if (self.socketManager.isLost) {
            [self.muteCamEnableSwitch setOn:NO animated:YES];
        }
    }
    else {
        //[self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetSoundEnable(1)];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetSoundIfExsit];
        if (self.socketManager.isLost) {
            [self.muteCamEnableSwitch setOn:NO animated:YES];
        }
    }
}

- (void)cameraVolumeValueChanged:(id)sender
{
    int volume;
    volume = (int)self.cameraVolumeSlider.value;
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetSoundVolume(volume)];
    if (self.socketManager.isLost) {
        [self.cameraVolumeSlider setValue:0 animated:YES];
    }
}
- (void)recordingVolumeValueChanged:(id)sender
{
    int volume;
    volume = (int)self.recordingVolumeSlider.value;
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetSoundRecordVolume(volume)];
    if (self.socketManager.isLost) {
        [self.recordingVolumeSlider setValue:0 animated:YES];
    }
}

- (IBAction)jpgInfoSwitchAction:(id)sender {
    
    if (self.jpgInfoSwitch.on) {
         [ImageClient sharedImageClient].isShownJpgInfo = YES;
    }
    else [ImageClient sharedImageClient].isShownJpgInfo = NO;
}

- (void)updateUIWithLensParam:(LENS_PARAMS)status 
{
    self.lensTypeLabel.text         = [self decodeLensTypeWith:status.lens_type];
    self.camModeLabel.text          = [NSString stringWithFormat:@"%@ / %@ / %@ / %@",
                                       [self decodeLensFocusStateWith:status.focus_mode],
                                       [self decodeLensValueWith:status.current_iris_value],
                                       [self decodeLensShutterValueWith:status.current_shutter_value],
                                       [self decodeLensExposureValueWith:status.current_exposure_value]];

    self.exposureLabel.text         = [NSString stringWithFormat:@"%@", [self decodeLensExposureValueWith:status.current_exposure_value]];
    self.irisLabel.text             = [NSString stringWithFormat:@"%@", [self decodeLensValueWith:status.current_iris_value]];
    self.shutterLabel.text          = [NSString stringWithFormat:@"%@", [self decodeLensShutterValueWith:status.current_shutter_value]];
    
    if (status.bwdisplay_state == DISPLAY_BLACKANDWHITE) {
        [self.BWModeSwitch setOn:YES animated:YES];
    }
    else [self.BWModeSwitch setOn:NO animated:YES];
    
    if (status.focus_mode == FOCUS_MF) {
        [self.focusModeSwitch setOn:YES animated:YES];
    }
    else [self.focusModeSwitch setOn:NO animated:YES];
    

    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = status.iris_min_value; i <= status.iris_max_value; i ++) {
        NSLog(@"status.iris_value : %d", i);
        [array addObject:[self decodeLensValueWith:i]];
    }
    self.irisArray = array;
}

- (void)updateuUIWithDeviceParams:(DEV_INFO)devInfo
{
    self.autoPowerOffTimeLabel.text = [NSString stringWithFormat:@"%@", [self decodePowerOffTimeValueWith:devInfo.power_off_time]];
    NSLog(@"power off time:%d",devInfo.power_off_time);
    //self.EVFBackLightSlider.value   = (float)devInfo.evf_backlight_value;
    [self.EVFBackLightSlider setValue:(float)devInfo.evf_backlight_value animated:YES];

    if (devInfo.power_off_time == 0) {
        [self.autoPowerOffSwitcher setOn:NO animated:YES];
    }
    else [self.autoPowerOffSwitcher setOn:YES animated:YES];
    
    self.devVersionLabel.text = [NSString stringWithFormat:@"%s", devInfo.dev_version];
    if (devInfo.arm_standby == STADNDBY_ENABLE) {
        [self.standbySwitch setOn:YES animated:YES];
    }
    else [self.standbySwitch setOn:NO animated:YES];
}

- (void)uploadToneFileWithFileName:(NSString *)name ofType:(NSString *)type toCameraPath:(const char *)path
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    self.socketManager.upLoadData = data;
    [self.socketManager sendUploadFileMessageWithCMD:(CTL_MESSAGE_PACKET)CMDUploadGeneralFile withPath:path]; //"/audio/begin.wav"
}

#pragma mark - TCP socket delegate

- (void)didReceiveLensStatus:(LENS_PARAMS)lensStatus
{
    NSLog(@"status.lens_type:%c",lensStatus.lens_type);
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        [self updateUIWithLensParam:lensStatus];
    });
}

- (void)didReceiveDevInfo:(DEV_INFO)decInfo
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        [self updateuUIWithDeviceParams:decInfo];
    });
}

- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command
{
    NSLog(@"command: %d", command.cmd);
    [self.socketManager receiveMessageWithTimeOut:-1];
}

- (void)didSendData
{
    static int i = 0;
    NSLog(@"did send voice file ");
    [NSThread sleepForTimeInterval:1.0f];
    //[self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetSoundEnable(1)];
    if (i == 0) {
        [self uploadToneFileWithFileName:@"begin_classic" ofType:@"wav" toCameraPath:"/audio/begin.wav"];
        //[ProgressHUD show:@"配置开机音..." Interaction:NO];
        i = 1;
    }
    else if (i == 1) {
        [self uploadToneFileWithFileName:@"focus_classic" ofType:@"wav" toCameraPath:"/audio/focus.wav"];
        //[ProgressHUD show:@"配置对焦音..." Interaction:NO];
        i = 2;
    }
    else if (i == 2) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetSoundVolume(15)];
        i = 0;
    }
    

}

- (void)didReceiveACKWithState:(CTL_MESSAGE_PACKET)ACK
{

    if (ACK.state != SDB_STATE_SUCCESS &&
        (ACK.cmd == SDB_SET_LENS_FOCUS_PARAM_ACK ||
         ACK.cmd == SDB_SET_BWDISPLAY_PARAM_ACK ||
         ACK.cmd == SDB_SET_EXPOSURE_PARAM_ACK ||
         ACK.cmd == SDB_SET_EXPOSURE_MODE_ACK ||
         ACK.cmd == SDB_SET_SHUTTER_PARAM_ACK ||
         ACK.cmd == SDB_SET_IRIS_PARAM_ACK )
        ) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [ProgressHUD showError:@"设置失败"];
            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetLensStatus];
        });
    }
    if (ACK.cmd == SDB_SET_DEV_WORK_MODE_ACK && ACK.param0 == DWM_NORMAL) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetDeviceInfo];
        [NSThread sleepForTimeInterval:0.2f];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetLensStatus];
        [NSThread sleepForTimeInterval:0.2f];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetSoundEnable];
        [NSThread sleepForTimeInterval:0.2f];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetSoundVolume];
        [NSThread sleepForTimeInterval:0.2f];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetSoundRecordVolume];
        [NSThread sleepForTimeInterval:0.2f];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetDebugInfo];
    }
    if (ACK.cmd == SDB_SET_LENS_FOCUS_PARAM_ACK ||
        ACK.cmd == SDB_SET_BWDISPLAY_PARAM_ACK  ||
        ACK.cmd == SDB_SET_EXPOSURE_PARAM_ACK   ||
        ACK.cmd == SDB_SET_EXPOSURE_MODE_ACK    ||
        ACK.cmd == SDB_SET_SHUTTER_PARAM_ACK    ||
        ACK.cmd == SDB_SET_IRIS_PARAM_ACK){
        
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetLensStatus];
    }
    if (ACK.cmd == SDB_SET_EVF_BACKLIGHT_ACK && ACK.state == SDB_STATE_SUCCESS){
    }
    if (ACK.cmd == SDB_SET_STANDBY_EN_ACK || ACK.cmd == SDB_SET_POWER_OFF_TIME_ACK) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetDeviceInfo];
    }
    if (ACK.cmd == SDB_SET_SOUND_ENABLE_ACK)  {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetSoundEnable];
    }
    if (ACK.cmd == SDB_SET_SOUND_VOLUME_ACK )  {
        //[self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetSoundVolume];
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetSoundEnable(1)];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [ProgressHUD showSuccess:@"已配置" Interaction:NO];
        });
    }
    if (ACK.cmd == SDB_SET_SOUND_RECORD_VOLUME_ACK)  {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetSoundRecordVolume];
    }
    
    if (ACK.cmd == SDB_GET_SOUND_ENABLE_ACK)  {
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (ACK.param0) {
                [self.muteCamEnableSwitch setOn:NO animated:YES];
                //[self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetSoundVolume(15)];
            }
            else [self.muteCamEnableSwitch setOn:YES animated:YES];
        });
    }
    if (ACK.cmd == SDB_GET_SOUND_VOLUME_ACK )  {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.cameraVolumeSlider setValue:(float)ACK.param0 animated:YES];
        });
    }
    if (ACK.cmd == SDB_GET_SOUND_RECORD_VOLUME_ACK)  {
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.recordingVolumeSlider  setValue:(float)ACK.param0 animated:YES];
        });
    }
    if (ACK.cmd == SDB_SET_JPG_EXIF_PARAMS_ACK ) {
        if (ACK.state == SDB_STATE_SUCCESS) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [ProgressHUD showSuccess:@"清除成功" Interaction:NO];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [ProgressHUD showError:@"清除失败" Interaction:NO];
            });
        }
       
    }
    if (ACK.cmd == SDB_GET_SOUND_FILE_EXIST_ACK) {

        if (ACK.param0 == 0) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [ProgressHUD show:@"缺失声音文件，正在配置..." Interaction:NO];
            });
            [self uploadToneFileWithFileName:@"shot_classic" ofType:@"wav" toCameraPath:"/audio/shot.wav"];
        }
        if (ACK.param0 == 1) {
            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetSoundEnable(1)];
        }
    }
    [self.socketManager receiveMessageWithTimeOut:-1];
}

- (void)didFinishConnectToHost {
    dispatch_async(dispatch_get_main_queue(), ^(){
        //[ProgressHUD showSuccess:@"连接成功" Interaction:NO];
        //[self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetLensStatus];
        //设置相机工作模式
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
    });
}

- (void)didDisconnectSocket
{}

- (void)didLoseAlive
{}

- (void)didReceiveDebugInfo:(DEBUG_INFO)info
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        self.batteryLabel.text = [NSString stringWithFormat:@"%d％",info.StateOfCharge];
    });
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 3) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"will selected row : %ld, section :%ld", (long)indexPath.row, (long)indexPath.section);
    
    if ([self.setCamModeLabel.text isEqualToString: @"P"]) {
        
        if (indexPath.section == 1) {
            
            if (indexPath.row == 2) {
                return nil;
            }
            if (indexPath.row == 3) {
                return nil;
            }
        }
    }
    if ([self.setCamModeLabel.text isEqualToString: @"S"]) {
        
        if (indexPath.section == 1) {
            
            if (indexPath.row == 2) {
                self.irisLabel.text = @"---";
                return indexPath;
            }
            if (indexPath.row == 3) {
                return nil;
            }
        }
    }
    if ([self.setCamModeLabel.text isEqualToString: @"A"]) {
        
        if (indexPath.section == 1) {
            
            if (indexPath.row == 2) {
                return nil;
            }
            if (indexPath.row == 3) {
                return indexPath;
            }
        }
    }
    if ([self.setCamModeLabel.text isEqualToString: @"M"]) {
        
        if (indexPath.section == 1) {
            
            return indexPath;
            
        }
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did selected row : %ld, section :%ld", (long)indexPath.row, (long)indexPath.section);
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            if (!self.socketManager.isLost) {
                NSArray *array = [self.exposureArray copy];
                [MMPickerView showPickerViewInView:self.tableView
                                       withStrings:array
                                       withOptions:nil
                                        completion:^(NSString *selectedString){
                                            self.exposureLabel.text = selectedString;
                                            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetExposureValueParam([self recodeLensExposureValueWith:selectedString])];
                                            NSLog(@"picker view dismiss");
                                        }];
            }
        }
        
        if (indexPath.row == 1) {
            if (!self.socketManager.isLost) {
                NSArray *array = [self.camModeArray copy];
                [MMPickerView showPickerViewInView:self.tableView
                                       withStrings:array
                                       withOptions:nil
                                        completion:^(NSString *selectedString){
                                            
                                            self.setCamModeLabel.text = selectedString;
                                            
                                            if ([self.setCamModeLabel.text isEqualToString: @"P"]) {
                                                self.shutterLabel.text = @"---";
                                                self.irisLabel.text    = @"---";
                                            }
                                            if ([self.setCamModeLabel.text isEqualToString: @"A"]) {
                                                self.shutterLabel.text = @"---";
                                                
                                            }
                                            if ([self.setCamModeLabel.text isEqualToString: @"S"]) {
                                                self.irisLabel.text = @"---";
                                                
                                            }
                                            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetExposureMode([self recodeLensExposureModeWith:selectedString])];
                                        }];
            }
        }
        
        if (indexPath.row == 2) {
             if (!self.socketManager.isLost) {
                 NSArray *array = [self.shutterArray copy];
                 [MMPickerView showPickerViewInView:self.tableView
                                        withStrings:array
                                        withOptions:nil
                                         completion:^(NSString *selectedString){
                                             self.shutterLabel.text = selectedString;
                                             NSLog(@"shutter set finish");
                                             [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetShutterParam([self recodeLensShutterValue:selectedString])];
                                         }];
             }
        }
        
        if (indexPath.row == 3) {
            if (!self.socketManager.isLost) {
                NSArray *array = [self.irisArray copy];
                [MMPickerView showPickerViewInView:self.tableView
                                       withStrings:array
                                       withOptions:nil
                                        completion:^(NSString *selectedString){
                                            self.irisLabel.text = selectedString;
                                            NSLog(@"iris set finish");
                                            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetIRISParams([self recodeLensValueWith:selectedString])];
                                        }];
            }
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 4) {
            if (!self.socketManager.isLost) {
                NSArray *array = [self.autoPowerOffTimeArray copy];
                [MMPickerView showPickerViewInView:self.tableView
                                       withStrings:array
                                       withOptions:nil
                                        completion:^(NSString *selectedString){
                                            self.autoPowerOffTimeLabel.text = selectedString;
                                            NSLog(@"power off time set finish");
                                            [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPowerOffTime([self recodePowerOffTimeValueWith:selectedString])];
                                        }];
            }
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 5) {
            if (!self.socketManager.isLost) {
                [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDCleanPhotoInfo];
            }
        }
    }

    if (indexPath.section == 3 && indexPath.row == 0) {
        if (!self.socketManager.isLost) {
        self.formattingAlert = [[UIAlertView alloc] initWithTitle:@"清空相机？"
                                                          message:@"相机清空后，相机内所有照片会被删除"
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                                otherButtonTitles:@"确定", nil];
        [self.formattingAlert show];
        }
        else [ProgressHUD showError:@"连接已断开, 请连接相机后再试一次！" Interaction:NO];
    }
    if (indexPath.section == 3 && indexPath.row == 1) {
        if (!self.socketManager.isLost) {
            
            self.updateAlert = [[UIAlertView alloc] initWithTitle:@"恢复相机？"
                                                          message:@"恢复您的相机系统，但是照片和视频依然存在"
                                                         delegate:self
                                                cancelButtonTitle:@"取消"
                                                otherButtonTitles:@"更新",nil];
            
            [self.updateAlert show];
        }
        else [ProgressHUD showError:@"连接已断开, 请连接相机后再试一次！" Interaction:NO];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    }
    if (section == 2) {
        return 5;
    }
    if (section == 1)
    {
        if (self.isDevelopUse) {
            return 9;
        }
        else return 0;
    }
    if (section == 3)
    {
        return 2;
    }
    return 0;
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button tapped index :%ld", (long)buttonIndex);
    if (buttonIndex == 1 && alertView == self.updateAlert) {
        UpdateViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"updateController"];
        controller.message = [NSString stringWithFormat:@"点击确定开始恢复"];

        // 此处使用模态视图，使用模态视图后将不会掉用viewwillappear，viewdidappear
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            controller.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        }else{
            self.tabBarController.modalPresentationStyle = UIModalPresentationCurrentContext;
        }
        [self.tabBarController presentViewController:controller animated:YES completion:nil];
    }
    
    if (buttonIndex == 1 && alertView == self.formattingAlert) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDDeleteAllJPGs];
    }
}


#pragma mark - recode value

- (LENS_EXPOSURE_VALUE)recodeLensExposureValueWith:(NSString *)string
{
    if ([string isEqualToString:@"EV -10.0"]) return 0;
    
    if ([string isEqualToString:@"EV -9.0"]) return 1;
    
    if ([string isEqualToString:@"EV -8.0"]) return 2;
    
    if ([string isEqualToString:@"EV -7.0"]) return 3;
    
    if ([string isEqualToString:@"EV -6.0"]) return 4;
    
    if ([string isEqualToString:@"EV -5.0"]) return 5;
    
    if ([string isEqualToString:@"EV -4.0"]) return 6;
    
    if ([string isEqualToString:@"EV -3.0"]) return 7;
    
    if ([string isEqualToString:@"EV -2.0"]) return 8;
    
    if ([string isEqualToString:@"EV -1.0"]) return 9;
    
    if ([string isEqualToString:@"EV 0.0"]) return 10;
    
    if ([string isEqualToString:@"EV 1.0"]) return 11;
    
    if ([string isEqualToString:@"EV 2.0"]) return 12;
    
    if ([string isEqualToString:@"EV 3.0"]) return 13;
    
    if ([string isEqualToString:@"EV 4.0"]) return 14;
    
    if ([string isEqualToString:@"EV 5.0"]) return 15;
    
    if ([string isEqualToString:@"EV 6.0"]) return 16;
    
    if ([string isEqualToString:@"EV 7.0"]) return 17;
    
    if ([string isEqualToString:@"EV 8.0"]) return 18;
    
    if ([string isEqualToString:@"EV 9.0"]) return 19;
    
    if ([string isEqualToString:@"EV 10.0"]) return 20;
    
    else return 21;
    
}

- (LENS_EXPOSURE_MODE)recodeLensExposureModeWith:(NSString *)string
{
    if ([string isEqualToString:@"P"]) return 1;
    
    if ([string isEqualToString:@"S"]) return 2;
    
    if ([string isEqualToString:@"A"]) return 3;
    
    if ([string isEqualToString:@"M"]) return 4;
    
    else return 0;
}

- (LENS_SHUTTER_VALUE)recodeLensShutterValue:(NSString *)string
{
    if ([string isEqualToString:@"1/25"]) return 1;
    
    if ([string isEqualToString:@"1/50"]) return 2;
    
    if ([string isEqualToString:@"1/75"]) return 3;
    
    if ([string isEqualToString:@"1/100"]) return 4;
    
    if ([string isEqualToString:@"1/125"]) return 5;
    
    if ([string isEqualToString:@"1/150"]) return 6;
    
    if ([string isEqualToString:@"1/200"]) return 7;
    
    if ([string isEqualToString:@"1/500"]) return 8;
    
    if ([string isEqualToString:@"1/1000"]) return 9;
    
    if ([string isEqualToString:@"1/2000"]) return 10;
    
    if ([string isEqualToString:@"1/4000"]) return 11;
    
    if ([string isEqualToString:@"1/8000"]) return 12;
    
    else return 0;
}

- (LENS_IRIS_VALE)recodeLensValueWith:(NSString *)string
{
    if ([string isEqualToString:@"F1.2"])   return 0;
    
    if ([string isEqualToString:@"F1.4"])   return 1;
    
    if ([string isEqualToString:@"F1.7"])   return 2;
    
    if ([string isEqualToString:@"F1.8"])   return 3;
    
    if ([string isEqualToString:@"F2.0"])   return 4;
    
    if ([string isEqualToString:@"F2.2"])   return 5;
    
    if ([string isEqualToString:@"F2.5"])   return 6;
    
    if ([string isEqualToString:@"F2.8"])   return 7;
    
    if ([string isEqualToString:@"F3.2"])   return 8;
    
    if ([string isEqualToString:@"F3.5"])   return 9;
    
    if ([string isEqualToString:@"F4.0"])   return 10;
    
    if ([string isEqualToString:@"F4.5"])   return 11;
    
    if ([string isEqualToString:@"F5.0"])   return 12;
    
    if ([string isEqualToString:@"F5.6"])   return 13;
    
    if ([string isEqualToString:@"F6.3"])   return 14;
    
    if ([string isEqualToString:@"F7.1"])   return 15;
    
    if ([string isEqualToString:@"F8.0"])   return 16;
    
    if ([string isEqualToString:@"F9.0"])   return 17;
    
    if ([string isEqualToString:@"F10.0"])  return 18;
    
    if ([string isEqualToString:@"F11.0"])  return 19;
    
    if ([string isEqualToString:@"F13.0"])  return 20;
    
    if ([string isEqualToString:@"F14.0"])  return 21;
    
    if ([string isEqualToString:@"F16.0"])  return 22;
    
    if ([string isEqualToString:@"F18.0"])  return 23;
    
    if ([string isEqualToString:@"F20.0"])  return 24;
    
    if ([string isEqualToString:@"F22.0"])  return 25;
    
    else return 26;
    
}

- (NSInteger)recodePowerOffTimeValueWith:(NSString *)string
{
    if ([string isEqualToString:@"不自动关机"]) return 0;
    
    if ([string isEqualToString:@"1 min"])    return 1;
    
    if ([string isEqualToString:@"2 mins"])   return 2;
    
    if ([string isEqualToString:@"3 mins"])   return 3;
    
    if ([string isEqualToString:@"4 mins"])   return 4;
    
    if ([string isEqualToString:@"5 mins"])   return 5;
    
    if ([string isEqualToString:@"10 mins"])  return 10;
    
    if ([string isEqualToString:@"30 mins"])  return 30;
    
    if ([string isEqualToString:@"60 mins"])  return 60;
    
    if ([string isEqualToString:@"90 mins"])  return 90;
    
    if ([string isEqualToString:@"120 mins"]) return 120;
    
    else return 0;
    
    
}

- (NSString *)decodeLensTypeWith:(int)lensType
{
    switch (lensType) {
        case 0:
            return @"手动";
            break;
        case 1:
            return @"自动";
            break;
        default:
            return @"unknown";
            break;
    }
}

- (NSString *)decodeLensFocusStateWith:(unsigned char)lensFocusState
{
    switch (lensFocusState) {
            
        case 1:
            return @"AF";
            break;
        case 2:
            return @"MF";
            break;
            
        default:
            return @"unknown";
            break;
    }
}

- (NSString *)decodeLensShutterValueWith:(int)shutter
{
    switch (shutter) {
        case 1:
            return @"1/25";
            break;
        case 2:
            return @"1/50";
            break;
        case 3:
            return @"1/75";
            break;
        case 4:
            return @"1/100";
            break;
        case 5:
            return @"1/125";
            break;
        case 6:
            return @"1/150";
            break;
        case 7:
            return @"1/200";
            break;
        case 8:
            return @"1/500";
            break;
        case 9:
            return @"1/1000";
            break;
        case 10:
            return @"1/2000";
            break;
        case 11:
            return @"1/4000";
            break;
        case 12:
            return @"1/8000";
            break;
            
        default:
            return @"unknow";
            break;
    }
}

- (NSString *)decodeLensExposureValueWith:(int)exposure
{
    switch (exposure) {
        case 0:
            return @"EV -10.0";
            break;
        case 1:
            return @"EV -9.0";
            break;
        case 2:
            return @"EV -8.0";
            break;
        case 3:
            return @"EV -7.0";
            break;
        case 4:
            return @"EV -6.0";
            break;
        case 5:
            return @"EV -5.0";
            break;
        case 6:
            return @"EV -4.0";
            break;
        case 7:
            return @"EV -3.0";
            break;
        case 8:
            return @"EV -2.0";
            break;
        case 9:
            return @"EV -1.0";
            break;
        case 10:
            return @"EV 0.0";
            break;
        case 11:
            return @"EV 1.0";
            break;
        case 12:
            return @"EV 2.0";
            break;
        case 13:
            return @"EV 3.0";
            break;
        case 14:
            return @"EV 4.0";
            break;
        case 15:
            return @"EV 5.0";
            break;
        case 16:
            return @"EV 6.0";
            break;
        case 17:
            return @"EV 7.0";
            break;
        case 18:
            return @"EV 8.0";
            break;
        case 19:
            return @"EV 9.0";
            break;
        case 20:
            return @"EV 10.0";
            break;
            
        default:
            return @"unknown";
            break;
    }
}

- (NSString *)decodeLensValueWith:(int)iris
{
    switch (iris) {
            
        case 0:
            return @"F1.2";
            break;
        case 1:
            return @"F1.4";
            break;
        case 2:
            return @"F1.7";
            break;
        case 3:
            return @"F1.8";
            break;
        case 4:
            return @"F2.0";
            break;
        case 5:
            return @"F2.2";
            break;
        case 6:
            return @"F2.5";
            break;
        case 7:
            return @"F2.8";
            break;
        case 8:
            return @"F3.2";
            break;
        case 9:
            return @"F3.5";
            break;
        case 10:
            return @"F4.0";
            break;
        case 11:
            return @"F4.5";
            break;
        case 12:
            return @"F5.0";
            break;
        case 13:
            return @"F5.6";
            break;
        case 14:
            return @"F6.3";
            break;
        case 15:
            return @"F7.1";
            break;
        case 16:
            return @"F8.0";
            break;
        case 17:
            return @"F9.0";
            break;
        case 18:
            return @"F10.0";
            break;
        case 19:
            return @"F11.0";
            break;
        case 20:
            return @"F13.0";
            break;
        case 21:
            return @"F14.0";
            break;
        case 22:
            return @"F16.0";
            break;
        case 23:
            return @"F18.0";
            break;
        case 24:
            return @"F20.0";
            break;
        case 25:
            return @"F22.0";
            break;
            
        default:
            return @"unknown";
            break;
    }
}

- (NSString *)decodePowerOffTimeValueWith:(int)value
{
    switch (value) {
        case 0:
            return @"不自动关机";
            break;
            
        case 5:
            return @"5 mins";
            break;
            
        case 10:
            return @"10 mins";
            break;
            
        case 30:
            return @"30 mins";
            break;
            
        case 60:
            return @"60 mins";
            break;
            
        case 90:
            return @"90 mins";
            break;
            
        case 120:
            return @"120 mins";
            break;
            
        default:
            return @"不自动关机";
            break;
    }
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
///*
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}
//*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

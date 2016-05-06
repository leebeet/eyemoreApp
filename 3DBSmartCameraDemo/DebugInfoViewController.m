//
//  DebugInfoViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/8/19.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "DebugInfoViewController.h"
#import "TCPSocketManager.h"
#import "ProgressHUD.h"
#import "CMDManager.h"
#import "WIFIDetector.h"

@interface DebugInfoViewController ()<TCPSocketManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *debugInfoTextView;
@property (weak, nonatomic) IBOutlet UIButton   *getDebugInfoButton;
@property (strong, nonatomic) TCPSocketManager  *socketManager;
@property (assign, nonatomic) DEBUG_INFO         debugInfo;
@property (assign, nonatomic) NSInteger          tappedCount;
@end

@implementation DebugInfoViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    self.socketManager.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.debugInfoTextView.text = [NSString stringWithFormat:@"DEBUG WINDOW－－－－－－－－－－－－\n"];
}

- (IBAction)getDebugInfoButtonTapped:(id)sender {
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetDebugInfo];
    self.tappedCount ++;
    [self.debugInfoTextView scrollRangeToVisible:NSMakeRange(self.debugInfoTextView.text.length+500, 1)];

}

#pragma mark - TCP Socket manager delegate

- (void)didReceiveDebugInfo:(DEBUG_INFO)info{
    
    NSString *bqstring1 = [NSString stringWithFormat:@"%@",[self ToHex:(long long int)info.bq24192_registers[0]]];
    for (int i = 1; i < 10; i++) {
        NSString *temp = [NSString stringWithFormat:@" %@",[self ToHex:(long long int)info.bq24192_registers[i]]];
        bqstring1 = [bqstring1 stringByAppendingString:temp];
    }
    
    NSString *control = [self ToHex:info.Control];
    NSString *temperature = [self ToHex:info.Temperature];
    //NSString *voltage = [self ToHex:info.Voltage];
//    NSString *nominalAvailableCapacity = [self ToHex:info.NominalAvailableCapacity];
//    NSString *fullAvailableCapacity = [self ToHex:info.FullAvailableCapacity];
//    NSString *remainingCapacity = [self ToHex:info.RemainingCapacity];
//    NSString *fullChargeCapacity = [self ToHex:info.FullChargeCapacity];
//    NSString *averageCurrent = [self ToHex:info.AverageCurrent];
//    NSString *standbyCurrent = [self ToHex:info.StandbyCurrent];
//    NSString *maxLoadCurrent = [self ToHex:info.AverageCurrent];
//    NSString *stateOfCharge = [self ToHex:info.StateOfCharge];
    NSString *intTemperature = [self ToHex:info.IntTemperature];
    //NSString *stateOfHealth = [self ToHex:info.StateOfHealth];
    
    NSString *tempstring= [NSString stringWithFormat:@"%@",[self ToHex:(long long int)info.temp[0]]];
    for (int i = 1; i < 38; i++) {
        

        NSString *temp  = [NSString stringWithFormat:@" %@",[self ToHex:(long long int)info.temp[1]]];
        tempstring = [tempstring stringByAppendingString:temp];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(){
    
        NSDate *date = [NSDate date];
        
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        
        NSInteger interval = [zone secondsFromGMTForDate: date];
        
        NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
        
        NSString *newString = [NSString stringWithFormat:
                               @"\n\n--------%@-------- \nDeviceSSID = %@; \nSTM32 Version = %s; \nFPGA_Temperature = %d; \nVoltage = %hu mv; \nStateOfCharge = %hu ％; \nbq24192_registers = %@; \nControl = %@; \nTemperature = %@; \nNominalAvailableCapacity = %hu mAH; \nFullAvailableCapacity = %hu mAH; \nRemainingCapacity = %hu mAH; \nFullChargeCapacity = %hu mAH; \nAverageCurrent = %hi mA; \nStandbyCurrent = %hi mA; \nMaxLoadCurrent = %hi mA; \nAveragePower = %hi mW; \nIntTemperature = %@; \nStateOfHealth = %hu ％;",
                               localeDate,
                               [[WIFIDetector sharedWIFIDetector] getDeviceSSID],
                               info.stm32_version,
                               info.fpga_temp,
                               info.Voltage,
                               info.StateOfCharge,
                               bqstring1,
                               control,
                               temperature,
                               info.NominalAvailableCapacity,
                               info.FullAvailableCapacity,
                               info.RemainingCapacity,
                               info.FullChargeCapacity,
                               (signed short)info.AverageCurrent,
                               (signed short)info.StandbyCurrent,
                               (signed short)info.MaxLoadCurrent,
                               (signed short)info.AveragePower,
                               intTemperature,
                               info.StateOfHealth];
        
        NSString *text = self.debugInfoTextView.text;
        text = [text stringByAppendingString:newString];
        self.debugInfoTextView.text = text;
    
    });
    

}

- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command
{
    [self.socketManager receiveMessageWithTimeOut:-1];
}
- (void)didSendData
{
}
- (void)didReceiveACKWithState:(CTL_MESSAGE_PACKET)ACK
{
    
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

//- (void)didSetIRISWithStatus:(SDB_STATE)state
//{}
- (void)didReceiveDevInfo:(DEV_INFO)decInfo
{}

#pragma mark - decimal to hexadecimal

-(NSString *)ToHex:(long long int)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    
    long long int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
                
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;  
        }  
        
    }
    if (str.length == 1) {
        str = [NSString stringWithFormat:@"0%@", str];
    }
    return str;  
}

@end

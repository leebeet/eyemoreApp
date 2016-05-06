//
//  LogViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/10/10.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import "LogViewController.h"
#import "JLResourcePath.h"
#import "TCPSocketManager.h"
#import "CMDManager.h"
#import "net_interface_params.h"

@interface LogViewController ()<UIDocumentInteractionControllerDelegate, TCPSocketManagerDelegate>
//@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) TCPSocketManager *socketManager;



@end

@implementation LogViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(antoScrollToBottom) userInfo:nil repeats:NO];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view.
    //NSString * str = [NSString stringWithContentsOfFile:GetDocumentPathWithFile(@"MrNSLog.txt") encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"log view mode %@", self.mode);
    if ([self.mode isEqualToString:@"LocalMode"]) {
        self.logTextView.text = self.content;
    }
    else if ([self.mode isEqualToString:@"NetworkMode"])
    {
        self.socketManager = [TCPSocketManager sharedTCPSocketManager];
        self.socketManager.delegate = self;
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetNetworkLogFile];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)antoScrollToBottom
{
    [self.logTextView scrollRangeToVisible:NSMakeRange(self.logTextView.text.length+500, 1)];
}

- (IBAction)sendButtonTapped:(id)sender {
    
    NSString *filePath = [[NSString alloc] init];
    if (self.content == nil) {
        filePath = GetDocumentPathWithFile(@"NetworkLog.txt");
    }
    
    else  {filePath = GetDocumentPathWithFile(@"MrNSLog.txt");}
   
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSArray *items = [NSArray arrayWithObject:url];
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
    
//    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:url];
//    //interactionController.delegate = self;
//    CGRect navRect = self.navigationController.navigationBar.frame;
//    navRect.size = CGSizeMake(1500.0f, 40.0f);
//    
//    [interactionController presentOptionsMenuFromRect:navRect inView:self.view  animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - TCP socket manager delegate

- (void)didFinishSingleFileDownloadingWithImageData:(NSData *)imageData
{
    NSString *filePath = GetDocumentPathWithFile(@"NetworkLog.txt");
    
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:filePath error:nil];
    
    [imageData writeToFile:filePath atomically:YES];
    NSString * str = [NSString stringWithContentsOfFile:GetDocumentPathWithFile(@"NetworkLog.txt") encoding:NSUTF8StringEncoding error:nil];
    dispatch_async(dispatch_get_main_queue(), ^(){
        self.logTextView.text = str;
    });
}

- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command
{
    [self.socketManager receiveMessageWithTimeOut:-1];
}

- (void)didReceiveACKWithState:(CTL_MESSAGE_PACKET)ACK
{}

- (void)didFinishConnectToHost
{}

- (void)didDisconnectSocket
{}

- (void)didReceiveLensStatus:(LENS_PARAMS)lensStatus
{}

- (void)didSetIRISWithStatus:(SDB_STATE)state
{}

- (void)didReceiveDebugInfo:(DEBUG_INFO)info
{}

- (void)didLoseAlive
{}

- (void)didReceiveDevInfo:(DEV_INFO)decInfo
{}

@end

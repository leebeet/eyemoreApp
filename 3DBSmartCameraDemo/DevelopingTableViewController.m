//
//  DevelopingTableViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/12.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import "DevelopingTableViewController.h"
#import "LogViewController.h"
#import "JLResourcePath.h"
#import "TCPSocketManager.h"
#import "CMDManager.h"
#import "SettingCamTableViewController.h"
#import "ProgressHUD.h"

@interface DevelopingTableViewController ()<TCPSocketManagerDelegate>
@property (strong, nonatomic) TCPSocketManager *socketManager;
@property (strong, nonatomic) UIAlertView      *resetAlert;
@end

@implementation DevelopingTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    self.socketManager.delegate = self;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier  isEqualToString:@"NetworkLogSegue"]) {
        
        LogViewController *controller = segue.destinationViewController;
        NSString * strMode = [NSString stringWithFormat:@"NetworkMode"];
        controller.mode = strMode;
    }
    if ([segue.identifier isEqualToString:@"LocalLogSegue"]) {
        
        LogViewController *controller = segue.destinationViewController;
        NSString * str = [NSString stringWithContentsOfFile:GetDocumentPathWithFile(@"MrNSLog.txt") encoding:NSUTF8StringEncoding error:nil];
        controller.content = str;
        NSString * strMode = [NSString stringWithFormat:@"LocalMode"];
        controller.mode = strMode;
    }
    
    if ([segue.identifier  isEqualToString:@"FullParameters"]) {
        
        SettingCamTableViewController *controller = segue.destinationViewController;
        controller.isDevelopUse = YES;
        
    }
    
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 6 && indexPath.section == 0) {
        if (!self.socketManager.isLost) {
            
            self.resetAlert = [[UIAlertView alloc] initWithTitle:@"确定恢复相机吗"
                               
                                                         message:@"是否恢复您的相机为出厂设置？"
                               
                                                        delegate:self
                               
                                               cancelButtonTitle:@"取消"
                               
                                               otherButtonTitles:@"恢复",nil];
            
            [self.resetAlert show];
            
            //[self.socketManager factoryReset];
        }
        else [ProgressHUD showError:@"连接已断开, 请连接相机后再试一次！" Interaction:NO];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView == self.resetAlert) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDFactoryReset];
    }
}

#pragma mark - TCP socket manager delegate

- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command
{
}
- (void)didSendData
{}

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

- (void)didSetIRISWithStatus:(SDB_STATE)state
{}

- (void)didReceiveDebugInfo:(DEBUG_INFO)info
{}

- (void)didLoseAlive
{}

- (void)didReceiveDevInfo:(DEV_INFO)decInfo
{}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

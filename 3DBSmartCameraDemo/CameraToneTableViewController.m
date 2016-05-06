//
//  CameraToneTableViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/12/17.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import "CameraToneTableViewController.h"
#import "TCPSocketManager.h"
#import "CMDManager.h"
#import "ProgressHUD.h"

@interface CameraToneTableViewController ()<TCPSocketManagerDelegate>

@property (nonatomic, strong) TCPSocketManager *socketManager;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation CameraToneTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    self.socketManager.delegate = self;
    
    // setup background color
    self.view.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)uploadToneFileWithFileName:(NSString *)name ofType:(NSString *)type toCameraPath:(const char *)path
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    self.socketManager.upLoadData = data;
    [self.socketManager sendUploadFileMessageWithCMD:(CTL_MESSAGE_PACKET)CMDUploadGeneralFile withPath:path]; //"/audio/begin.wav"

}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetSoundEnable(0)];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TCP socket delegate

- (void)didReceiveLensStatus:(LENS_PARAMS)lensStatus
{
}

- (void)didReceiveDevInfo:(DEV_INFO)decInfo
{
}

- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command
{
    [self.socketManager receiveMessageWithTimeOut:-1];
}

- (void)didSendData
{
    NSLog(@"did send voice file ");
    [NSThread sleepForTimeInterval:1.0f];
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetSoundEnable(1)];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [ProgressHUD showSuccess:@"设置成功！" Interaction:NO];
    });
}

- (void)didReceiveACKWithState:(CTL_MESSAGE_PACKET)ACK
{
    if (ACK.cmd == SDB_SET_SOUND_ENABLE_ACK && ACK.param0 == 0) {
        if (self.selectedIndexPath.section == 0) {
            if (self.selectedIndexPath.row == 0) {
                [self uploadToneFileWithFileName:@"begin_classic" ofType:@"wav" toCameraPath:"/audio/begin.wav"];
            }
            if (self.selectedIndexPath.row == 1) {
                [self uploadToneFileWithFileName:@"loadingGun" ofType:@"wav" toCameraPath:"/audio/begin.wav"];
            }
            if (self.selectedIndexPath.row == 2) {
                [self uploadToneFileWithFileName:@"begin_startwin" ofType:@"wav" toCameraPath:"/audio/begin.wav"];
            }
            dispatch_async(dispatch_get_main_queue(), ^(){
                [ProgressHUD show:@"正在设置..." Interaction:NO];
            });
        }
        if (self.selectedIndexPath.section == 1) {
            if (self.selectedIndexPath.row == 0) {
                [self uploadToneFileWithFileName:@"shot_classic" ofType:@"wav" toCameraPath:"/audio/shot.wav"];
            }
            if (self.selectedIndexPath.row == 1) {
                [self uploadToneFileWithFileName:@"shootGun" ofType:@"wav" toCameraPath:"/audio/shot.wav"];
            }
            if (self.selectedIndexPath.row == 2) {
                [self uploadToneFileWithFileName:@"shot_fastGun" ofType:@"wav" toCameraPath:"/audio/shot.wav"];
            }
            if (self.selectedIndexPath.row == 3) {
                [self uploadToneFileWithFileName:@"shot_bomb" ofType:@"wav" toCameraPath:"/audio/shot.wav"];
            }
            if (self.selectedIndexPath.row == 4) {
                [self uploadToneFileWithFileName:@"shot_whistle" ofType:@"wav" toCameraPath:"/audio/shot.wav"];
            }
            dispatch_async(dispatch_get_main_queue(), ^(){
                [ProgressHUD show:@"正在设置..." Interaction:NO];
            });
        }
    }
}

- (void)didFinishConnectToHost
{
}

- (void)didDisconnectSocket
{
}

- (void)didLoseAlive
{
}

- (void)didReceiveDebugInfo:(DEBUG_INFO)info
{
}
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

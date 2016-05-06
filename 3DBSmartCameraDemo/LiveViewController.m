//
//  LiveViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/24.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import "LiveViewController.h"
#import "LiveViewRecorder.h"
#import "ProgressHUD.h"
#import "VideoClient.h"
#import "HJImagesToVideo.h"

@interface LiveViewController ()<LiveViewRecorderDelegate>

@property (strong, nonatomic) UIImageView       *liveView;
@property (strong, nonatomic) LiveViewRecorder  *liveViewRecorder;
@property (weak, nonatomic) IBOutlet UILabel    *reconnectCounter;
@property (strong, nonatomic) VideoClient       *videoManager;
@property (strong, nonatomic) NSMutableDictionary   *sampleVideo;
@property (assign, nonatomic) int                downloadedFrameCount;

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.liveViewRecorder = [LiveViewRecorder sharedLiveViewRecorder];
    self.liveViewRecorder.delegate = self;
    
    self.liveView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width / 20 * 20, self.view.bounds.size.height / 3 * 2)];
    self.liveView.contentMode = UIViewContentModeScaleAspectFit;
    self.liveView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    [self.view addSubview:self.liveView];
    
    self.videoManager = [VideoClient sharedVideoClient];
    self.sampleVideo = [[NSMutableDictionary alloc] init];
    [self.sampleVideo setObject:@"0" forKey:@"Name"];
    self.downloadedFrameCount = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startButtonTapped:(id)sender {
    [self.liveViewRecorder startLiveViewing];
    self.downloadedFrameCount = 0;
}
- (IBAction)stopButtonTapped:(id)sender {
    [self.liveViewRecorder stopLiveViewing];
}
- (IBAction)mp4ButtonTapped:(id)sender {
    
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:
//                      [NSString stringWithFormat:@"Documents/movie.mp4"]];
//    
//    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    for (int i = 0; i < 200; i++) {
//        [array addObject:[UIImage imageWithData:[self.videoManager getFrameImageDataWithVideoDict:self.sampleVideo withIndex:(int)i]]];
//    }
//    dispatch_async(dispatch_get_global_queue(0, 0), ^(){
//        [HJImagesToVideo videoFromImages:array toPath:path withSize:CGSizeMake(480, 270) withFPS:20 animateTransitions:NO withCallbackBlock:^(BOOL success){
//            if (success) {
//                NSLog(@"Success");
//                dispatch_async(dispatch_get_main_queue(), ^(){
//                    [ProgressHUD showSuccess:@"封装完成" Interaction:NO];
//                });
//            } else {
//                NSLog(@"Failed");
//            }
//        }];
//    });
}

- (void)didGetLiveViewData:(NSData *)data
{

//    UIImage *image = [UIImage imageWithData:data];
//    dispatch_async(dispatch_get_main_queue(), ^(){
//        [self.liveView setImage:image];
//    });
//    [self.videoManager recordFrameContentWithFrameImage:data withFrameAudio:nil withFrameIndex:nil withIndex:self.downloadedFrameCount withVideoDict:self.sampleVideo];
//    
//    if (self.downloadedFrameCount == 199) {
//        
//        [self.liveViewRecorder stopLiveViewing];
//        dispatch_async(dispatch_get_main_queue(), ^(){
//            [ProgressHUD showSuccess:@"录制完成" Interaction:NO];
//        });
//    }
//    NSLog(@"current frame....................................:%d",self.downloadedFrameCount);
//    self.downloadedFrameCount ++;
}
- (void)didLoseLiveViewDataWithType:(LIVEVIEWOFFLINETYPE)type
{
    static int i = 0;
    dispatch_async(dispatch_get_main_queue(), ^(){
        self.reconnectCounter.text = [NSString stringWithFormat:@"%d", i];
    });
    
    i++;
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

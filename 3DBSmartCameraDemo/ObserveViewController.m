//
//  ObserveViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/3/26.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "ObserveViewController.h"
#import "ImageAlbumManager.h"
#import "ImageClient.h"

@interface ObserveViewController ()<imageClientDelegate>

@property (weak, nonatomic)   IBOutlet UIImageView *observeImageView;
@property (weak, nonatomic)   ImageClient          *imgClient;
@property (strong, nonatomic) NSMutableArray       *animationArray;
@property (strong, nonatomic) CALayer              *playLayer;
@property (strong, nonatomic) NSTimer              *timer;
@end

@implementation ObserveViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[ImageClient sharedImageClient] resetCompleteFlat];
    self.imgClient                    = [ImageClient sharedImageClient];
    self.imgClient.delegate           = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.timer = [[NSTimer alloc] init];
    self.observeImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.animationArray               = [[NSMutableArray alloc] init];
    self.playLayer                    = self.observeImageView.layer;
    [self.view.layer addSublayer:self.playLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
//    NSLog(@"TGR view controller received memory warning!");
//    [self.imgClient.imgCache clearMemory];
//    [self.imgClient.cacheData removeAllObjects];
//    self.imgClient = nil;
//    self.view = nil;
}

- (IBAction)takePhotoButtonTapped:(id)sender {
    [self pauseLayer:self.playLayer];
    [self.timer invalidate];
    NSLog(@"self.observeImageView.image :%@", self.observeImageView.layer.contents);
}
- (IBAction)observingButtonTapped:(id)sender {
    
    [self imageViewStartDisplay];
    //[self imageViewStartDisplay];

}
- (IBAction)resumeObservingButtonTapped:(id)sender {
    
    [self resumeLayer:self.playLayer];
}

- (void)imageViewStartDisplay
{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^(){
//        [self assemblingOneSecond];
//        dispatch_async(dispatch_get_main_queue(), ^(){
//            self.observeImageView.animationImages = self.animationArray;
//            NSLog(@"self.observeImageView.animationImages = %@", self.observeImageView.animationImages);
//            [self.observeImageView setAnimationDuration:0.5];
//            [self.observeImageView setAnimationRepeatCount:0];
//            [self.observeImageView startAnimating];
//        });
//    });
//    dispatch_async(dispatch_get_global_queue(0, 0), ^(){
        //[self.imgClient downloadImage];
 //       dispatch_async(dispatch_get_main_queue(), ^(){
//
//        });
//    });
}

- (void)assemblingOneSecond
{
    for (int i = 0; i < 5; i++) {
        [self observingOneFrame];
    }
}
- (void)observingOneFrame
{
    //[self.imgClient downloadImage];
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

#pragma mark Image Client Delegate

- (void)didFinishDownloadImage
{
    //[self.animationArray addObject: [self.imgClient getImageFromPath]];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
    [self.timer fire];
}
- (void)updateUI
{
    //[self.observeImageView setImage:[self.imgClient getImageFromPath]];
    //[self.imgClient downloadImage];
}
@end

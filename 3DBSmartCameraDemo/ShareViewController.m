//
//  ShareViewController.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/24.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "ShareViewController.h"
#import "Config.h"
#import "AFNetworking.h"
#import "eyemoreAPI.h"
#import "eyemoreUser.h"
#import "ProgressHUD.h"
#import "BLUIkitTool.h"
#import "BLImageRotation.h"

@interface ShareViewController ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *rotateButton;
@property (assign, nonatomic) UIImageOrientation imageOrientation;

@end

@implementation ShareViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpImageView];
    [self setUpRotateButton];
    //[self.uploadImageView setImage:[UIImage imageWithData:self.uploadData]];
    [self.imageIntroField becomeFirstResponder];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)]];
    self.imageOrientation = UIImageOrientationRight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpImageView
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 74, 100, 100)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.imageView setImage:[UIImage imageWithData:self.uploadData]];
    [self.view addSubview:self.imageView];
}

- (void)setUpRotateButton
{
    self.rotateButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.rotateButton setImage:[UIImage imageNamed:@"rotating.png"] forState:UIControlStateNormal];
    self.rotateButton.center = CGPointMake(self.imageView.center.x, self.imageView.center.y + 75);
    //self.rotateButton.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:1];
    self.rotateButton.layer.masksToBounds = YES;
    self.rotateButton.layer.cornerRadius = 5;
    self.rotateButton.layer.shadowOffset = CGSizeMake(0, 0);
    [self.rotateButton addTarget:self action:@selector(rotateButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rotateButton];
}

- (void)hideKeyBoard:(id)sender
{
    [self.imageIntroField resignFirstResponder];
}

- (void)rotateButtonTapped
{
    CGAffineTransform rotation;
    [self.rotateButton setEnabled:NO];
    if (self.imageOrientation == UIImageOrientationRight) {
        self.imageOrientation = UIImageOrientationUp;
        rotation = CGAffineTransformMakeRotation(-M_PI/2.0f);
    }
    else {
        self.imageOrientation = UIImageOrientationRight;
        rotation = CGAffineTransformMakeRotation(0);
    }
    
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.imageView setTransform:rotation];
    } completion:^(BOOL finished){
        [self.rotateButton setEnabled:YES];
    }];
}

- (IBAction)uploadButtonTapped:(id)sender
{
    [ProgressHUD show:@"正在发布" Interaction:NO];
    if (self.imageOrientation == UIImageOrientationUp) {
        self.uploadData = [BLUIkitTool dataFromImage:[BLImageRotation SetRotation:UIImageOrientationLeft withImageData:self.uploadData] metadata:nil mimetype:@"image/jpeg"];
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_UPLOAD]
        parameters:@{@"title": self.imageIntroField.text,
                    @"image":@"image"}constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
                        [formData appendPartWithFileData:self.uploadData name:@"image" fileName:@"image.jpg" mimeType:@"image/jpeg"];}
            progress:nil
            success:^(NSURLSessionDataTask *task, id responseObject){
                NSDictionary *result = (NSDictionary *)responseObject;
                NSInteger status = [[result objectForKey:@"status"] integerValue];
                if (status == 1) {
                    NSLog(@"upload image response :%@", [result objectForKey:@"results"]);
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        [ProgressHUD showSuccess:@"发布成功"];
                        [self dismissViewControllerAnimated:YES completion:nil];});
                }
                else {
                    [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
                }
            }
            failure:^(NSURLSessionDataTask *task, NSError *error){
                [ProgressHUD showError:@"发布失败, 请检查网络" Interaction:YES];
                NSLog(@"upload image error: %@", error);}];
}

- (IBAction)DismissController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

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

@interface ShareViewController ()

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
    [self.uploadImageView setImage:[UIImage imageWithData:self.uploadData]];
    [self.imageIntroField becomeFirstResponder];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)hideKeyBoard:(id)sender
{
    [self.imageIntroField resignFirstResponder];
}

- (IBAction)uploadButtonTapped:(id)sender
{
    [ProgressHUD show:@"正在发布" Interaction:NO];
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

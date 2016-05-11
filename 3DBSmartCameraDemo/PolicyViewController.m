//
//  PolicyViewController.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/5/10.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "PolicyViewController.h"

@interface PolicyViewController ()

@property (strong, nonatomic) UIWebView *OfflineWebView;

@end

@implementation PolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                               target:self
                                               action:@selector(dismissController)]];
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    self.OfflineWebView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.OfflineWebView];
    [self loadHtmlFileWithFileStyle:self.policyStyle];
}

- (void)loadHtmlFileWithFileStyle:(POLICYSTYLE)policy
{
    NSString *fileName = [NSString new];
    if (policy == USER_SERVICE_POLICY) {
        fileName = @"UserServicePolicy.html";
    }
    else {
        fileName = @"UserPrivacyPolicy.html";
    }
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL];
    [self.OfflineWebView loadRequest:request];
}

- (void)dismissController{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

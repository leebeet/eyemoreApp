//
//  HowToConnectController.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/5/10.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "HowToConnectController.h"

@interface HowToConnectController ()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation HowToConnectController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetCenterButtonHiden" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetCenterButtonShow" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetCenterButtonShow" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image = [UIImage imageNamed:@"howToConnect.jpg"];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 5.15)];
    [self.imageView setImage:image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.scrollView.scrollEnabled = YES;
    self.scrollView.contentSize = self.imageView.frame.size;
    self.scrollView.backgroundColor = [UIColor colorWithRed:30/255. green:30/255. blue:34/255. alpha:1];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scroll View Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    CGFloat alaph = (scrollView.contentOffset.y - 44) / 64.0;
//    self.navigationController.navigationBar.subviews.firstObject.alpha = (1 - alaph);
}

@end

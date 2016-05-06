//
//  RootNavigationController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/5/5.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "RootNavigationController.h"
#import "TCPSocketManager.h"

@interface RootNavigationController ()
{
    UIView *_navBackView;
}
@property (weak, nonatomic) IBOutlet UITabBarItem *sysnBarItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *downloadBarItem;
@property (weak, nonatomic) IBOutlet UITabBarItem *meBarItem;

@end

@implementation RootNavigationController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.navigationBar.barTintColor = [UIColor colorWithRed:95/255.0 green:200/255.0 blue:75/255.0 alpha:1];
    //self.navigationBar.barTintColor = [UIColor colorWithRed:8/255.0 green:8/255.0 blue:12/255.0 alpha:1];
    self.navigationBar.barStyle = UIBarStyleBlack;
    [self wipeNaviBarBottomBaseLine];
    self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor lightGrayColor],NSForegroundColorAttributeName,nil];
    self.navigationBar.tintColor = [UIColor lightGrayColor];
    self.navigationBar.translucent = YES;
    //[self addBlurEffect];
    //
//    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    
//    CGRect barFrame = self.navigationBar.frame;
//    CGRect blurFrame = CGRectMake(0, -20, CGRectGetWidth(barFrame), CGRectGetHeight(barFrame) + 20);
//    
//    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    blurView.frame = blurFrame;
//
    
//    [self.sysnBarItem     setSelectedImage:[UIImage imageNamed:@"tab1_active"]];
//    [self.downloadBarItem setSelectedImage:[UIImage imageNamed:@"media_active"]];
//    [self.meBarItem       setSelectedImage:[UIImage imageNamed:@"me_active"]];
}

- (void)wipeNaviBarBottomBaseLine
{
    //NavigationBar底部的黑线是一个UIImageView上的UIImageView
    if ([self.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        NSArray *list=self.navigationBar.subviews;
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView=(UIImageView *)obj;
                NSArray *list2=imageView.subviews;
                for (id obj2 in list2) {
                    if ([obj2 isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView2=(UIImageView *)obj2;
                        imageView2.hidden=YES;
                    }
                }
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
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

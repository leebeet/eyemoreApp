//
//  VideoListController.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/11.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "VideoListController.h"

@interface VideoListController ()
@property (nonatomic, strong) UIToolbar    *toolBar;
@end

@implementation VideoListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpNaviBar];
    self.view.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpNaviBar
{
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(DismissVideoBrowser)];
    btn1.tintColor = [UIColor whiteColor];
    NSArray *arr1=[[NSArray alloc]initWithObjects:btn1, nil];
    self.navigationItem.leftBarButtonItems = arr1;
}
- (void)DismissVideoBrowser
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

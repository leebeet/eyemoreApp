//
//  RootTabBarViewController.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/4/15.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCPSocketManager.h"

@interface RootTabBarViewController : UITabBarController<UITabBarControllerDelegate>
@property (nonatomic, strong) UIButton          *syncButton;
@end

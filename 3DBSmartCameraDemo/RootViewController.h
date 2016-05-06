//
//  RootViewController.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/5/6.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMPopLabel.h"
#import "JRMessageView.h"
#import "Wifiicon.h"
@interface RootViewController : UIViewController <JRMessageViewDelegate>
@property (strong, nonatomic) Wifiicon         *rightButton;
@property (strong, nonatomic) JRMessageView    *wifiMessageSuccess;
@property (strong, nonatomic) JRMessageView    *wifiMessageFail;
@end

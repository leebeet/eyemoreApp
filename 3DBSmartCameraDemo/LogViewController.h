//
//  LogViewController.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/10/10.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import "RootViewController.h"

@interface LogViewController : RootViewController
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *mode;
@end

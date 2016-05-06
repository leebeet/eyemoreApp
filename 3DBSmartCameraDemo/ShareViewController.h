//
//  ShareViewController.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/24.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *uploadImageView;
@property (weak, nonatomic) IBOutlet UITextView *imageIntroField;
@property (strong, nonatomic) NSData *uploadData;

@end

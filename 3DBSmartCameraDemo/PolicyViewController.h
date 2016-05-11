//
//  PolicyViewController.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/5/10.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _POLICYSTYLE{
    
    USER_SERVICE_POLICY,
    USER_PRIVACY_POLICY
}POLICYSTYLE;

@interface PolicyViewController : UIViewController

@property (assign,  nonatomic) POLICYSTYLE policyStyle;

@end

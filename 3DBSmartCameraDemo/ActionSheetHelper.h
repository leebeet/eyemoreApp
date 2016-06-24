//
//  ActionSheetHelper.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/6/23.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SocialRequestAssistant.h"

@interface ActionSheetHelper : NSObject

+ (void)actionShareSheetWithUserID:(NSInteger)userID
                            blogID:(NSInteger)blogID
                             image:(UIImage *)image
                            inView:(UIView *)view;

@end

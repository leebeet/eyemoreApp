//
//  BLUIkitTool.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/5/11.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BLUIkitTool : NSObject

+ (UIViewController *)currentRootViewController;
+ (NSString*)deviceVersion;
+ (void)redirectNSlogToDocumentFolder;
+ (NSData *)dataFromImage:(UIImage *)image metadata:(NSDictionary *)metadata mimetype:(NSString *)mimetype;

@end

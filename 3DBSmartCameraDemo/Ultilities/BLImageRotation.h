//
//  ImageRotation.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/4/8.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BLImageRotation : NSObject

+ (UIImage *)SetRotation:(UIImageOrientation)orientation withImage:(UIImage *)image;
+ (UIImage *)SetRotation:(UIImageOrientation)orientation withImageData:(NSData *)imageData;

//+(UIImage *)rotateImageWithImageData:(NSData *)aImageData withOrientation:(UIImageOrientation)orient;
@end

//
//  UIImage+Rotating.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/5/21.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "NYXImagesHelper.h"

@interface UIImage (Rotating)

-(UIImage*)rotateInRadians:(float)radians;

-(UIImage*)rotateInDegrees:(float)degrees;

-(UIImage*)rotateImagePixelsInRadians:(float)radians;

-(UIImage*)rotateImagePixelsInDegrees:(float)degrees;

-(UIImage*)verticalFlip;

-(UIImage*)horizontalFlip;

@end

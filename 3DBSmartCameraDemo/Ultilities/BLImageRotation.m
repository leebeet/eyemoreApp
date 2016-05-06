//
//  ImageRotation.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/4/8.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "BLImageRotation.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

/* Number of components for an opaque grey colorSpace = 3 */
#define kNyxNumberOfComponentsPerGreyPixel 3
/* Number of components for an ARGB pixel (Alpha / Red / Green / Blue) = 4 */
#define kNyxNumberOfComponentsPerARBGPixel 4
/* Minimun value for a pixel component */
#define kNyxMinPixelComponentValue (UInt8)0
/* Maximum value for a pixel component */
#define kNyxMaxPixelComponentValue (UInt8)255

/* Convert degrees value to radians */
#define NYX_DEGREES_TO_RADIANS(__DEGREES) (__DEGREES * 0.017453293) // (M_PI / 180.0f)
/* Convert radians value to degrees */
#define NYX_RADIANS_TO_DEGREES(__RADIANS) (__RADIANS * 57.295779513) // (180.0f / M_PI)

CGContextRef NYXCreateARGBBitmapContext(const size_t width, const size_t height, const size_t bytesPerRow, BOOL withAlpha);
CGImageRef NYXCreateGradientImage(const size_t pixelsWide, const size_t pixelsHigh, const CGFloat fromAlpha, const CGFloat toAlpha);
CIContext* NYXGetCIContext(void);
CGColorSpaceRef NYXGetRGBColorSpace(void);
void NYXImagesKitRelease(void);
BOOL NYXImageHasAlpha(CGImageRef imageRef);



@implementation BLImageRotation

+ (UIImage *)SetRotation:(UIImageOrientation)orientation withImage:(UIImage *)image
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}

+ (UIImage *)SetRotation:(UIImageOrientation)orientation withImageData:(NSData *)imageData
{
    UIImage *image = [UIImage imageWithData:imageData];
    return [BLImageRotation SetRotation:orientation withImage:image];
}


@end

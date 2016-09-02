//
//  BLImageEditor.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/7/28.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "BLImageEditor.h"

@implementation BLImageEditor

- (UIImage *)waterMarkImageWithBackgroundImage:(UIImage *)background waterMark:(UIImage *)markImage markPosition:(BLWaterMarkPosition)position
{
    //1.创建一个基于位图的上下文（开启一个基于位图的上下文）
    //size: 新图片的尺寸
    //opaque : 透明. NO为不透明,YES为透明
    //scale : 缩放
    //这段代码过后就相当于创建一个新的bitmap,也就是新的UImage对象
    UIGraphicsBeginImageContextWithOptions(background.size, NO, 0.0);
    
    //2.绘背景图至图形上下文
    [background drawInRect:CGRectMake(0, 0, background.size.width, background.size.height)];
    
    //3.绘水印至图形上下文
    CGFloat margin = 5;
    CGFloat scale = 1.0;
    CGFloat waterW = markImage.size.width * scale;
    CGFloat waterH = markImage.size.height * scale;
    CGRect  markPosition = CGRectZero;
    
    switch (position) {
            
        case PositionLeftTop: {
            CGFloat waterX = margin;
            CGFloat waterY = margin;
            markPosition = CGRectMake(waterX, waterY, waterW, waterH);
            break;
        }
            
        case PositionRightTop: {
            CGFloat waterX = background.size.width - waterW - margin;
            CGFloat waterY = margin;
            markPosition = CGRectMake(waterX, waterY, waterW, waterH);
            break;
        }
            
        case PositionLeftBottom: {
            CGFloat waterX = margin;
            CGFloat waterY = background.size.height - waterH -margin;
            markPosition = CGRectMake(waterX, waterY, waterW, waterH);
            break;
        }
            
        case PositionRightBottom: {
            CGFloat waterX = background.size.width - waterW - margin;
            CGFloat waterY = background.size.height - waterH -margin;
            markPosition = CGRectMake(waterX, waterY, waterW, waterH);
            break;
        }
            
        default:
            break;
    }
    [markImage drawInRect:markPosition];
    
    //4.从上下文取得制作完毕的UIImage对象
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //5.结束上下文
    UIGraphicsEndImageContext();
    
    return newImage;

}
@end

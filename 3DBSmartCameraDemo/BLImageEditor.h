//
//  BLImageEditor.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/7/28.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum _BLWaterMarkPosition {
    
    PositionLeftTop = 1,
    PositionRightTop = 2,
    PositionLeftBottom = 3,
    PositionRightBottom = 4
    
}BLWaterMarkPosition;

@interface BLImageEditor : NSObject

+ (UIImage *)waterMarkImageWithBackgroundImage:(UIImage *)background
                                     waterMark:(UIImage *)markImage
                                  markPosition:(BLWaterMarkPosition)position;

+ (NSData *)dataFromImage:(UIImage *)image
                 metadata:(NSDictionary *)metadata
                 mimetype:(NSString *)mimetype;
@end

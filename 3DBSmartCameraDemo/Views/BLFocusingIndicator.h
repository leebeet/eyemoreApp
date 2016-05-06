//
//  BLFocusingIndicator.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 16/1/25.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLFocusingIndicator : UIImageView

@property (nonatomic, assign) BOOL isFocusedDone;
@property (nonatomic, assign) BOOL isFocusing;

- (id)init;
- (void)startFocusingOnPosition:(CGPoint)position onView:(UIView *)view;
- (void)stopFocusing;
- (void)setFocusingDone;

@end

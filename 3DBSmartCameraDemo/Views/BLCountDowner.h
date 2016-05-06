//
//  BLCountDowner.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 16/3/9.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCountDowner;

@protocol BLCountDownerDelegate <NSObject>

@optional
- (void)BLCounterdidFinishCounting:(BLCountDowner *)counter ;

@end

@interface BLCountDowner : UIView

//typedef void (^FinishedBlock)();
@property (assign, nonatomic) id <BLCountDownerDelegate> delegate;
@property (strong, nonatomic) UILabel *countLabel;

- (instancetype)initWithCountTime:(NSInteger)time onView:(UIView *)superView withColor:(UIColor *)countColor withBeeping:(BOOL)isBeeping;
- (void)startCounting;

@end

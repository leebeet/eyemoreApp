//
//  BLRocker.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 16/3/1.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RockStyle)
{
    RockStyleOpaque = 0,
    RockStyleTranslucent
};

typedef NS_ENUM(NSInteger, RockDirection)
{
    RockDirectionLeft = 0,
    RockDirectionUp,
    RockDirectionRight,
    RockDirectionDown,
    RockDirectionCenter,
};

@protocol BLRockerDelegate;

@interface BLRocker : UIView

@property (weak ,nonatomic) id <BLRockerDelegate> delegate;
@property (nonatomic, readonly) RockDirection direction;

- (void)setRockerStyle:(RockStyle)style;
- (id)initWithFrame:(CGRect)frame handleView:(UIView *)handler;

@end


@protocol BLRockerDelegate <NSObject>

@optional
- (void)rockerDidChangeDirection:(BLRocker *)rocker;
- (void)rockerDidScanDirection:(BLRocker *)rocker;

@end

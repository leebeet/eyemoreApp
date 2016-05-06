//
//  BLAnimation.h
//  Sudoku
//
//  Created by ApplePerfect on 14-10-26.
//  Copyright (c) 2014年 Jan Lion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum _BLDirection {
    
    DirectionToLeft = 1,
    DirectionToRight = 2,
    DirectionToTop = 3,
    DirectionToBottom = 4
    
}BLDirection;

typedef enum _BLAnimationEffect {

    BLEffectFadeIn = 1,
    BLEffectFadeOut,
    BLEffectWhiteToRed,
    BLEffectRedToWhite
    
}BLAnimationEffect;


@interface BLAnimation : NSObject

+ (void)FlyToDestinationAnimationWithObject:(UIControl *)controller
                                 withDestination:(CGPoint)destination;

+ (void)scaleRotationAnimationWithObject:(UIView *)object withAngle:(float)angle;
+ (void)rotationAnimationWithObject:(UIView *)object withAngle:(float)angle;

+ (void)pushAnimationWithView:(UIView *)view
                     WithDirection:(BLDirection )direction
                     WithOffsetValueInX:(NSInteger)valueX
                     WithOffsetValueInY:(NSInteger)valueY
                             completion:(void (^)(BOOL finished))completion;
+ (void)pushAnimationWithViews:(NSArray *)views WithDirection:(BLDirection )direction WithOffsetValueInX:(NSInteger)valueX WithOffsetValueInY:(NSInteger)valueY completion:(void (^)(BOOL finished))completion;


+ (void)revealView:(UIView *)  view  WithBLAnimation:(BLAnimationEffect )anim completion:(void (^)(BOOL finished))completion;
+ (void)revealViews:(NSArray *)views WithBLAnimation:(BLAnimationEffect )anim completion:(void (^)(BOOL finished))completion;

@end

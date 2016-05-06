//
//  BLAnimation.m
//  Sudoku
//
//  Created by ApplePerfect on 14-10-26.
//  Copyright (c) 2014年 Jan Lion. All rights reserved.
//

#import "BLAnimation.h"

@implementation BLAnimation

+ (void)FlyToDestinationAnimationWithObject:(UIControl *)controller withDestination:(CGPoint)destination
{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
    anim.toValue = [NSValue valueWithCGPoint:destination];
    anim.duration = 0.8f;
    anim.autoreverses = YES;
    [controller.layer addAnimation:anim forKey:@"pos"];

}
+ (void)scaleRotationAnimationWithObject:(UIView *)object withAngle:(float)angle
{
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = @0;
    rotation.toValue = @(angle / 2);
    rotation.duration = 0.15f;
    rotation.delegate = self;
    
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @1;
    scale.toValue = @1.3;
    scale.duration = 0.15f;
    scale.delegate = self;
    scale.autoreverses = YES;
    
    [object.layer addAnimation:rotation forKey:@"rotation"];
    [object.layer addAnimation:scale forKey:@"scale"];
     object.transform = CGAffineTransformMakeRotation((CGFloat)(angle));
    //NSLog(@"rotation animation occur");

}

+ (void)rotationAnimationWithObject:(UIView *)object withAngle:(float)angle
{
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = @0;
    rotation.toValue = @(angle / 2);
    rotation.duration = 0.15f;
    rotation.delegate = self;
    
    [object.layer addAnimation:rotation forKey:@"rotation"];
    object.transform = CGAffineTransformMakeRotation((CGFloat)(angle));
    //NSLog(@"rotation animation occur");
    
}

+ (void)pushAnimationWithView:(UIView *)view WithDirection:(BLDirection )direction WithOffsetValueInX:(NSInteger)valueX WithOffsetValueInY:(NSInteger)valueY completion:(void (^)(BOOL finished))completion
{
    UIView *pushView = view;
    if (direction == DirectionToLeft) {//show view animation
        [UIView animateWithDuration:0.4
                              delay:0.1
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^(){
                             pushView.layer.affineTransform = CGAffineTransformTranslate(pushView.transform, valueX, valueY);
                             
                         }
                         completion:completion];
        
    }
    
    if (direction == DirectionToRight) {//hide view animation
        [UIView animateWithDuration:0.4
                              delay:0.1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(){
                             pushView.layer.affineTransform = CGAffineTransformTranslate(pushView.transform, valueX,valueY);
                             
                         }
                         completion:completion];
        
    }
}

+ (void)pushAnimationWithViews:(NSArray *)views WithDirection:(BLDirection )direction WithOffsetValueInX:(NSInteger)valueX WithOffsetValueInY:(NSInteger)valueY completion:(void (^)(BOOL finished))completion
{
    UIView *pushView1 = views[0];
    UIView *pushView2 = views[1];
    if (direction == DirectionToLeft) {//show view animation
        [UIView animateWithDuration:1
                              delay:0.1
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^(){
                             pushView1.layer.affineTransform = CGAffineTransformTranslate(pushView1.transform, valueX, valueY);
                             pushView2.layer.affineTransform = CGAffineTransformTranslate(pushView2.transform, valueX, valueY);
                             
                         }
                         completion:completion];
        
    }
    
    if (direction == DirectionToRight) {//hide view animation
        [UIView animateWithDuration:1
                              delay:0.1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(){
                             pushView1.layer.affineTransform = CGAffineTransformTranslate(pushView1.transform, valueX,valueY);
                             pushView2.layer.affineTransform = CGAffineTransformTranslate(pushView2.transform, valueX,valueY);
                             
                         }
                         completion:completion];
        
    }
}


+ (void)revealView:(UIView *)view WithBLAnimation:(BLAnimationEffect )anim completion:(void (^)(BOOL finished))completion
{
    if (anim == BLEffectFadeOut) {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState animations:^(){
                                view.alpha = 0.0;
        } completion:completion];
    }
    
    if (anim == BLEffectFadeIn) {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn animations:^(){
                                view.alpha = 1.0;
                            } completion:completion];
    }
//    if (anim == BLEffectRedToWhite) {
//        [UIView animateWithDuration:0.2
//                              delay:0.0
//                            options:UIViewAnimationOptionBeginFromCurrentState animations:^(){
//                                view.alpha = 0.0;
//                            } completion:completion];
//    }
}

+ (void)revealView:(UIView *)view WithBLAnimation:(BLAnimationEffect )anim WithDuration:(float)interval completion:(void (^)(BOOL finished))completion
{
    if (anim == BLEffectFadeOut) {
        [UIView animateWithDuration:interval
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState animations:^(){
                                view.alpha = 0.0;
                            } completion:completion];
    }
    
    if (anim == BLEffectFadeIn) {
        [UIView animateWithDuration:interval
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn animations:^(){
                                view.alpha = 1.0;
                            } completion:completion];
    }

}

+ (void)revealViews:(NSArray *)views WithBLAnimation:(BLAnimationEffect )anim completion:(void (^)(BOOL finished))completion
{
    if (anim == BLEffectFadeOut) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState animations:^(){
                                for (int i = 0; i < views.count; i++) {
                                    UIView *view = views[i];
                                    view.alpha = 0.0;
                                }
                            } completion:completion];
    }
    if (anim == BLEffectFadeIn) {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState animations:^(){
                                for (int i = 0; i < views.count; i++) {
                                    UIView *view = views[i];
                                    view.alpha = 1.0;
                                }
                            } completion:completion];
    }
}
@end

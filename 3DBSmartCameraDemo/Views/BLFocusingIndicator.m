//
//  BLFocusingIndicator.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 16/1/25.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "BLFocusingIndicator.h"

#define kFlashingCount 30

@interface BLFocusingIndicator ()

@property (assign, nonatomic) NSInteger   count;
@end

@implementation BLFocusingIndicator

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 50, 50);
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.transform = CGAffineTransformMakeScale(1.5, 1.5);
        self.alpha = 0;
    }
    return self;
}

- (void)startFocusingOnPosition:(CGPoint)position onView:(UIView *)view
{
    [self removeFromSuperview];
    [self setImage:[UIImage imageNamed:@"focusing"]];
    self.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.alpha = 0;
    
    [view addSubview:self];
    //self.center = position;
    [self setIndicatorPosition:position withView:view];
    
    [UIView animateWithDuration:0.2 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^(){
        self.transform = CGAffineTransformMakeScale(1, 1);
        self.alpha = 1.0;
    } completion:^(BOOL  finished){
        self.count = 0;
        self.isFocusedDone = NO;
        
        if (self.isFocusing == NO) {
            [self startFlashingEaseOut];
        }
    }];
}

- (void)stopFocusing
{
    self.isFocusing = NO;
    
    [UIView animateWithDuration:0.2 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^(){
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL  finished){
        [self removeFromSuperview];
    }];

}

- (void)setFocusingDone
{
    [self focusingDone];
}

- (void)focusingDone
{
    [self setImage:[UIImage imageNamed:@"focusingDone"]];
    
    self.isFocusedDone = YES;
    self.isFocusing = NO;
    
    [UIView animateWithDuration:0.2 delay:2.0f options:UIViewAnimationOptionCurveEaseIn animations:^(){
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL  finished){
        [self removeFromSuperview];
    }];
}

- (void)startFlashingEaseOut
{
    self.isFocusing = YES;
    
    if (self.count < kFlashingCount) {
        [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^(){
            self.alpha = 0.6;
        } completion:^(BOOL finished){
            if (self.isFocusedDone == NO) {
                self.count++;
                [self startFlashingEaseIn];
            }
        }];
    }
    if (self.count >= kFlashingCount) {
        [self stopFocusing];
        //[self focusingDone];
    }
    if (self.isFocusedDone) {
        [self focusingDone];
    }
}

- (void)startFlashingEaseIn
{
    if (self.count <= kFlashingCount) {
        [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^(){
            self.alpha = 1.0;
        } completion:^(BOOL finished){
            [self startFlashingEaseOut];
        }];
    }
}

- (void)setIndicatorPosition:(CGPoint)pos withView:(UIView *)view
{
    float posX = 0.0;
    float posY = 0.0;
    
    if (view.bounds.size.width - pos.x < self.frame.size.width / 2) {
        posX = view.bounds.size.width - self.frame.size.width / 2;
    }
    else if (view.bounds.size.width - pos.x > view.bounds.size.width - self.frame.size.width / 2) {
        posX = self.frame.size.width / 2;
    }
    else posX = pos.x;
    
    if (view.bounds.size.height - pos.y < self.frame.size.height / 2) {
        posY = view.bounds.size.height - self.frame.size.height / 2;
    }
    else if (view.bounds.size.height - pos.y > view.bounds.size.height - self.frame.size.height / 2) {
        posY = self.frame.size.height / 2;
    }
    else posY = pos.y;
    
    self.center = CGPointMake(posX, posY);
}

@end

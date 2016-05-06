//
//  BLCountDowner.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 16/3/9.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "BLCountDowner.h"
#import <AudioToolbox/AudioToolbox.h>

@interface BLCountDowner ()

@property (strong, nonatomic) NSTimer *countTimer;
@property (assign, nonatomic) NSInteger countTime;
@property (assign, nonatomic) BOOL isBeeping;
@end

@implementation BLCountDowner

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCountTime:(NSInteger)time onView:(UIView *)superView withColor:(UIColor *)countColor withBeeping:(BOOL)isBeeping
{
    self = [super init];
    if (self) {
        self.isBeeping = isBeeping;
        self.frame = superView.frame;
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.backgroundColor = [UIColor clearColor];
        [self setUpCountLabelWithColor:countColor];
        self.countTime = time;
        [superView addSubview:self];
    }
    return self;
}

- (void)setUpCountLabelWithColor:(UIColor *)color
{
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    [self.countLabel setFont:[UIFont systemFontOfSize:50]];
    [self.countLabel setTextAlignment:NSTextAlignmentCenter];
    [self.countLabel setTextColor:color];
    self.countLabel.alpha = 1;
    [self.countLabel setHidden:YES];
    [self addSubview:self.countLabel];
    self.countLabel.center = CGPointMake(self.center.x, self.center.y);
}

- (void)startCounting
{
    [self.countTimer invalidate];
    self.countTimer = nil;
    self.countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countingAnimation) userInfo:nil repeats:YES];
    
}

- (void)countingAnimation
{
    static NSInteger i = 0;
    
    if (i <= self.countTime) {
        [self.countLabel setText:[NSString stringWithFormat:@"%d", (int)(self.countTime - i)]];
        i ++;
        
        [self.countLabel setHidden:NO];
        self.countLabel.alpha = 1;
        
        if (self.isBeeping) {
            [self playBeep];
        }
        [UIView animateWithDuration:0.9f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(){
            CGAffineTransform scale = CGAffineTransformMakeScale(5, 5);
            [self.countLabel setTransform:scale];
            self.countLabel.alpha = 0;
        } completion:^(BOOL finished){
            [self.countLabel setHidden:YES];
            CGAffineTransform scale = CGAffineTransformMakeScale(1, 1);
            [self.countLabel setTransform:scale];

        }];
    }
    else {
        [self.countTimer invalidate];
        self.countTimer = nil;
        [self.countTimer setFireDate:[NSDate distantFuture]];
        i = 0;
        [self.delegate BLCounterdidFinishCounting:self];
        [self removeFromSuperview];
    }

}

- (void)playBeep
{
    SystemSoundID cameraSound_id = 1003;
    AudioServicesPlaySystemSound(cameraSound_id);
}

@end

//
//  ConnectionStatusView.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/5/16.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "ConnectionStatusView.h"

@implementation ConnectionStatusView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.frame = frame;
        float iconWidth = frame.size.width / 6;
        float iconHeight = frame.size.width / 6;
        
        self.deviceIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iconWidth, iconHeight)];
        self.deviceIcon.center = CGPointMake(iconWidth + iconWidth / 2, frame.size.height / 2);
        self.deviceIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self.deviceIcon setImage:[UIImage imageNamed:@"eyemore_v1_540.png"]];
        [self addSubview:self.deviceIcon];
        
        self.iPhoneIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iconWidth, iconHeight)];
        self.iPhoneIcon.center = CGPointMake(frame.size.width - iconWidth - iconWidth / 2, frame.size.height / 2);
        self.iPhoneIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self.iPhoneIcon setImage:[UIImage imageNamed:@"iphone6.png"]];
        [self addSubview:self.iPhoneIcon];
        
        self.forwardProgress = [[ConnectionProgressView alloc] initWithFrame:CGRectMake(0, 0, iconWidth * 2, 3)];
        self.forwardProgress.center = CGPointMake(frame.size.width / 2, frame.size.height / 2 - 5);
        self.forwardProgress.animateDirection = LDAnimateDirectionForward;
        self.forwardProgress.animate = YES;
        self.forwardProgress.stripeWidth = 10.0;
        [self addSubview:self.forwardProgress];
        
        self.backwardProgress = [[ConnectionProgressView alloc] initWithFrame:CGRectMake(0, 0, iconWidth * 2, 3)];
        self.backwardProgress.center = CGPointMake(frame.size.width / 2, frame.size.height / 2 + 5);
        self.backwardProgress.animateDirection = LDAnimateDirectionBackward;
        self.backwardProgress.animate = YES;
        self.backwardProgress.stripeWidth = 10.0;
        [self addSubview:self.backwardProgress];
        
        self.connectState = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        self.connectState.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        self.connectState.contentMode = UIViewContentModeScaleAspectFit;
        [self.connectState setImage:[UIImage imageNamed:@"connected_check"]];
        [self addSubview:self.connectState];
        
        self.battIndicator = [[BLBatteryView alloc] initWithFrame:CGRectMake(0, 0, 30, 15)];
        CGAffineTransform rotate = CGAffineTransformMakeRotation(-M_PI/2.0f);
        [self.battIndicator setTransform:rotate];
        self.battIndicator.center = CGPointMake(iconWidth - 10, self.deviceIcon.frame.size.height + self.deviceIcon.frame.origin.y - 13);
        [self.battIndicator setBatteryPowerProcessing:0];
        [self addSubview:self.battIndicator];
        
        self.settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        self.settingsButton.center  = CGPointMake(frame.size.width / 2, self.connectState.center.y + 35);
        self.settingsButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.settingsButton setImage:[UIImage imageNamed:@"settings.png"] forState:UIControlStateNormal];
        [self.settingsButton addTarget:self action:@selector(settingsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.settingsButton];
        
    }
    return self;
}

- (void)settingsButtonTapped
{
    if (self.settingButtonTappedHandler) {
        self.settingButtonTappedHandler(YES);
    }
}
- (void)setConnection:(BOOL)isConnected
{
    if (isConnected) {
        self.forwardProgress.animate = YES;
        self.backwardProgress.animate = YES;
        [self.settingsButton setHidden:NO];
        [self.connectState setImage:[UIImage imageNamed:@"connected_check"]];
    }
    else {
        self.forwardProgress.animate = NO;
        self.backwardProgress.animate = NO;
        [self.settingsButton setHidden:YES];
        [self.connectState setImage:[UIImage imageNamed:@"connected_error"]];
    }
}
@end

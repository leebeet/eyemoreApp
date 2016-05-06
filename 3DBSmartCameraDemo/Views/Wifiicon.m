//
//  Wifiicon.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/7.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "Wifiicon.h"

@implementation Wifiicon

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 70, 30);
        [self setImage:[UIImage imageNamed:@"error"] forState:UIControlStateNormal];
        [self setTitle:@"WiFi" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 8;
        self.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.layer.borderWidth = 1.5;
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

- (void)setIconConnected:(BOOL)isConnected
{
    if (isConnected) {
        [self setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    }
    else [self setImage:[UIImage imageNamed:@"error"] forState:UIControlStateNormal];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  CustomedToolBar.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 16/2/29.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "CustomedToolBar.h"

@implementation CustomedToolBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)aRect {
    if ((self = [super initWithFrame:aRect])) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];  //设置为背景透明，可以在这里设置背景图片
        //self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
        self.clearsContextBeforeDrawing = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // do nothing
}
@end

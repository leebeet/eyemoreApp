//
//  ConnectionProgressView.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/5/16.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "ConnectionProgressView.h"

@interface ConnectionProgressView ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) CGFloat offset;

@end

@implementation ConnectionProgressView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //self.frame = frame;
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.backgroundColor = [UIColor clearColor];
    self.stripeWidth = 15.0;
}

- (void)setAnimate:(BOOL)animate {
    _animate = animate;
    if (animate) {
        [self.timer invalidate];
        self.timer = nil;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementOffset) userInfo:nil repeats:YES];
    } else if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)incrementOffset {
    if (self.animateDirection == LDAnimateDirectionForward) {
        if (self.offset >= 0) {
            self.offset = -self.stripeWidth;
        } else {
            self.offset += 0.3;
        }
    } else {
        if (self.offset <= -self.stripeWidth) {
            self.offset = 0;
        } else {
            self.offset -= 0.3;
        }
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rectToDrawIn = rect;
    CGRect insetRect = CGRectInset(rectToDrawIn, 0, 0);
    [self drawStripes:context inRect:insetRect];
}

- (void)drawStripes:(CGContextRef)context inRect:(CGRect)rect {
    CGContextSaveGState(context);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.layer.cornerRadius] addClip];
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] colorWithAlphaComponent:0.8].CGColor);
    CGFloat xStart = self.offset, height = rect.size.height, width = self.stripeWidth, y = rect.origin.y;
    while (xStart < rect.size.width) {
        CGContextSaveGState(context);
        CGContextMoveToPoint(context, xStart, height + y);
        CGContextAddLineToPoint(context, xStart + width * 0.25, 0);
        CGContextAddLineToPoint(context, xStart + width * 0.75, 0);
        CGContextAddLineToPoint(context, xStart + width * 0.50, height + y);
        CGContextClosePath(context);
        CGContextFillPath(context);
        CGContextRestoreGState(context);
        xStart += width;
    }
    CGContextRestoreGState(context);
}
@end

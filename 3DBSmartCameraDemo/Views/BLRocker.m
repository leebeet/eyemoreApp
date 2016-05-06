//
//  BLRocker.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 16/3/1.
//  Copyright © 2016年 3DB. All rights reserved.
//
#import "BLRocker.h"

#define kRadius ([self bounds].size.width * 0.5f)
#define kTrackRadius kRadius * 0.8f
const float kMinimumGestureLength = 50.0f;

@interface BLRocker ()
{
    CGFloat _x;
    CGFloat _y;
    CGPoint _gestureStartPoint;
}

@property (strong, nonatomic) UIView *handleImageView;
@property (strong, nonatomic) NSTimer *constantTouchTimer;

@end

@implementation BLRocker

- (id)initWithFrame:(CGRect)frame handleView:(UIView *)handler
{
    if ((self = [super initWithFrame:frame]))
    {
        [self commonInitWithHandler:handler];
    }
    
    return self;
}

- (void)commonInitWithHandler:(UIView *)handler
{
    [self setRockerStyle:RockStyleOpaque];
    
    _direction = RockDirectionCenter;
    
    if (!_handleImageView) {
        _handleImageView = handler;
        [self addSubview:_handleImageView];
        [self resetHandle];
    }
    
    _x = 0;
    _y = 0;
    
    
}

- (void)setRockerStyle:(RockStyle)style
{
    //    NSArray *imageNames = @[@"rockerOpaqueBg",@"rockerTranslucentBg"];
    //
    //    [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:imageNames[style]]]];
}

- (void)resetHandle
{
    //_handleImageView.image = [UIImage imageNamed:@"handleNormal"];
    
    _x = 0.0;
    _y = 0.0;
    
    CGRect handleImageFrame = [_handleImageView frame];
    handleImageFrame.origin = CGPointMake(([self bounds].size.width - [_handleImageView bounds].size.width) * 0.5f,
                                          ([self bounds].size.height - [_handleImageView bounds].size.height) * 0.5f);
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionTransitionNone animations:^(){
        _handleImageView.frame = handleImageFrame;
    } completion:^(BOOL finished){}];
    
}

- (void)setHandlePositionWithLocation:(CGPoint)location
{
    _x = location.x - kRadius;
    _y = -(location.y - kRadius);
    
    float r = sqrt(_x * _x + _y * _y);
    
    if (r >= kTrackRadius) {
        
        _x = kTrackRadius * (_x / r);
        _y = kTrackRadius * (_y / r);
        
        location.x = _x + kRadius;
        location.y = -_y + kRadius;
        
        [self rockerValueChanged];
    }
    
    CGRect handleImageFrame = [_handleImageView frame];
    //    handleImageFrame.origin = CGPointMake(location.x - ([_handleImageView bounds].size.width * 0.5f),
    //                                          location.y - ([_handleImageView bounds].size.width * 0.5f));
    handleImageFrame.origin = CGPointMake(kRadius - ([_handleImageView bounds].size.width * 0.5f),
                                          location.y - ([_handleImageView bounds].size.width * 0.5f));
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionTransitionNone animations:^(){
    _handleImageView.frame = handleImageFrame;
    } completion:^(BOOL finished){}];
    
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //_handleImageView.image = [UIImage imageNamed:@"handlePressed"];
    
    //CGPoint location = [[touches anyObject] locationInView:self];
    
    //[self setHandlePositionWithLocation:location];
    
    UITouch *touch = [touches anyObject];
    
    _gestureStartPoint = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPosition = [touch locationInView:self];
    
    //float deltaX = fabs(_gestureStartPoint.x - currentPosition.x);
    
    float deltaY = fabs(_gestureStartPoint.y - currentPosition.y);
    
    if ( deltaY >= kMinimumGestureLength ) // && deltaX <= kMaximumVariance)
    {  
        [self setHandlePositionWithLocation:location];
        
    }
    
    //[self setHandlePositionWithLocation:location];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resetHandle];
    
    [self rockerValueChanged];
    
    [self.constantTouchTimer setFireDate:[NSDate distantFuture]];
    [self.constantTouchTimer invalidate];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resetHandle];
    
    [self rockerValueChanged];
    
    [self.constantTouchTimer setFireDate:[NSDate distantFuture]];
    [self.constantTouchTimer invalidate];

}

- (void)rockerValueChanged
{
    NSInteger rockerDirection = -1;
    
    float arc = atan2f(_y,_x);
    
    if ((arc > (3.0f/4.0f)*M_PI &&  arc < M_PI) || (arc < -(3.0f/4.0f)*M_PI &&  arc > -M_PI)) {
        rockerDirection = RockDirectionLeft;
    }else if (arc > (1.0f/4.0f)*M_PI &&  arc < (3.0f/4.0f)*M_PI) {
        rockerDirection = RockDirectionUp;
    }else if ((arc > 0 &&  arc < (1.0f/4.0f)*M_PI) || (arc < 0 &&  arc > -(1.0f/4.0f)*M_PI)) {
        rockerDirection = RockDirectionRight;
    }else if (arc > -(3.0f/4.0f)*M_PI &&  arc < -(1.0f/4.0f)*M_PI) {
        rockerDirection = RockDirectionDown;
    }else if (0 == _x && 0 == _y)
    {
        rockerDirection = RockDirectionCenter;
    }
    
    if (-1 != rockerDirection && rockerDirection != _direction) {
        _direction = rockerDirection;
        
        if ([self.delegate respondsToSelector:@selector(rockerDidChangeDirection:)])
        {
            [self.delegate rockerDidChangeDirection:self];
            [self.constantTouchTimer setFireDate:[NSDate distantFuture]];
            [self.constantTouchTimer invalidate];
            self.constantTouchTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(rockerDidScanDirection) userInfo:nil repeats:YES];

        }
    }
}

- (void)rockerDidScanDirection
{
    [self.delegate rockerDidScanDirection:self];
}

@end


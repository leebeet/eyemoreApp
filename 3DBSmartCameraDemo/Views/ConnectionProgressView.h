//
//  ConnectionProgressView.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/5/16.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LDAnimateDirection) {
    LDAnimateDirectionForward,
    LDAnimateDirectionBackward
};

@interface ConnectionProgressView : UIView

@property (assign, nonatomic) BOOL animate;
@property (assign, nonatomic) CGFloat stripeWidth;
@property (nonatomic) LDAnimateDirection animateDirection;

@end

//
//  TimeoutManager.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/11.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TimeOutManagerDelegate <NSObject>

@optional

- (void)didTimeoutWithInfo:(id)userInfo;

@end

@interface TimeoutManager : NSObject

@property (assign, nonatomic) id <TimeOutManagerDelegate>  delegate;
@property (strong, nonatomic) NSTimer             *timeOutTimer;
@property (strong, nonatomic) NSDictionary        *timeOutInfo;
@property (assign, nonatomic) BOOL                 isTimingOut;

+ (TimeoutManager *)sharedTimeOutManager;
- (void)setFinishTransfering;
- (void)executeTimeOutCounterWithCMD:(NSString *)cmd withAmout:(int)amout withTimeOut:(float)time repeat:(BOOL)flag;
- (void)stopTimeOutExecution;
@end

//
//  TimeoutManager.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/11.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import "TimeoutManager.h"

@interface TimeoutManager()
{
    NSDate *_finishDate;
    NSDate *_startDate;
}
@end

@implementation TimeoutManager

+ (TimeoutManager *)sharedTimeOutManager
{
    static TimeoutManager *instance = nil;
    if (instance == nil) {
        instance = [[TimeoutManager alloc] init];
    }
    return instance ;
}

- (void)setFinishTransfering
{
    _finishDate = self.timeOutTimer.fireDate;
}

- (void)executeTimeOutCounterWithCMD:(NSString *)cmd withAmout:(int)amout withTimeOut:(float)time repeat:(BOOL)flag
{
    //清空超时信息
    _startDate = self.timeOutTimer.fireDate;
    _finishDate = nil;
    self.timeOutInfo = nil;

    //超时计时开始
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.timeOutTimer setFireDate:[NSDate distantFuture]];
    [self.timeOutTimer invalidate];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (cmd) {
        [dict setObject:cmd forKey:@"CMD"];
    }
    if (amout) {
         [dict setObject:[NSString stringWithFormat:@"%d",amout] forKey:@"Number"];
    }
   
    
    self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:time
                                                         target:self
                                                       selector:@selector(timeOutHandle:)
                                                       userInfo:[dict copy]
                                                        repeats:flag];
    });
}

- (void)timeOutHandle:(NSTimer *)timer
{
    if (!_finishDate) {
        //self.isTimingOut = YES;
        [self.delegate didTimeoutWithInfo:(NSDictionary *)[timer userInfo]];
        
        //        if (!self.socketManager.isLost) {
        //            [self.socketManager tcpLingSocketConnectToHost];
        //            self.timeOutInfo = (NSDictionary *)[timer userInfo];
        //            [self.timeOutTimer setFireDate:[NSDate distantFuture]];
        //                [self.timeOutTimer invalidate];
        //        }
        //        else {
        //            [ProgressHUD showError:@"同步超时" Interaction:NO];
        //            [self.timeOutTimer invalidate];
        //        }        
    }
}

- (void)stopTimeOutExecution
{
    [self.timeOutTimer setFireDate:[NSDate distantFuture]];
    [self.timeOutTimer invalidate];
}
@end

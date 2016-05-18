//
//  LiveViewRecorder.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/24.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
typedef enum _LIVEVIEWOFFLINETYPE
{
    LiveSocketOfflineByServer,// 服务器掉线，默认为0
    LiveSocketOfflineByUser,  // 用户主动cut
    LiveSocketOfflineByCam,
    
}LIVEVIEWOFFLINETYPE;

typedef enum _VIEWING_MODE
{
    LIVE_VIEWING_MODE,
    LIVE_RECORDING_MODE,
    
}VIEWING_MODE;

@protocol LiveViewRecorderDelegate <NSObject>

@optional

- (void)didGetLiveViewData:(NSArray *)data;
- (void)didLoseLiveViewDataWithType:(LIVEVIEWOFFLINETYPE)type;

@end

@interface LiveViewRecorder : NSObject 

@property (strong, nonatomic) GCDAsyncSocket *liveViewSocket;
@property (weak, nonatomic) id <LiveViewRecorderDelegate> delegate;
@property (assign, nonatomic) VIEWING_MODE mode;
@property (assign, nonatomic) BOOL isConnected;

+ (LiveViewRecorder *)sharedLiveViewRecorder;
- (void)setViewingMode:(VIEWING_MODE)mode;
- (void)startLiveViewing;
- (void)stopLiveViewing;
- (void)autoRestartLiveViewing;

@end

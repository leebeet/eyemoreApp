//
//  PulseWaveController.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/6/25.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "ViewController.h"
#import "ImageClient.h"
#import "TCPSocketManager.h"
#import "LiveViewRecorder.h"
#import "VideoClient.h"
#import "VideoRecorder.h"
#import "eyemoreNotificaitions.h"
typedef enum _SHOOTMODE {
    
    SYNC_MODE = 1,

    SELFIE_MODE = 2,
    
    LIVEVIEW_MODE = 3,
    
    RECORDING_MOVIE_MODE = 4,
    
    HD_RECORDING_MODE = 5,
    
    DOWNLOAD_SYNCING_MODE = 6,
    
    TIME_LAPSE_MODE = 7
    
}SHOOTMODE;

@interface PulseWaveController : ViewController

//@property (weak,   nonatomic)   IBOutlet UIView            *wavePulser;
@property (strong, nonatomic)            UIView            *wavePulser;
@property (strong, nonatomic)            UIButton          *dimissButton;
@property (strong, nonatomic)            ImageClient       *imgClient;
@property (strong, nonatomic)            VideoClient       *videoManager;
@property (strong, nonatomic)            TCPSocketManager  *socketManager;
@property (strong, nonatomic)            VideoRecorder     *videoRecorder;
@property (strong, nonatomic)            LiveViewRecorder  *liveViewRecorder;
@property (strong, nonatomic)            UIImageView       *backGroundImageView;
@property (assign, nonatomic)            BOOL               autoRotate;
@property (assign, nonatomic)            SHOOTMODE          shootMode;

+ (PulseWaveController *)sharedPulseWaveController;

@end

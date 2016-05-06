//
//  ImageRecorder.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/23.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCPSocketManager.h"
#import "CMDManager.h"
#import "ImageClient.h"

@class ImageRecorder;
@protocol ImageRecorderDelegate <NSObject>
@optional

- (void)imageRecorder:(ImageRecorder *)recoder didDownLoadSingleImages:(NSData *)imageData;

@end

@interface ImageRecorder : NSObject <TCPSocketManagerDelegate>

@property (nonatomic, strong)     TCPSocketManager      *socketManager;
@property (nonatomic, assign) id <ImageRecorderDelegate> delegate;


@end


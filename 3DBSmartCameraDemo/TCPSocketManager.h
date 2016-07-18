//
//  TCPSocketManager.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/4/17.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#include "net_interface_params.h"
#import "eyemoreNotificaitions.h"

enum
{
    SocketOfflineByServer,// 服务器掉线，默认为0
    SocketOfflineByUser,  // 用户主动cut
};

typedef enum _erroCode{
    
    Error8007,
    Error80xx,
    
}ErroCode;

@protocol TCPSocketManagerDelegate <NSObject>

@optional

// lingACKDelegate
- (void)didFinishConnectToHost;
- (void)didDisconnectSocket;
- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command;
- (void)didSendData;
- (void)didReceiveACKWithState:(CTL_MESSAGE_PACKET)ACK;
- (void)didReceiveLensStatus:(LENS_PARAMS)lensStatus;
- (void)didReceiveDebugInfo:(DEBUG_INFO)info;
- (void)didReceiveDevInfo:(DEV_INFO)decInfo;

- (void)didLoseAlive;

// dataSourceDelegate
- (void)didFinishSingleFileDownloadingWithImageData:(NSData *)imageData;
- (void)didFinishBatchFilesDownloadingWithImageDataArray:(NSMutableArray *)imageDataArray;;
- (void)didFinishGetDEVInfo;
- (void)didFinishDownloadRecordingData:(NSData *)recordData withCMD:(CTL_MESSAGE_PACKET)CMD;


@end

@interface TCPSocketManager : NSObject<GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate>

@property (nonatomic, weak  ) id   <TCPSocketManagerDelegate>  delegate;
@property (nonatomic, strong)      GCDAsyncSocket             *lingSocket;   // 信令socket
@property (nonatomic, strong)      GCDAsyncSocket             *dataSocket;   // 数据socket
@property (nonatomic, strong)      GCDAsyncUdpSocket          *HBSocket;     // 心跳包socket
@property (nonatomic, strong)      GCDAsyncUdpSocket          *wakeUpSocket;
@property (nonatomic, copy  )      NSString                   *socketHost;   // 信令和数据socket的Host, 从服务器返回的心跳包初获取
@property (nonatomic, assign)      DEV_INFO                    deviceInfo;
@property (nonatomic, assign)      CTL_MESSAGE_PACKET          fileList;
@property (nonatomic, strong)      NSData                     *upLoadData;

@property (nonatomic, retain)      NSTimer                    *connectTimer; // 计时器
@property (nonatomic, strong)      NSData                     *receivedData;
@property (nonatomic, assign) BOOL                             isLost;
@property (nonatomic, assign) BOOL                             isTransforingData;

@property (nonatomic, assign)      LENS_PARAMS                 lensStatus;
@property (nonatomic, assign)      DEBUG_INFO                  debugInfo;
@property (nonatomic, assign)      DEV_INFO                    devInfo;

+ (TCPSocketManager *)sharedTCPSocketManager;

//socket的基本方法，连接，长连接，断开等
- (void)tcpLingSocketConnectToHost;
- (void)tcpDataSocketConnectToHost;
- (void)cutOffTcpSocketWithSocket:(GCDAsyncSocket *)socket;
- (void)UdpSocketConnet;
- (void)initLongConnectionToUdpSocket;

// 下载多文件之间，务必要先获取文件列表操作，即getFileList;
- (void)sendMessageWithCMD:(CTL_MESSAGE_PACKET)command;
- (void)sendUploadFileMessageWithCMD:(CTL_MESSAGE_PACKET)command withPath:(const char *)path;
- (void)receiveMessageWithTimeOut:(NSUInteger)timeOut;

// Keep Alive methods (ling socket)
- (void)startKeepingAlive;
- (void)stopKeepingAlive;
@end

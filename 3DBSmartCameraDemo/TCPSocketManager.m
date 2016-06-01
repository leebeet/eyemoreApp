//
//  TCPSocketManager.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/4/17.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "TCPSocketManager.h"
#import <arpa/inet.h>
#import "CMDManager.h"
#import "FirmwareManager.h"
#define ksendHBpacket                    21
#define ksendWakeupPacket                300

//Cam Data Tags (read)
#define kreadMessageTag                  22
#define kreadKeepAliveMessageTag         200

//// Cam Data Tags (read did)
#define kreadDidGetDEVInfoTag            27
#define kreadDidDownloadSingleFileTag    28
#define kreadDidDownloadAllFileTag       29

#define kreadDidDownloadGetFirstFrameTag 50
#define kreadDidDownloadGetFrameDesTag   51
#define kreadDidDownloadGetFrameTag      52
#define kreadDidDownloadLiveFrameTag     53

// Cam Data Tags (write)
#define kwriteMessageTag                 30
#define kwriteKeepAliveMessageTag        201

#define kLingSize                        84
#define kTimeInterval                    1
#define kLosePackRate                    5

#define kBroadCastAddr                   @"192.168.1.255"
#define kHost                            @"192.168.1.134"
#define kCameraFilePath                  "path/name"
#define kBatchNumber                     4

#define kSupportSocketState              1.04

@interface TCPSocketManager ()

{
    NSData *_fileData;
    NSData *_udpRecevieData;
    NSDate *_currentDate;
    NSDate *_receiveDate;
    CTL_MESSAGE_PACKET _dataArray;
    CTL_MESSAGE_PACKET _downloadedACK;
}

@property (nonatomic, assign) BOOL        isBroadcast;
@property (nonatomic, assign) CTL_MESSAGE_PACKET didSendCMD;
@property (nonatomic, assign) BOOL        isLingSocketConnected;
@property (nonatomic, assign) BOOL        isDataSocketConnected;

@property (nonatomic, strong) NSTimer    *keepAliveTimeOutTimer;
@property (nonatomic, strong) NSTimer    *wakeUpTimer;

@property (nonatomic, assign) BOOL        isKeepAliveMessage;


@end

@implementation TCPSocketManager

+ (TCPSocketManager *)sharedTCPSocketManager
{
    static TCPSocketManager *instance = nil;
    if (instance == nil) {
        instance = [[TCPSocketManager alloc] init];
    }
    return instance;
}

- (GCDAsyncSocket *)sharedLingSocket
{
    static GCDAsyncSocket *instance = nil;
    if (instance == nil) {
        dispatch_queue_t sQueue = dispatch_queue_create("client tcp signale ling socket", NULL);
        
        instance = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:sQueue];
    }
    return instance;
}

- (GCDAsyncSocket *)sharedDataSocket
{
    static GCDAsyncSocket *instance = nil;
    if (instance == nil) {
        dispatch_queue_t qQueue = dispatch_queue_create("client tcp data transfo socket", NULL);
        
        instance = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:qQueue];
    }
    return instance;
}


#pragma mark - Keep Network Alive System

- (void)sendKeepAliveMessage
{
    NSLog(@"send keep alive Message");
    
    NSDate *date = self.keepAliveTimeOutTimer.fireDate;
    
    NSDateFormatter *formatterSecond = [[NSDateFormatter alloc] init];
    NSDateFormatter *formatterMin    = [[NSDateFormatter alloc] init];
    NSDateFormatter *formatterHour   = [[NSDateFormatter alloc] init];
    NSDateFormatter *formatterDay    = [[NSDateFormatter alloc] init];
    NSDateFormatter *formatterMonth  = [[NSDateFormatter alloc] init];
    NSDateFormatter *formatterYear   = [[NSDateFormatter alloc] init];
    
    [formatterSecond setDateFormat:@"ss"];
    [formatterMin    setDateFormat:@"mm"];
    [formatterHour   setDateFormat:@"hh"];
    [formatterDay    setDateFormat:@"dd"];
    [formatterMonth  setDateFormat:@"MM"];
    [formatterYear   setDateFormat:@"yy"];
    
    NSString *currentdateSecond = [formatterSecond   stringFromDate:date];
    NSString *currentdateMin    = [formatterMin      stringFromDate:date];
    NSString *currentdateHour   = [formatterHour     stringFromDate:date];
    NSString *currentdateDay    = [formatterDay      stringFromDate:date];
    NSString *currentdateMonth  = [formatterMonth    stringFromDate:date];
    NSString *currentdateYear   = [formatterYear     stringFromDate:date];
    
    DateTime currentDate;
    currentDate.year     = (unsigned int)[currentdateYear intValue];
    currentDate.month    = (unsigned int)[currentdateMonth intValue];
    currentDate.day      = (unsigned int)[currentdateDay intValue];
    currentDate.hours    = (unsigned int)[currentdateHour intValue];
    currentDate.minutes  = (unsigned int)[currentdateMin intValue];
    currentDate.senconds = (unsigned int)[currentdateSecond intValue];

    
    CTL_MESSAGE_PACKET signalLing = (CTL_MESSAGE_PACKET)CMDGetDeviceInfo;
    //memcpy(signalLing.paramn, &currentDate, sizeof(DateTime));
    signalLing.paramn[0] = currentDate.year;
    signalLing.paramn[1] = currentDate.month;
    signalLing.paramn[2] = currentDate.day;
    signalLing.paramn[3] = currentDate.hours;
    signalLing.paramn[4] = currentDate.minutes;
    signalLing.paramn[5] = currentDate.senconds;
    signalLing.paramn[6] = 0;
    
    NSLog(@"paramn[0]:%u,paramn[1]:%u,paramn[2]:%u,paramn[3]:%u,paramn[4]:%u,paramn[5]:%u",
          signalLing.paramn[0],
          signalLing.paramn[1],
          signalLing.paramn[2],
          signalLing.paramn[3],
          signalLing.paramn[4],
          signalLing.paramn[5]);
    
    NSData            *cmdData    = [[NSData alloc] initWithBytes:&signalLing length:sizeof(signalLing)];
    [self.lingSocket writeData:cmdData withTimeout:3 tag:kwriteKeepAliveMessageTag];
}

- (void)initKeepAlive
{
    self.keepAliveTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(sendKeepAliveMessage) userInfo:nil repeats:YES];
}
- (void)startKeepingAlive
{
//    self.keepAliveTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(sendKeepAliveMessage) userInfo:nil repeats:YES];
    [self.keepAliveTimeOutTimer setFireDate:[NSDate distantPast]];
}

- (void)stopKeepingAlive
{
    [self.keepAliveTimeOutTimer setFireDate:[NSDate distantFuture]];
    //[self.keepAliveTimeOutTimer invalidate];
}

- (void)wakeupDevice
{
    NSLog(@"send wake up msg");
    // 发送心跳包
    HB_PACKET HBPack      = {"CE1D42C0-EB5E-44DD-AB92-66F8E2D1947A"};
    
    NSData   *dataStream  = [[NSData alloc] initWithBytes:&HBPack length:sizeof(HBPack)];
    
    [self.wakeUpSocket sendData:dataStream toHost:@"192.168.1.1" port:65001 withTimeout:-1 tag:ksendWakeupPacket];
    [self.wakeUpSocket beginReceiving:nil];
    //[self.HBSocket sendData:dataStream withTimeout:-1 tag:ksendHBpacket];
}


#pragma mark - Receiving / Sending  Methods / commands - TCP Manager Functions

- (void)sendMessageWithCMD:(CTL_MESSAGE_PACKET)command
{
    NSLog(@"send CMD Message :%d", command.cmd);
    
    CTL_MESSAGE_PACKET signalLing = command;
    NSData            *cmdData    = [[NSData alloc] initWithBytes:&signalLing length:sizeof(signalLing)];
    [self.lingSocket writeData:cmdData withTimeout:-1 tag:kwriteMessageTag];
    
    self.didSendCMD = command;
}

- (void)sendUploadFileMessageWithCMD:(CTL_MESSAGE_PACKET)command withPath:(const char *)path
{
    CTL_MESSAGE_PACKET signalLing = command;
    [self.lingSocket writeData:[self packingUploadFileInfoWithCMD:signalLing withPath:path] withTimeout:-1 tag:kwriteMessageTag];
    
    self.didSendCMD = command;

}

- (void)receiveMessageWithTimeOut:(NSUInteger)timeOut
{
    NSLog(@"receiving message");
    [self.lingSocket readDataToLength:kLingSize withTimeout:timeOut tag:kreadMessageTag];
}

- (void)receiveKeepAliveMessageWithTimeOut:(NSUInteger)timeOut
{
    NSLog(@"receiving keep alive message");
    [self.lingSocket readDataToLength:kLingSize withTimeout:timeOut tag:kreadKeepAliveMessageTag];
}

#pragma mark - Private Methods - download / upload data methods

- (void)downloadSingleFileStreamWithLength:(NSUInteger )length
{
    //NSLog(@"file length : %lu", (unsigned long)length);
    [self.dataSocket readDataToLength:length withTimeout:-1 tag:kreadDidDownloadSingleFileTag];
}

- (void)downloadAllFilesStreamWithLength:(NSUInteger )length
{
    [self.dataSocket readDataToLength:length withTimeout:-1 tag:kreadDidDownloadAllFileTag];
    NSLog(@"download all file stream with length : %lu", (unsigned long)length);
}

- (void)downloadDataStreamWithLength:(NSUInteger)length withTag:(int)tag
{
    [self.dataSocket readDataToLength:length withTimeout:10 tag:tag];
}

- (void)getDeviceInfoStreamWithLength:(NSUInteger )length
{
    //NSLog(@"%lu length",(unsigned long)length);
    [self.dataSocket readDataToLength:length withTimeout:-1 tag:kreadDidGetDEVInfoTag];
}

- (void)extractStreamWithArray:(unsigned int *)paramn withDownloadedData:(NSData *)data
{
    //此方法后续应考虑是否使用使用多线程
    
    NSMutableArray *fileArray = [[NSMutableArray alloc] init];
    NSUInteger      fileCount = [[NSNumber numberWithChar:_dataArray.param1] integerValue];
    int t = 0;
    
    for (int i = 0; i < fileCount; i++) {
        if (i == 0) {
            _fileData         = [data subdataWithRange:NSMakeRange(0, _dataArray.paramn[i])];
        }
        else _fileData        = [data subdataWithRange:NSMakeRange(t, _dataArray.paramn[i])];
        
        [fileArray addObject:_fileData];
        t = t + _dataArray.paramn[i];
    }
    
    NSLog(@"成功获取数据流，共有: %lu个文件  %lu", (unsigned long)fileArray.count, (unsigned long)[fileArray[0] length]);
    
    [self.delegate didFinishBatchFilesDownloadingWithImageDataArray:fileArray];
    //return fileArray;
}

#pragma mark - extract and packing data

- (void)extractLensStatuWithData:(CTL_MESSAGE_PACKET)data
{
    LENS_PARAMS *lens;
    lens = (LENS_PARAMS *)data.paramn;
    self.lensStatus = *(lens);
    [self.delegate didReceiveLensStatus:self.lensStatus];
}

- (void)extractDebugInfoWithData:(CTL_MESSAGE_PACKET)data
{
    DEBUG_INFO *info;
    info = (DEBUG_INFO *)data.paramn;
    self.debugInfo = *(info);
    [self.delegate didReceiveDebugInfo:self.debugInfo];
}

- (void)extractDevInfoWithData:(CTL_MESSAGE_PACKET)data
{
    DEV_INFO *devInfo;
    devInfo = (DEV_INFO *)data.paramn;
    self.devInfo = *(devInfo);
    if (self.isKeepAliveMessage == NO) {
        [self.delegate didReceiveDevInfo:self.devInfo];
    }
    else {
        [self checkDataSocketState:self.devInfo];
    }
    
}

- (NSData *)packingUploadFileInfoWithCMD:(CTL_MESSAGE_PACKET)command withPath:(const char * )path
{
    UPLOAD_GFILE_STRUCT file;
    file.size = (int)[self.upLoadData length];
    strcpy(file.pathname, path);
    memcpy(command.paramn, &file, sizeof(file));

    NSData  *cmdData    = [[NSData alloc] initWithBytes:&command length:sizeof(command)];
    return cmdData;
}

- (void)uploadSingleFileStreamWithData:(NSData *)data
{
    [self.dataSocket writeData:data withTimeout:-1 tag:kwriteMessageTag];
}

- (int)getLengthOfAllFilesWithACK:(CTL_MESSAGE_PACKET )ACK
{
    int count       = (int)ACK.param1;
    int totalLength = 0;
    for (int i = 0; i < count; i++) {
        totalLength = totalLength + ACK.paramn[i];
    }
    //NSLog(@"total length : %d", totalLength);
    return totalLength;
}

- (void)notifyIsTCPConnectionLost:(BOOL) isLost
{
    if (isLost) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyTCPConnectionDidLost" object:nil];
    }
    else [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyTCPConnectionDidConnect" object:nil];
}

- (void)checkDataSocketState:(DEV_INFO)devInfo
{
    //float ver = [[[FirmwareManager sharedFirmwareManager].camVerison substringFromIndex:1] floatValue];
    static int count = 0;
    //if (devInfo.datasocketstatus == 0 && ver > kSupportSocketState) {
    if (devInfo.datasocketstatus == 0 ) {
        count++;
        NSLog(@"tcp data socket error, reconnect count :%d", count);
        
    }
    if (count > 3) {
        NSLog(@"tcp data socket error, reconnect now");
        [self sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDOpenDataChannel];
        count = 0;
    }
}
#pragma mark - Socket Connection Operations


// UDPsocket Connect

- (void)UdpSocketConnet{
    
    self.isLost = NO;
    
    NSLog(@"trying connect to server");
    dispatch_queue_t dQueue = dispatch_queue_create("client udp socket", NULL);
    
     self.HBSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dQueue];
    [self.HBSocket setIPv4Enabled:YES];
    [self.HBSocket setIPv6Enabled:NO];
    
    NSError *connetError  = nil;
    [self.HBSocket bindToPort:SERVER_BROADCAST_PORT error:&connetError];
    //[self.HBSocket connectToHost:kBroadCastAddr onPort:SERVER_BROADCAST_PORT error:nil];
    if (connetError) {
        NSLog(@"%@", connetError);
    }
}

- (void)initLongConnectionToUdpSocket
{

    NSError *receiveError = nil;
    
    [self.HBSocket enableBroadcast:NO error:nil];

    self.isBroadcast = YES;
    
    // 广播一个心跳包出去
    HB_PACKET HBPack = {"CE1D42C0-EB5E-44DD-AB92-66F8E2D1947A"};
    //NSLog(@"%lu",sizeof(HBPack));
    
    NSData *dataStream = [[NSData alloc] initWithBytes:&HBPack length:sizeof(HBPack)];
    NSLog(@"%lu", sizeof(HBPack));
    [self.HBSocket sendData:dataStream toHost:kHost port:SERVER_BROADCAST_PORT withTimeout:-1 tag:ksendHBpacket];
    
    // 服务器收到广播信息后反馈信息回给客户端
    //[self.HBSocket receiveOnce:&receiveError];
    [self.HBSocket beginReceiving:&receiveError];
    
    if (receiveError) {
        NSLog(@"%@",receiveError);
    }
    
    [self.connectTimer invalidate];
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(longConnectToUdpSocket) userInfo:nil repeats:YES];
    // 在longConnectToSocket方法中进行长连接需要向服务器发送的讯息，短时间发送心跳包
    
    [self.connectTimer fire];
    
    [self.keepAliveTimeOutTimer invalidate]; 
    self.keepAliveTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(sendKeepAliveMessage) userInfo:nil repeats:YES];
}

- (void)initLongWakeupUDPSocketConnect
{
    
    dispatch_queue_t wQueue = dispatch_queue_create("wake up udp socket", NULL);
    
    self.wakeUpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:wQueue];
    [self.wakeUpSocket setIPv4Enabled:YES];
    [self.wakeUpSocket setIPv6Enabled:NO];
    
//    NSError *connetError  = nil;
//    //[self.wakeUpSocket bindToPort:65001 error:&connetError];
//    //[self.HBSocket connectToHost:kBroadCastAddr onPort:SERVER_BROADCAST_PORT error:nil];
//    if (connetError) {
//        NSLog(@"%@", connetError);
//    }
    
    //NSError *receiveError = nil;
    
    [self.wakeUpSocket enableBroadcast:YES error:nil];
    
    self.isBroadcast = YES;
    
    // 广播一个心跳包出去
    HB_PACKET HBPack = {"CE1D42C0-EB5E-44DD-AB92-66F8E2D1947A"};
    //NSLog(@"%lu",sizeof(HBPack));
    
    NSData *dataStream = [[NSData alloc] initWithBytes:&HBPack length:sizeof(HBPack)];
    NSLog(@"%lu", sizeof(HBPack));
    [self.wakeUpSocket sendData:dataStream toHost:@"192.168.1.1" port:65001 withTimeout:-1 tag:ksendWakeupPacket];
    [self.wakeUpSocket beginReceiving:nil];
    
    // 服务器收到广播信息后反馈信息回给客户端
    //[self.HBSocket receiveOnce:&receiveError];
//    [self.wakeUpSocket beginReceiving:&receiveError];
//    
//    if (receiveError) {
//        NSLog(@"%@",receiveError);
//    }
}

// socket连接
- (void)tcpLingSocketConnectToHost{
    
    self.lingSocket = [self sharedLingSocket];
    
    NSError *error  = nil;
    
    //[self cutOffTcpSocketWithSocket:self.lingSocket];
    //[self.lingSocket disconnect];
    //[self.dataSocket disconnect];
    
    [self.lingSocket connectToHost:kHost onPort:SERVER_CTL_PORT  withTimeout:3 error:&error];
    
    self.lingSocket.userData = SocketOfflineByServer;
}

- (void)tcpDataSocketConnectToHost{
    
    self.dataSocket = [self sharedDataSocket];
    
    NSError *error2 = nil;
    
    [self.dataSocket disconnect];
    
    [self.dataSocket connectToHost:kHost onPort:SERVER_DATA_PORT withTimeout:3 error:&error2];
    
    self.dataSocket.userData = SocketOfflineByServer;
}

// tcp 长连接
- (void)longConnectToTcpSocket
{
    // 根据服务器要求发送固定格式的数据，假设为指令@"longConnect"，但是一般不会是这么简单的指令
    
    NSString *longConnect = @"longConnect";
    
    NSData   *dataStream  = [longConnect dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.lingSocket writeData:dataStream withTimeout:1 tag:100];
    [self.dataSocket writeData:dataStream withTimeout:1 tag:101];
}

// udp 长连接
- (void)longConnectToUdpSocket
{
    
    // 发送心跳包
    HB_PACKET HBPack      = {"CE1D42C0-EB5E-44DD-AB92-66F8E2D1947A"};
    
    NSData   *dataStream  = [[NSData alloc] initWithBytes:&HBPack length:sizeof(HBPack)];
    
    [self.HBSocket sendData:dataStream toHost:kHost port:SERVER_BROADCAST_PORT withTimeout:-1 tag:ksendHBpacket];
    //[self.HBSocket sendData:dataStream withTimeout:-1 tag:ksendHBpacket];
    
    // 服务器收到广播信息后反馈信息回给客户端
    [self.HBSocket receiveOnce:nil];
    [self.HBSocket beginReceiving:nil];
    
    // 服务端心跳包反馈处理，网络状态监测, 如果心跳包丢失，断开tcp连接。当心跳包恢复正常后重新连接
    _currentDate = self.connectTimer.fireDate;
    
    if ([self judgeIfConnectionDidLostWithCurrentDate:_currentDate lastDate:_receiveDate]) {
        
        //NSLog(@"self. is lost :%s", self.isLost ? "yes":"no");
        [self cutOffTcpSocketWithSocket:self.lingSocket];
        [self cutOffTcpSocketWithSocket:self.dataSocket];
        self.isLost = YES;
        
        //start to broadcast msg to camera
        [self initLongWakeupUDPSocketConnect];
        [self.wakeUpTimer invalidate];
        self.wakeUpTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(wakeupDevice) userInfo:nil repeats:YES];
        [self.wakeUpTimer setFireDate:[NSDate distantPast]];

    }
    else{
        //NSLog(@"self. is lost :%s", self.isLost ? "yes":"no");

        if (self.isLost) {
            [self tcpLingSocketConnectToHost];
            self.isLost = NO;
            
            //stop broadcasting msg to camera
            [self.wakeUpTimer setFireDate:[NSDate distantFuture]];
            NSLog(@"stop sending wake up msg");
            //连接成功后改为正常时间发送心跳包
            [self.connectTimer invalidate];
             self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeInterval target:self selector:@selector(longConnectToUdpSocket) userInfo:nil repeats:YES];
            [self.connectTimer fire];
        }
    }
}

// 切断socket
-(void)cutOffTcpSocketWithSocket:(GCDAsyncSocket *)socket {
    
//    self.lingSocket.userData = [NSNumber numberWithInt:SocketOfflineByUser];// 声明是由用户主动切断
//    self.dataSocket.userData = [NSNumber numberWithInt:SocketOfflineByUser];// 声明是由用户主动切断
//    
//    [self.lingSocket disconnect];
//    [self.dataSocket disconnect];
    socket.userData = [NSNumber numberWithInt:SocketOfflineByUser];
    [socket disconnect];
}


// 判断心跳包规则, 丢失3个包以上认为失去连接

- (BOOL)judgeIfConnectionDidLostWithCurrentDate:(NSDate *)currentDate lastDate:(NSDate *)lastDate
{
//    NSDateFormatter *formatterSecond = [[NSDateFormatter alloc] init];
//    NSDateFormatter *formatterMin    = [[NSDateFormatter alloc] init];
//    
//    [formatterSecond setDateFormat:@"ss"];
//    [formatterMin    setDateFormat:@"mm"];
//    
//    NSString *currentdateSecond = [formatterSecond   stringFromDate:currentDate];
//    NSString *lastdateSecond    = [formatterSecond   stringFromDate:lastDate];
//    
//    NSString *currentdateMin    = [formatterMin      stringFromDate:currentDate];
//    NSString *lastdateMin       = [formatterMin      stringFromDate:lastDate];
//    
//    int       date1second       = [currentdateSecond intValue];
//    int       date2second       = [lastdateSecond    intValue];
//    
//    int       date1Min          = [currentdateMin    intValue];
//    int       date2Min          = [lastdateMin       intValue];
//    
//    int       total1Second      = date1Min * 60 + date1second;
//    int       total2Second      = date2Min * 60 + date2second;
    
    //NSInteger timeDifference = [currentDate timeIntervalSinceDate:lastDate];
    NSTimeInterval total1Interval = [currentDate timeIntervalSince1970];
    NSTimeInterval total2Interval = [lastDate timeIntervalSince1970];
    
    NSInteger timeDifference = total1Interval - total2Interval;
        
    if ((timeDifference) >= kTimeInterval * kLosePackRate) {
            
        // 心跳包丢失，关闭所有tcp连接
        //NSLog(@"total1 second: %d, total2 second: %d, %d, 已经丢失网络连接", total1Second, total2Second, abs(total1Second - total2Second));
        NSLog(@"Total1:%f, Total2: %f, difference: %ld, 已经丢失网络连接", total1Interval, total2Interval, (long)timeDifference);
        
        return YES;
    }
    else {
        
        // 心跳包正常，保持tcp连接，若已经关闭，重新连接tcp
       // NSLog(@"total1 second: %d, total2 second: %d, %d, 网络连接正常",    total1Second, total2Second, abs(total1Second - total2Second));
        NSLog(@"Total1:%f, Total2: %f, difference: %ld, 网络连接正常", total1Interval, total2Interval, (long)timeDifference);
        return NO;
    }
}

#pragma mark - GCD Async Udp Socket Delegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    NSLog(@"host: %@", [GCDAsyncSocket hostFromAddress:address]);
    
    if ([[GCDAsyncSocket hostFromAddress:address] isEqualToString:kHost]) {
        
        HB_PACKET ACK;
        
        [data getBytes:&ACK length:sizeof(ACK)];
        
        _receiveDate = self.connectTimer.fireDate;
        
        if (sock == self.wakeUpSocket) {
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"wake up ack: %@", string);
        }
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    NSLog(@"udp did connect to server");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    if (tag == ksendHBpacket) {
        NSError *error = nil;
        [self.HBSocket beginReceiving:&error];
        if (error) {
            NSLog(@"receive data error :%@", error);
        }
    }
}

#pragma mark - GCD Async Socket delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"tcp socket did connect to host with socket :%@", sock);
   // static int i = 0;
    if (sock == self.lingSocket) {
        //i = i + 1;
        self.isLingSocketConnected = YES;
        self.isDataSocketConnected = NO;
        self.lingSocket.userData = SocketOfflineByServer;
        [self sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDOpenDataChannel];
    }
    if (sock == self.dataSocket) {
        //i = i + 1;
        self.isDataSocketConnected = YES;
        self.lingSocket.userData = SocketOfflineByServer;
    }
    if (self.isLingSocketConnected == YES && self.isDataSocketConnected == YES) {
        [self.delegate didFinishConnectToHost];
        //i = 0;

        self.isKeepAliveMessage = NO;
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    
    NSLog(@"sorry the connect is failure %@ with socket %@:",sock.userData, sock);
    //static int i = 0;
    if (sock == self.lingSocket) {
        //i = i + 1;
        //self.isLostConnection = YES;
        self.isLingSocketConnected = NO;
        self.isDataSocketConnected = YES;
        if (sock.userData == SocketOfflineByServer) {
            // 服务器掉线，重连
            NSLog(@"server lost");
            [self tcpLingSocketConnectToHost];
        }
        else if (sock.userData == [NSNumber numberWithInt:SocketOfflineByUser]) {
            // 如果由用户断开，不进行重连
            NSLog(@"user lost");
            return;
        }
    }
    
    if (sock == self.dataSocket) {
        //i = i + 1;
        self.isDataSocketConnected = NO;
    }
    if (self.isDataSocketConnected == NO && self.isDataSocketConnected == NO) {
        [self.delegate didDisconnectSocket];
        NSLog(@"tcp sockets are disconnected");
        //i = 0;
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    //获取服务器返回信令ack
    
    if (tag == kwriteMessageTag)   {
        NSLog(@"did write data");
        [self.delegate didSendMessageWithCMD:self.didSendCMD];
        self.isKeepAliveMessage = NO;
    }
    
    if (tag == kwriteKeepAliveMessageTag)   {
        NSLog(@"did send keep alive Message");
        [self receiveMessageWithTimeOut:-1];
        self.isKeepAliveMessage = YES;
    }
    //写入数据流后操作
    
    if (sock == self.dataSocket) {
        if (tag == kwriteMessageTag) {
            NSLog(@"上传固件更新包完毕...");
            [self.delegate didSendData];
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    /****************************************对返回的ack进行解析与转换*******************************************/
    
    if (sock == self.lingSocket) {
        
        CTL_MESSAGE_PACKET receiveACK;
        
        [data getBytes:&receiveACK length:sizeof(receiveACK)];
        NSLog(@"返回的ACK包: %d-%d-%d-%d-%d",receiveACK.cmd,receiveACK.param0,receiveACK.param1,receiveACK.state,receiveACK.paramn[0]);
        
//        if (tag == kreadKeepAliveMessageTag && receiveACK.state == SDB_STATE_SUCCESS && self.isKeepAliveMessage == YES) {
//            NSLog(@"did receive keep alive message");
//            self.isKeepAliveMessage = NO;
//        }
        
        if (tag == kreadMessageTag && receiveACK.state == SDB_STATE_SUCCESS) {
            
            switch (receiveACK.cmd) {
                case SDB_GET_BLOCK_NORMAL_PHOTOS_ACK:
                    
                    _dataArray = receiveACK;
                    [self downloadAllFilesStreamWithLength:[self getLengthOfAllFilesWithACK:receiveACK]];
                    break;
                    
                case SDB_GET_DEBUG_INFO_ACK:
                    [self extractDebugInfoWithData:(CTL_MESSAGE_PACKET)receiveACK];
                    break;
                    
                case SDB_GET_DEVICEINFO_ACK:
                    [self extractDevInfoWithData:receiveACK];
                    break;
                    
                case SDB_GET_FLASH_PHOTO_ACK:
                    [self downloadSingleFileStreamWithLength:receiveACK.paramn[0]];
                    break;
                    
                case SDB_GET_LENS_PARAMS_ACK:
                    [self extractLensStatuWithData:receiveACK];
                    break;
                    
                case SDB_GET_NORMAL_PHOTO_COUNT_ACK:
                    self.fileList = receiveACK;
                    break;
                    
                case SDB_SET_BWDISPLAY_PARAM_ACK:
                    
                    break;
                    
                case SDB_SET_DEV_CTL_CHANNEL_ACK:
                    
                    break;
                    
                case SDB_SET_DEV_DATA_CHANNEL_ACK:
                    NSLog(@"已经打开数据传输通道");
                    [self tcpDataSocketConnectToHost];
                    break;
                    
                case SDB_SET_DEV_WORK_MODE_ACK:
                    
                    break;
                    
                case SDB_SET_EXPOSURE_MODE_ACK:
                    
                    break;
                    
                case SDB_SET_EXPOSURE_PARAM_ACK:
                    
                    break;
                    
                case SDB_SET_IRIS_PARAM_ACK:
                    
                    break;
                    
                case SDB_SET_LENS_FOCUS_PARAM_ACK:
                    
                    break;

                case SDB_SET_SHUTTER_PARAM_ACK:
                    
                    break;
                    
                case SDB_SET_SNAPSHOT_ACK:
                    //[self receiveMessageWithTimeOut:-1];
                    break;
                    
                case SDB_SET_STANDBY_EN_ACK:
                    
                    break;
                    
                case SDB_SET_UPLOAD_ZYNQ_FRIMWARE_ACK:
                    [self uploadSingleFileStreamWithData:self.upLoadData];
                    break;
                
                case SDB_UPLOAD_GENFILE_ACK:
                    [self uploadSingleFileStreamWithData:self.upLoadData];
                    break;
                    
                case SDB_SET_POWER_OFF_TIME_ACK:
                    break;
                    
                case SDB_GET_LOG_FILE_ACK:
                    [self downloadSingleFileStreamWithLength:receiveACK.paramn[0]];
                    
                case SDB_GET_RECORD_DES_ACK:
                    
                    NSLog(@"get record descript length :%d", receiveACK.paramn[0]);
                    [self downloadDataStreamWithLength:receiveACK.paramn[0] withTag:kreadDidDownloadGetFrameDesTag];
                    _downloadedACK = receiveACK;
                    break;
                    
                case SDB_GET_FIRST_FRAME_ACK:
                    
                    
                    NSLog(@"get first frame length :%d", receiveACK.paramn[0]);
                    [self downloadDataStreamWithLength:receiveACK.paramn[0] withTag:kreadDidDownloadGetFirstFrameTag];
                    _downloadedACK = receiveACK;
                    break;
                    
                case SDB_GET_FRAME_ACK:
                    
                    NSLog(@"get frame length :%d", receiveACK.paramn[0]);
                    [self downloadDataStreamWithLength:receiveACK.paramn[0] withTag:kreadDidDownloadGetFrameTag];
                    _downloadedACK = receiveACK;
                    break;
                    
                case SDB_GET_LIVE_FRAME_ACK:
                    NSLog(@"get live frame with Length : %d", receiveACK.paramn[0]);
                    [self downloadDataStreamWithLength:receiveACK.paramn[0] withTag:kreadDidDownloadLiveFrameTag];
                    _downloadedACK = receiveACK;
                    break;
                    
                default:;
                    break;
            }
            
            //[self.delegate didReceiveACKWithState:receiveACK];
        }
        
        [self.delegate didReceiveACKWithState:receiveACK];
        
    }
    
    /**********************************************读取数据流***************************************************/
    if (sock == self.dataSocket) {
        
        if (tag == kreadDidDownloadSingleFileTag) {
            NSLog(@"已下载文件数据流,长度:%lu 并回调代理方法.",(unsigned long)[data length]);
            
            //获取单文件下载的数据流并回调代理方法
            [self.delegate didFinishSingleFileDownloadingWithImageData:data];
        }
        if (tag == kreadDidDownloadAllFileTag) {
            NSLog(@"获取多下载的数据流,并解析成多个单文件");
            
            //获取多下载的数据流,并解析成多个单文件, 回调代理方法
            [self extractStreamWithArray:_dataArray.paramn withDownloadedData:data];

//            if (self.fileList.paramn[0] < kBatchNumber) {
//                [self.delegate didFinishAllFilesDownloading];
//            }

        }
        if (tag == kreadDidDownloadGetFrameDesTag) {
            NSLog(@"已获视频描述信息数据，长度:%lu",(unsigned long)[data length]);
            [self.delegate didFinishDownloadRecordingData:data withCMD:_downloadedACK];
        }
        if (tag == kreadDidDownloadGetFirstFrameTag) {
            NSLog(@"已获取首帧画面,长度:%lu",(unsigned long)[data length]);
            [self.delegate didFinishDownloadRecordingData:data withCMD:_downloadedACK];
        }
        if (tag == kreadDidDownloadGetFrameTag) {
            NSLog(@"已获取帧／多帧 画面, 长度：%lu",(unsigned long)[data length]);
            [self.delegate didFinishDownloadRecordingData:data withCMD:_downloadedACK];
        }
        if (tag == kreadDidDownloadLiveFrameTag) {
             NSLog(@"已获取指定实时取景帧, 长度：%lu",(unsigned long)[data length]);
            [self.delegate didFinishDownloadRecordingData:data withCMD:_downloadedACK];
        }
    }
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    if (tag == kwriteKeepAliveMessageTag) {
        [self.delegate didLoseAlive];
        return 0;
    }
    else return -1;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length
{
    
    if (tag == kreadMessageTag && self.isKeepAliveMessage == YES) {
        NSLog(@"did losing Keep Alive Message");
        [self.delegate didLoseAlive];
        return 0;
    }
    else return -1;
}

@end

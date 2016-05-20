//
//  FirmwareManager.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 16/2/25.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#define kFirmwareVersion @"T2.10"

@interface FirmwareManager : NSObject 

typedef void (^FinishedBlock)(NSArray *descriptions);
typedef void (^DownloadProgressBlock)(NSProgress *downloadProgress);
typedef void (^CompleteDownloadBlock)(NSURL *filePath, NSError *error);

@property (strong, nonatomic) NSString *appVerison;
@property (strong, nonatomic) NSString *camVerison;
@property (strong, nonatomic) NSString *latestUpdate;
@property (strong, nonatomic) NSString *latestUpdateURL;
@property (strong, nonatomic) NSString *latestUpdateInfo;
@property (strong, nonatomic) NSURL    *firmwarePathURL;
@property (strong, nonatomic) NSString *firmwareFileName;
@property (strong, nonatomic) NSProgress *downloadingProgress;

- (instancetype)init;
+ (FirmwareManager *)sharedFirmwareManager;
- (void)getFirmwareJsonDescriptionSuccess:(FinishedBlock)success;
- (BOOL)checkingLatestUpdateWithArray:(NSArray *)array;
- (BOOL)checkingCameraShouldUpdateWithCamVer:(NSString *)camVer;
- (void)downloadLatestFirmwareWithURL:(NSString *)link progress:(DownloadProgressBlock)progress completeHandler:(CompleteDownloadBlock)block;
- (void)submitToNewestFirmware;
- (void)deleteFirmwareFile;
- (void)saveFirmware;
- (void)cleanURLCache;
@end

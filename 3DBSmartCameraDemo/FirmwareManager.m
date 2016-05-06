//
//  FirmwareManager.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 16/2/25.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "FirmwareManager.h"

const NSString * kFirmware = @"firmware";
const NSString * kVersion = @"version";
const NSString * kAppSupportVer = @"appversion";
const NSString * kFirmwareURL = @"url";
const NSString * kUpdateCNinfo = @"info_zh";
const NSString * kUpdateENinfo = @"info_en";

#define kDescriptionHTTPString  @"http://www.eyemore.cn/firmware/testfirmware/desc/version_desc"

@implementation FirmwareManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.appVerison = [NSString stringWithFormat:@"1.00"];
        self.camVerison = [NSString stringWithFormat:@"T1.85"];
        [self loadFirmware];
    }
    return self;
}

+ (FirmwareManager *)sharedFirmwareManager
{
    static FirmwareManager *instance = nil;
    if (instance == nil) {
        instance = [[FirmwareManager alloc] init];
    }
    return instance;
}

- (void)getFirmwareJsonDescriptionSuccess:(FinishedBlock)success
{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [manager GET:[NSString stringWithFormat:@"%@",kDescriptionHTTPString]
      parameters:nil
        progress:^(NSProgress *downloadProgress){}
         success:^(NSURLSessionDataTask *task, id responseObject) {
        
             NSDictionary *dict = (NSDictionary *)responseObject;
             
             NSArray *array = [dict objectForKey:kFirmware];
             NSLog(@"Firmware Description: %@", array);
             success(array);
            
         }
     
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"Fetch firmware description error: %@", error);
        }];
}

- (BOOL)checkingLatestUpdateWithArray:(NSArray *)array
{
    for (int i = (int)(array.count - 1); i >= 0; i --) {
        
        NSDictionary *dict     = [array objectAtIndex:i];
        NSArray *supportedApps = [dict objectForKey:kAppSupportVer];
        float maxSupported     = [[supportedApps lastObject] floatValue];
        float minSupported     = [[supportedApps firstObject] floatValue];
        
        if (minSupported <= [self.appVerison floatValue] && [self.appVerison floatValue] <= maxSupported) {
            
            self.latestUpdate     = [dict objectForKey:kVersion];
            self.latestUpdateURL  = [dict objectForKey:kFirmwareURL];
            self.latestUpdateInfo = [dict objectForKey:kUpdateCNinfo];
            
            NSLog(@"latest update version: %@, url: %@, info: %@", self.latestUpdate, self.latestUpdateURL, self.latestUpdateInfo);
            
            return YES;
        }
    }
    return NO;
}

- (BOOL)checkingCameraShouldUpdateWithCamVer:(NSString *)camVer
{
    float camValue = [[camVer substringFromIndex:1] floatValue];
    float updateValue = [[self.latestUpdate substringFromIndex:1] floatValue];
    
    if (camValue < updateValue) return YES;
    else return NO;

}

- (void)downloadLatestFirmwareWithURL:(NSString *)link progress:(DownloadProgressBlock)progress completeHandler:(CompleteDownloadBlock)block
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    NSURL *url = [NSURL URLWithString:link];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request
                                                                     progress:^(NSProgress *downloadProgress){
                                                                         if (downloadProgress) {
                                                                             progress(downloadProgress);
                                                                         }
                                                                         //NSLog(@"firmware downloading Progress is %f", downloadProgress.fractionCompleted);
                                                                     }
                                                                  destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                                                      NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                                                                                            inDomain:NSUserDomainMask
                                                                                                                                   appropriateForURL:nil
                                                                                                                                              create:NO
                                                                                                                                               error:nil];
                                                                      self.firmwareFileName = [response suggestedFilename];
                                                                      return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                                                                  }
                                                            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@,", filePath);
        if (error) {
            NSLog(@"download error: %@", error);
            block(nil, error);
        }
        else {
            self.firmwarePathURL = [[NSURL alloc] init];
            self.firmwarePathURL = filePath;
            [self saveFirmware];
            block(self.firmwarePathURL, nil);
        }
    }];
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
    }];
    [downloadTask resume];
}

- (void)submitToNewestFirmware
{
    self.camVerison = self.latestUpdate;
}

- (void)saveFirmware
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.latestUpdate     forKey:@"latestUpdate"];
    [defaults setObject:self.latestUpdateInfo forKey:@"latestUpdateInfo"];
    [defaults setObject:self.latestUpdateURL  forKey:@"latestUpdateURL"];
    [defaults setURL:   self.firmwarePathURL  forKey:@"firmwarePathURL"];
    [defaults setObject:self.firmwareFileName forKey:@"firmwareFileName"];
    [defaults setObject:self.camVerison       forKey:@"camVerison"];
}

- (void)loadFirmware
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"latestUpdate"]) {
        self.latestUpdate = [defaults objectForKey:@"latestUpdate"];
    }
    if ([defaults objectForKey:@"latestUpdateInfo"]) {
        self.latestUpdateInfo = [defaults objectForKey:@"latestUpdateInfo"];
    }
    if ([defaults objectForKey:@"latestUpdateURL"]) {
        self.latestUpdateURL  = [defaults objectForKey:@"latestUpdateURL"];
    }
    if ([defaults URLForKey:@"firmwarePathURL"]) {
        self.firmwarePathURL  = [defaults URLForKey:@"firmwarePathURL"];
    }
    if ([defaults objectForKey:@"firmwareFileName"]) {
        self.firmwareFileName = [defaults objectForKey:@"firmwareFileName"];
    }
    if ([defaults objectForKey:@"camVerison"]) {
        self.camVerison = [defaults objectForKey:@"camVerison"];
    }
}

- (void)deleteFirmwareFile
{
    NSString *path = [self.firmwarePathURL absoluteString];
    
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:path];
    if (!blHave) {
        NSLog(@"video file doesn't exist,no need to remove");
        return ;
    }
    else
    {
        NSLog(@"video file already exist,now removing");
        BOOL blDele= [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        if (blDele) {
            NSLog(@"delete firmware successed");
            //[self.videoList removeObject:dict];
            //[SaveLoadInfoManager saveAppInfoWithVideoClient:[VideoClient sharedVideoClient]];
        }else {
             NSLog(@"delete firmware failed");
        }
    }

}

- (void)cleanURLCache
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end

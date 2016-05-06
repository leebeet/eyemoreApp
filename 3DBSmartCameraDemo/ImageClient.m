//
//  ImageClient.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/3/24.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "ImageClient.h"
#import <UIKit/UIKit.h>
#import "JLResourcePath.h"
#import "JLResourcePath.h"
#import <CoreGraphics/CoreGraphics.h>
#import "BLFileManager.h"
#import "BLImageRotation.h"
#import "UIImage+Rotating.h"
#import "CMDataStorage.h"
#import "SaveLoadInfoManager.h"

//#define kHOST      @"ftp://192.169.1.156"
#define kMaxNumber 100
#define kBatchNum  50

@interface ImageClient ()

@property (assign, nonatomic) NSInteger   didLaunchFlag;
@end

@implementation ImageClient

+ (ImageClient *)sharedImageClient
{
    static ImageClient *instance = nil;
    if (instance == nil) {
        instance = [[ImageClient alloc] init];
    }
    return instance;
}

- (id)init
{
    self= [super init];
    if (self) {

        self.imgPath       = [[NSMutableArray alloc] init];
//        self.syncImgPath   = [[NSMutableArray alloc] init];
//        self.selfieImgPath = [[NSMutableArray alloc] init];
        self.imgPathFlag = 0;
        self.didLaunchFlag = 0;
        
        self.imgManager    = [SDWebImageManager sharedManager];
        self.imgCache      = [SDImageCache sharedImageCache];
        //self.dataCache     = [CMDataStorage sharedCacheStorage];
        self.dataCache      = [CMDataStorage sharedDocumentsStorage];
        self.downloadedImage = [[UIImage alloc] init];
        self.cacheData     = [[NSMutableArray alloc] init];
        self.writeQueue    = dispatch_queue_create("writeImage", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Download Manage Methods

- (void)resetCompleteFlat
{
    self.completeFlat = 0;
}

#pragma mark - Cache Manage Methods

- (UIImage *)getImageFromPath
{
    static NSUInteger flat = 0;
    //UIImage *image    = [self.imgCache imageFromDiskCacheForKey:self.imgPath[flat]];
    UIImage *image    = [self getImageForKey:self.imgPath[flat]];
    //UIImage *image = [UIImage imageWithContentsOfFile:self.imgPath[flat]];
    NSLog(@"image: %lu%@",(unsigned long)flat,image);
    flat++;
    if (flat == kMaxNumber) {
        flat = 0;
    }
    return image;
}

- (void)checkingImageIfExist
{
    for (int i = 0; i < 5;  i++) {
        BOOL b  = [self.imgCache diskImageExistsWithKey:self.imgPath[i]];
        NSLog(@"NO.%d image if existed %s",i, b?"YES":"NO");
    }
}

- (void)clearAllImages
{
    [self.imgCache clearMemory];
    [self.imgCache cleanDisk];
    [self.imgCache clearDisk];
}

- (NSUInteger )calculateCacheInMB
{
//    NSUInteger imgSize = 0;
//    imgSize = [self.imgCache getSize];
//    imgSize = imgSize / 1024 / 1024;
//    return imgSize;
    BLFileManager *fileManager = [[BLFileManager alloc] init];
    NSUInteger     imgsize = [fileManager getFileSizeWithRootPath:GetCachePathWithFile(nil)] / 1024 /1024;
    return          imgsize;
}

- (NSUInteger )calculateAvgSizeInKB
{
    NSUInteger avgSize = 0;
    BLFileManager *fileManager = [[BLFileManager alloc] init];
    NSUInteger imgsize = [fileManager getFileSizeWithRootPath:GetCachePathWithFile(nil)];
    avgSize = imgsize / self.imgPath.count / 1024;
    return avgSize;
}

- (void)storeSingleImageWithData:(NSData *)imageData
{
    NSString *path = [[NSString alloc] init];
    
    if (self.didLaunchFlag == 0) {
        self.imgPathFlag = [SaveLoadInfoManager imagePathIndex] + 1;
        NSLog(@"self.img flag :%lu", (unsigned long)self.imgPathFlag);
        //self.imgPathFlag = 0;
        self.didLaunchFlag = 1;
    }
    
    if (self.cameraMode == SYNCMODE) {
        path = [NSString stringWithFormat:@"image%lu.jpg", (unsigned long)self.imgPathFlag];
        [self.imgPath addObject:path];
    }
    self.imgPathFlag++;
    
    [self.dataCache writeData:imageData key:path];
    [SaveLoadInfoManager saveAppInfoWithClient:self];
    NSLog(@"downloaded path : %@", GetCachePathWithFile([NSString stringWithFormat:@"/%d.jpg",1]));
}

- (UIImage *)getImageForKey:(NSString *)path
{
      return [UIImage imageWithData:[self.dataCache dataForKey:path]];
}

- (NSData *)getImageDataForKey:(NSString *)path
{
    return [self.dataCache dataForKey:path];
}

- (void)storeAllImagesWithData:(NSMutableArray *)imageArray WithCameraMode:(CameraMode)mode
{
    NSUInteger index = self.imgPathFlag;
    [self storeAllImagesWithData:imageArray WithCameraMode:mode StartAtIndex:index];
}

- (void)storeAllImagesWithData:(NSMutableArray *)imageArray WithCameraMode:(CameraMode)mode StartAtIndex:(NSUInteger)index
{
    if (self.didLaunchFlag == 0) {
        self.imgPathFlag = [SaveLoadInfoManager imagePathIndex] + 1;
        //self.imgPathFlag = 0;
        self.didLaunchFlag = 1;
    }
    
    for (int i = (int)index; i < index + imageArray.count; i++) {
        
        NSString *path = [NSString stringWithFormat:@"image%lu.jpg", (unsigned long)self.imgPathFlag];
        NSLog(@"writing path: %@",path);
        [self.imgPath addObject:path];
        [self.dataCache writeData:imageArray[i - index] key:path];
        self.imgPathFlag ++;
    }
}

- (void)removeImageDataWithPath:(NSString *)path WithCameraMode:(CameraMode)mode
{
    [self.dataCache removeDataForKey:path block:nil];
    
}

- (NSString * )extractImageIndexWithData:(NSData *)data
{
    NSData *subData = [data subdataWithRange:NSMakeRange(104, 9)];
    NSString *string = [[NSString alloc] initWithData:subData encoding:NSUTF8StringEncoding];
    return string;
}
@end

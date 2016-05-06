//
//  ImageClient.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/3/24.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageManager.h"
#import "TCPSocketManager.h"
#import "CMDataStorage.h"

@protocol imageClientDelegate <NSObject>

@optional

- (void)didFinishStoreSingleImage;
- (void)didFinishStoreBatchImages;
- (void)didFinishStoreAllImages;

@end

typedef enum _CameraMode{

    SYNCMODE     = 1,
    DOWNLOADMODE = 2,
    SELFIEMODE   = 3,
    NORMALMODE   = 4

}CameraMode;

@interface ImageClient : NSObject <SDWebImageManagerDelegate, TCPSocketManagerDelegate>

@property (nonatomic, strong) NSMutableArray         *imageURLarray;
@property (nonatomic, strong) SDWebImageManager      *imgManager;
@property (nonatomic, strong) SDImageCache           *imgCache;
@property (nonatomic, strong) CMDataStorage          *dataCache;

@property (nonatomic, assign) NSInteger               completeFlat;
@property (assign, nonatomic) NSUInteger              imgPathFlag;
@property (nonatomic, strong) UIImage                *downloadedImage;


@property (nonatomic, assign) id<imageClientDelegate> delegate;
@property (nonatomic, strong) NSMutableArray         *cacheData;

@property (nonatomic, strong) dispatch_queue_t        writeQueue;
@property (nonatomic, assign) NSUInteger              queueDownloadFlat;
@property (nonatomic, strong) NSString               *currentPath;
@property (nonatomic, assign) NSUInteger              currentIndex;
@property (nonatomic, assign) NSUInteger              lastImageIndex;
@property (nonatomic, assign) NSUInteger              syncLeavingFlag;
@property (nonatomic, assign) NSUInteger              downloadLeavingFlag;

@property (nonatomic, strong) NSMutableArray         *imgPath;
@property (nonatomic, strong) NSMutableArray         *syncImgPath;
@property (nonatomic, strong) NSMutableArray         *selfieImgPath;

@property (nonatomic, assign) BOOL                    isShownJpgInfo;
@property (nonatomic, assign) CameraMode              cameraMode;

+ (ImageClient *)sharedImageClient;
//- (UIImage *)    getImageFromPath;
- (UIImage *)    getImageForKey:(NSString *)path;
- (NSData *)     getImageDataForKey:(NSString *)path;
- (NSUInteger)   calculateCacheInMB;
- (NSUInteger )  calculateAvgSizeInKB;

- (void)storeSingleImageWithData:(NSData *)imageData;
- (void)storeAllImagesWithData:(NSMutableArray *)imageArray WithCameraMode:(CameraMode)mode;
- (void)storeAllImagesWithData:(NSMutableArray *)imageArray WithCameraMode:(CameraMode)mode StartAtIndex:(NSUInteger)index;
- (void)removeImageDataWithPath:(NSString *)path WithCameraMode:(CameraMode)mode;

- (NSString * )extractImageIndexWithData:(NSData *)data;

- (void)resetCompleteFlat;
- (void)checkingImageIfExist;
- (void)clearAllImages;

@end

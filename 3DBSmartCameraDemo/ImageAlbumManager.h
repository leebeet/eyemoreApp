//
//  ImageAlbumManager.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/3/26.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageAlbumManager : NSObject


+ (ImageAlbumManager *)sharedImageAlbumManager;
- (void)createCustomAlbumWithName:(NSString *)AlbumName;
- (void)saveToAlbumWithMetadata:(NSDictionary *)metadata
                      imageData:(NSData *)imageData
                customAlbumName:(NSString *)customAlbumName
                completionBlock:(void (^)(void))completionBlock
                   failureBlock:(void (^)(NSError *error))failureBlock;

@end

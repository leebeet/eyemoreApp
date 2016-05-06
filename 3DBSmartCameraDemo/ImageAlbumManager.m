//
//  ImageAlbumManager.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/3/26.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "ImageAlbumManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ImageAlbumManager ()
{
    NSData *_imageData;
}
@end

@implementation ImageAlbumManager

+ (ImageAlbumManager *)sharedImageAlbumManager
{
    static ImageAlbumManager *instance = nil;
    if (instance == nil) {
        instance = [[ImageAlbumManager alloc] init];
    }
    return instance;
}

- (void)createCustomAlbumWithName:(NSString *)AlbumName
{
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group , BOOL *stop) {
    
        if (group) {
           
            [groups addObject:group];
        }
        else{
        
            BOOL haveCustomAlbum = NO;
            for (ALAssetsGroup *gp in groups) {
                NSString *name = [gp valueForProperty:ALAssetsGroupPropertyName];
                if ([name isEqualToString:AlbumName]) {
                    haveCustomAlbum = YES;
                }
            }
            if (!haveCustomAlbum) {
                [assetsLibrary addAssetsGroupAlbumWithName:AlbumName resultBlock:^(ALAssetsGroup *group){
                    [groups addObject:groups];
                } failureBlock:nil];
                //haveCustomAlbum = YES;
            }
        }
    };
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:listGroupBlock failureBlock:nil];
}

- (void)saveToAlbumWithMetadata:(NSDictionary *)metadata
                      imageData:(NSData *)imageData
                customAlbumName:(NSString *)customAlbumName
                completionBlock:(void (^)(void))completionBlock
                   failureBlock:(void (^)(NSError *error))failureBlock
{
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    __weak typeof(ALAssetsLibrary ) * weakAssetsLibrary = assetsLibrary;
    void (^AddAsset)(ALAssetsLibrary *, NSURL *) = ^(ALAssetsLibrary *assetsLibrary, NSURL *assetURL) {
        [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                
                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:customAlbumName]) {
                    [group addAsset:asset];
                    if (completionBlock) {
                        completionBlock();
                    }
                }
            } failureBlock:^(NSError *error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        } failureBlock:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
            }
        }];
    };
    [assetsLibrary writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
        if (customAlbumName) {
            [assetsLibrary addAssetsGroupAlbumWithName:customAlbumName resultBlock:^(ALAssetsGroup *group) {
                if (group) {
                    [weakAssetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        [group addAsset:asset];
                        if (completionBlock) {
                            completionBlock();
                        }
                    } failureBlock:^(NSError *error) {
                        if (failureBlock) {
                            failureBlock(error);
                        }
                    }];
                } else {
                    AddAsset(weakAssetsLibrary, assetURL);
                }
            } failureBlock:^(NSError *error) {
                AddAsset(weakAssetsLibrary, assetURL);
            }];
        } else {
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}



@end

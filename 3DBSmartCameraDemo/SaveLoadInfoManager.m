//
//  SaveLoadInfoManager.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/6/17.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "SaveLoadInfoManager.h"

@implementation SaveLoadInfoManager

+ (SaveLoadInfoManager *)sharedSaveLoadInfoManager
{
    static SaveLoadInfoManager *instance = nil;
    if (instance == nil) {
        instance = [[SaveLoadInfoManager alloc] init];
    }
    return instance;
}

+ (void)saveAppInfoWithClient:(ImageClient *)client
{
    NSArray *sycnArray     = [[NSArray alloc] initWithArray:[client.imgPath copy]];
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    [userData setObject:sycnArray forKey:@"ImagePaths"];
    NSLog(@"save userData : %@", userData);
}

+ (ImageClient *)loadInfoWithClient
{
//    NSBundle *bundle = [NSBundle mainBundle];
//    NSString *path = [bundle pathForResource:@"SavingInfoList" ofType:@"plist"];
//    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:path];
//    
//    client.syncImgPath = [data[@"syncImagePaths"] mutableCopy];
//    client.imgPath     = [data[@"downloadImagePaths"] mutableCopy];

    ImageClient *client = [[ImageClient alloc] init];
    
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSMutableArray *imgPath = [[userData objectForKey:@"ImagePaths"] mutableCopy];
    if (imgPath != nil) {
            client.imgPath = imgPath;
    }
    else client.imgPath = [[NSMutableArray alloc] init];
    //client.imgPath     = [[userData objectForKey:@"downloadImagePaths"] mutableCopy];
    
    NSLog(@"client.imgPath.count : %lu, client.imgPath : %@,", (unsigned long)client.imgPath.count, client.imgPath);
    return client;
}

+ (int)imagePathIndex
{
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSMutableArray *imgPath = [[NSMutableArray alloc] init];
    imgPath = [[userData objectForKey:@"ImagePaths"] mutableCopy];
    //client.imgPath     = [userData objectForKey:@"downloadImagePaths"];
    NSLog(@"download array : %@",imgPath);
    
    if (imgPath == nil) {
        return 0;
    }
    else {
    NSString *key = [imgPath lastObject];
    int a = [[key substringFromIndex:(5)] intValue];
    
    return a;
    }
}

+ (void)saveAppInfoWithVideoClient:(VideoClient *)client
{
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSMutableArray *videoList = [[NSMutableArray alloc] initWithArray:client.videoList];
    [userData setObject:videoList forKey:@"VideoList"];
}
+ (VideoClient *)loadAppInfoWithVideoClient
{
    VideoClient *client = [[VideoClient  alloc] init];
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSMutableArray *videoList = [[userData objectForKey:@"VideoList"] mutableCopy];
    if (videoList != nil) {
        client.videoList = videoList;
    }
    else client.videoList = [[NSMutableArray alloc] init];
    return client;
}
@end

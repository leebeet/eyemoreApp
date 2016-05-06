//
//  eyemoreVideos.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/5.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EyemoreVideo : NSObject <NSCoding>

@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, assign) NSInteger fileSize;
@property (nonatomic, assign) NSInteger frameCount;
@property (nonatomic, assign) NSInteger channel;
@property (nonatomic, assign) CGSize    resolution;
@property (nonatomic, assign) CGFloat   FPS;
@property (nonatomic, assign) CGFloat   FS;
@property (nonatomic, assign) CGFloat   audioWidth;
@property (nonatomic, strong) NSMutableDictionary  *videoMaterial;
@property (nonatomic, strong) NSString *videoType;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *createdDate;
@property (nonatomic, assign) NSInteger timeScale;

- (instancetype)initWithProfileDict:(NSArray *)VideoInfo;

@end

//
//  BLFileManager.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/4/7.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLFileManager : NSObject
- (NSUInteger)getFileSizeWithRootPath:(NSString *)path;
+ (void)writeFile:(NSData *)data forKeyPath:(NSString *)key;
@end

//
//  JLResourcePath.m
//  FileManagerDemo
//
//  Created by whunf on 14-7-6.
//  Copyright (c) 2014年 Jan Lion. All rights reserved.
//

#import "JLResourcePath.h"
#import <Foundation/Foundation.h>

NSString *GetDocumentPathWithFile(NSString *file)
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    if (file) {
        return [path stringByAppendingPathComponent:file];
    }
    
    return path;
}

NSString *GetCachePathWithFile(NSString *file)
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    if (file) {
        return [path stringByAppendingPathComponent:file];
    }
    
    return path;
}

NSString *GetTempPathWithFile(NSString *file)
{
    NSString *path = NSTemporaryDirectory();
    
    if (file) {
        return [path stringByAppendingPathComponent:file];
    }
    
    return path;
}

void deleteFileWithPath(NSString *path)
{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSLog(@"文件是否存在: %@",[fileManger isExecutableFileAtPath:path]?@"YES":@"NO");
    NSError *error = nil;
    BOOL isRemove = [fileManger removeItemAtPath:path error:&error];
    NSLog(@"remove failed:%@", [error localizedDescription]);
    if (isRemove) {
        NSLog(@"delete success");
    }
    else NSLog(@"delete fail");
}
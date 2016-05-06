//
//  BLFileManager.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/4/7.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "BLFileManager.h"
#import <sys/stat.h>

@implementation BLFileManager

- (NSUInteger)getFileSizeWithRootPath:(NSString *)path
{
    __block NSUInteger size = 0;
    //dispatch_sync(self.ioQueue, ^{
    NSFileManager *fileManger = [NSFileManager defaultManager];
        NSDirectoryEnumerator *fileEnumerator = [fileManger enumeratorAtPath:path];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [fileManger attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
   // });
    return size;
}

- (long long) fileSizeAtPath:(NSString*) filePath{
    struct stat st;
    if(lstat([filePath cStringUsingEncoding:NSUTF8StringEncoding], &st) == 0){
        return st.st_size;
    }
    return 0;
}

+ (void)writeFile:(NSData *)data forKeyPath:(NSString *)key
{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    [fileManger createFileAtPath:key contents:data attributes:nil];
    
}
//void deleteFileWithPath(NSString *path)
//{
//    NSFileManager *fileManger = [NSFileManager defaultManager];
//    NSLog(@"文件是否存在: %@",[fileManger isExecutableFileAtPath:path]?@"YES":@"NO");
//    NSError *error = nil;
//    BOOL isRemove = [fileManger removeItemAtPath:path error:&error];
//    NSLog(@"remove failed:%@", [error localizedDescription]);
//    if (isRemove) {
//        NSLog(@"delete success");
//    }
//    else NSLog(@"delete fail");
//}
@end

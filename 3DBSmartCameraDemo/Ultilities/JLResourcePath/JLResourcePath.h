//
//  JLResourcePath.h
//  FileManagerDemo
//
//  Created by whunf on 14-7-6.
//  Copyright (c) 2014年 Jan Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *GetDocumentPathWithFile(NSString *file);
NSString *GetCachePathWithFile(NSString *file);
NSString *GetTempPathWithFile(NSString *file);

void deleteFileWithPath(NSString *path);


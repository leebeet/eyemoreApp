//
//  BL32BitCheckSumValidator.m
//  BL32BitCheckSumValidator
//
//  Created by 李伯通 on 15/9/23.
//  Copyright © 2015年 Beet. All rights reserved.
//

#import "BL32BitCheckSumValidator.h"

#define kAccurateBytes 4

@implementation BL32BitCheckSumValidator

+ (unsigned  int )calculateCheckSumWithData:(NSData *)data
{
    
    NSUInteger dataLength = [data length];
    NSUInteger fileCount  = dataLength / kAccurateBytes;
    NSUInteger remainder  = dataLength % kAccurateBytes;
    
    if (remainder != 0) {
        fileCount = fileCount + 1;
    }
    
    NSLog(@"file count : %lu， reminder :%lu", (unsigned long)fileCount, (unsigned long)remainder);
    
    int t = 0;
    unsigned  int checkSum = 0;
    NSData *unitData;
    
    for (int i = 0; i < fileCount; i++) {
        
        if (i == 0)
        {
            unitData = [data subdataWithRange:NSMakeRange(0, kAccurateBytes)];
            
        }
        
        else if (i != 0 && i != (fileCount - 1))
        {
            unitData = [data subdataWithRange:NSMakeRange(t, kAccurateBytes)];
        }
        
        else if ( i == fileCount - 1)
        {
            if (remainder != 0) {
                  unitData = [data subdataWithRange:NSMakeRange(t, remainder)];
            }
            else  unitData = [data subdataWithRange:NSMakeRange(t, kAccurateBytes)];
        }
        
        unsigned  int temp;
        [unitData getBytes:&temp length:sizeof(temp)];
        
        checkSum = checkSum + temp;
        
        t = t + kAccurateBytes;
    }
    return checkSum;
}
@end

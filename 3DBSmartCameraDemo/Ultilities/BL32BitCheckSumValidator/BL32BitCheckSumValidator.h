//
//  BL32BitCheckSumValidator.h
//  BL32BitCheckSumValidator
//
//  Created by 李伯通 on 15/9/23.
//  Copyright © 2015年 Beet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BL32BitCheckSumValidator : NSObject

+ ( unsigned int )calculateCheckSumWithData:(NSData *)data;

@end

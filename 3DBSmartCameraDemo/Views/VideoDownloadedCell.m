//
//  VideoDownloadedCell.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/7.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "VideoDownloadedCell.h"

@implementation VideoDownloadedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)instantiateFromNib
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    VideoDownloadedCell *view = [views firstObject];
    return view;
}

@end

//
//  VdieoUndownloadCell.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/11.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "VideoUndownloadCell.h"

@implementation VideoUndownloadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)instantiateFromNib
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    VideoUndownloadCell *view = [views firstObject];
    return view;
}
@end

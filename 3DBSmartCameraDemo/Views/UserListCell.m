//
//  UserListCell.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/22.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "UserListCell.h"

@implementation UserListCell

+ (instancetype)instantiateFromNib
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    UserListCell *cell = [views firstObject];
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

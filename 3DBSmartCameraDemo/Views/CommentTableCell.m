//
//  CommentTableCell.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/5.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "CommentTableCell.h"

@implementation CommentTableCell

+ (instancetype)instantiateFromNib
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    CommentTableCell *cell = [views firstObject];
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentTableCellTapped)];
    [self addGestureRecognizer:tap];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)commentTableCellTapped
{
    [self.delegate didSelectCommentTableCell:self];
}

@end

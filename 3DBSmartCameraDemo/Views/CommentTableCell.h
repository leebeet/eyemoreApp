//
//  CommentTableCell.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/5.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommentTableCell;

@protocol CommentTableCellDelegare <NSObject>

- (void)didSelectCommentTableCell:(CommentTableCell *)cell;

@end


@interface CommentTableCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *CommentLabel;
@property (weak, nonatomic) id <CommentTableCellDelegare> delegate;

@property (assign, nonatomic) NSInteger commentUserID;

+ (instancetype)instantiateFromNib;

@end

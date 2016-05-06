//
//  CommentTableCell.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/5.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *CommentLabel;

+ (instancetype)instantiateFromNib;

@end

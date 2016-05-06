//
//  UserListCell.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/22.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
+ (instancetype)instantiateFromNib;
@end

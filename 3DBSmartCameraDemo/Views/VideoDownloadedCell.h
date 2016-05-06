//
//  VideoDownloadedCell.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/7.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoDownloadedCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *lengthLabel;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *HDLabel;
@end

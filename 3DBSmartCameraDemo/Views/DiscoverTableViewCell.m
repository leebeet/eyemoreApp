//
//  DiscoverTableViewCell.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/24.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "DiscoverTableViewCell.h"

@interface DiscoverTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *userAvatarView;

@end

@implementation DiscoverTableViewCell

+ (instancetype)instantiateFromNib
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    DiscoverTableViewCell *cell = [views firstObject];
    [cell.likeButton addTarget:self action:@selector(likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [cell.commentButton addTarget:self action:@selector(commentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.likeButton addTarget:self action:@selector(likeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.commentButton addTarget:self action:@selector(commentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarAction)];
    self.userAvatar.userInteractionEnabled = YES;
    [self.userAvatar addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postImageAction)];
    self.postImage.userInteractionEnabled = YES;
    [self.postImage addGestureRecognizer:tap1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)likeButtonTapped
{
    [self.delegate didTappedLikeButtonOnCell:self];
}

- (void)commentButtonTapped
{
    [self.delegate didTappedCommentButtonOnCell:self];
}

- (void)avatarAction
{
    [self.delegate didActionAvatarViewOnCell:self];
}

- (void)postImageAction
{
    [self.delegate didActionPostImageOnCell:self];
}
//- (void)setUpUserAvatar
//{
//    self.userAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
//    self.userAvatar.contentMode = UIViewContentModeScaleAspectFit;
//    self.userAvatar.layer.masksToBounds = YES;
//    self.userAvatar.layer.cornerRadius = self.userAvatar.frame.size.width / 2;
//    [self.contentView addSubview:self.userAvatar];
//}
@end

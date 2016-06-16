//
//  DiscoverTableViewCell.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/24.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DiscoverTableViewCell;

@protocol DiscoverTableViewCellDelegate <NSObject>

@optional
- (void)didTappedLikeButtonOnCell:   (DiscoverTableViewCell *)cell;
- (void)didTappedCommentButtonOnCell:(DiscoverTableViewCell *)cell;
- (void)didTappedMoreButtonOnCell:   (DiscoverTableViewCell *)cell;
- (void)didActionAvatarViewOnCell:   (DiscoverTableViewCell *)cell;
- (void)didActionPostImageOnCell:    (DiscoverTableViewCell *)cell;

@end

@interface DiscoverTableViewCell : UITableViewCell

@property (weak, nonatomic) id<DiscoverTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel     *userName;
@property (weak, nonatomic) IBOutlet UIButton    *moreButton;
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UIButton    *likeButton;
@property (weak, nonatomic) IBOutlet UIButton    *commentButton;
@property (weak, nonatomic) IBOutlet UILabel     *likeLabel;
@property (weak, nonatomic) IBOutlet UILabel     *commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel     *imageTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel     *postedDateLabel;
@property (assign, nonatomic)        NSInteger    blogID;
@property (assign, nonatomic)        NSInteger    userID;
@property (strong, nonatomic)        NSString    *imageURLString;

+ (instancetype)instantiateFromNib;

@end

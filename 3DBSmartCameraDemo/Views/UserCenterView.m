//
//  UserCenterView.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/18.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "UserCenterView.h"

@implementation UserCenterView

+ (instancetype)instantiateFromNib
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    UserCenterView *view = [views firstObject];
    view.userAvartaView.layer.cornerRadius = view.userAvartaView.frame.size.width / 2;
    view.userAvartaView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.userAvartaView.layer.borderWidth = 1.5;
    
    view.userAvarta.layer.masksToBounds = YES;
    view.userAvarta.layer.cornerRadius = view.userAvartaView.frame.size.width / 2;
    view.userAvarta.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.userAvarta.layer.borderWidth = 1.5;
    
    view.followButton.layer.masksToBounds = YES;
    view.followButton.layer.cornerRadius = 2.5;
    view.followButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    view.followButton.layer.borderWidth = 1;

    return view;
}

+ (instancetype)instantiateFromNibWithName:(NSString *)string Image:(UIImage *)image LeftString:(NSString *)leftString RightString:(NSString *)RightString
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    
    UserCenterView *view = [views firstObject];
    [view.userNameLabel setText:string];
    [view.followersLabel setText:leftString];
    [view.likesLabel setText:RightString];
    view.userAvartaView.layer.cornerRadius = view.userAvartaView.frame.size.width / 2;
    view.userAvartaView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.userAvartaView.layer.borderWidth = 1.5;
    
    view.userAvarta.layer.masksToBounds = YES;
    view.userAvarta.layer.cornerRadius = view.userAvartaView.frame.size.width / 2;
    view.userAvarta.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.userAvarta.layer.borderWidth = 1.5;
    [view.userAvarta setImage:image];
    
    view.followButton.layer.masksToBounds = YES;
    view.followButton.layer.cornerRadius = 5;
    view.followButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.followButton.layer.borderWidth = 1;
    
    return view;
}

+ (instancetype)instantiateFromNibWithDefault
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil];
    
    UserCenterView *view = [views firstObject];
    [view.userNameLabel setText:@" 点击登录"];
    [view.followersLabel setHidden:YES];
    [view.likesLabel setHidden:YES];
    [view.seperator setHidden:YES];
    view.userAvartaView.layer.cornerRadius = view.userAvartaView.frame.size.width / 2;
    view.userAvartaView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.userAvartaView.layer.borderWidth = 1.5;
    
    view.userAvarta.layer.masksToBounds = YES;
    view.userAvarta.layer.cornerRadius = view.userAvartaView.frame.size.width / 2;
    view.userAvarta.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.userAvarta.layer.borderWidth = 1.5;
    
    view.followButton.layer.masksToBounds = YES;
    view.followButton.layer.cornerRadius = 5;
    view.followButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.followButton.layer.borderWidth = 1;
    
    return view;
}

- (void)changeStateToLoginWithName:(NSString *)string Image:(UIImage *)image LeftString:(NSString *)leftString RightString:(NSString *)RightString
{
    [self.followersLabel setHidden:NO];
    [self.likesLabel setHidden:NO];
    [self.seperator setHidden:NO];
    [self.userNameLabel setHidden:YES];
    [self.userNameLabel setText:string];
    [self.followersLabel setText:leftString];
    [self.likesLabel setText:RightString];
    [self.followButton setHidden:YES];
    [self.userAvarta setImage:image];

}
- (void)changeStateToUserCenterWithName:(NSString *)string Image:(UIImage *)image LeftString:(NSString *)leftString RightString:(NSString *)RightString
{
    [self.followersLabel setHidden:YES];
    [self.likesLabel setHidden:YES];
    [self.seperator setHidden:YES];
    [self.userNameLabel setHidden:YES];
    [self.userNameLabel setText:string];
    [self.followersLabel setHidden:YES];
    [self.likesLabel setHidden:YES];
    [self.followButton setHidden:NO];
    [self.userAvarta setImage:image];
    
}

- (void)changeStateToDefault
{
    [self.userNameLabel setText:@" 点击登录"];
    [self.userNameLabel setHidden:NO];
    [self.followersLabel setHidden:YES];
    [self.likesLabel setHidden:YES];
    [self.seperator setHidden:YES];
    [self.followersLabel setHidden:YES];
    [self.likesLabel setHidden:YES];
    [self.followButton setHidden:YES];
    
    [self.userAvarta setImage:[UIImage imageNamed:@"user_male"]];
    
}
@end

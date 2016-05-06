//
//  UserCenterView.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/18.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCenterView : UIView

@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIView *userAvartaView;
@property (weak, nonatomic) IBOutlet UIImageView *userAvarta;
@property (weak, nonatomic) IBOutlet UIView *seperator;
@property (weak, nonatomic) IBOutlet UIButton *followButton;


+ (instancetype)instantiateFromNib;
+ (instancetype)instantiateFromNibWithName:(NSString *)string
                                     Image:(UIImage *)image
                                LeftString:(NSString *)leftString
                               RightString:(NSString *)RightString;
+ (instancetype)instantiateFromNibWithDefault;

- (void)changeStateToLoginWithName:(NSString *)string
                             Image:(UIImage *)image
                        LeftString:(NSString *)leftString
                       RightString:(NSString *)RightString;

- (void)changeStateToUserCenterWithName:(NSString *)string
                                  Image:(UIImage *)image
                             LeftString:(NSString *)leftString
                            RightString:(NSString *)RightString;

- (void)changeStateToDefault;
@end

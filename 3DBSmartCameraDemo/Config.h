//
//  Config.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 16/2/24.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "eyemoreUser.h"
#import <UIKit/UIKit.h>

@interface Config : NSObject

+ (void)saveOwnAccount:(NSString *)account andPassword:(NSString *)password;
+ (void)saveProfile:  (eyemoreUser *)user;
+ (void)updateProfile:(eyemoreUser *)user;
+ (void)clearProfile: (eyemoreUser *)user;
+ (eyemoreUser *)myProfile;
+ (void)clearCookies;
+ (void)savePortrait:(UIImage *)protrait;

+ (NSArray *)getOwnAccountAndPassword;
+ (int64_t)getOwnID;
+ (NSString *)getOwnUserName;
+ (UIImage *)getPortrait;

+ (void)saveAccessToken:(NSString *)token;
+ (NSString *)myAccessToken;
@end

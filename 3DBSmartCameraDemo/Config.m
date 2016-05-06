//
//  Config.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 16/2/24.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "Config.h"
#import "SSKeychain.h"

NSString * const kService = @"3dbCamera";
NSString * const kAccount = @"account";
NSString * const kUserID = @"userID";
NSString * const kUserName = @"nickName";
NSString * const kPortrait = @"portrait";
NSString * const kPortraitURL = @"portraitURL";
NSString * const kGender = @"gender";
NSString * const kAccessToken = @"access_token";
NSString * const kFollowerList = @"followerList";
NSString * const kFansList = @"fansList";

@implementation Config

+ (void)saveOwnAccount:(NSString *)account andPassword:(NSString *)password
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:account ?: @"" forKey:kAccount];
    [userDefaults synchronize];
    
    [SSKeychain setPassword:password ?: @"" forService:kService account:kAccount];
}

#pragma mark - user profile

+ (void)saveProfile:(eyemoreUser *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setInteger:user.userID forKey:kUserID];
    [userDefaults setObject:user.nickName forKey:kUserName];
    [userDefaults setURL:user.avatorURL forKey:kPortraitURL];
    [userDefaults setObject:user.gender forKey:kGender];
    [userDefaults setObject:user.followerList forKey:kFollowerList];
    [userDefaults setObject:user.fansList forKey:kFansList];
    
    [userDefaults synchronize];
}

+ (void)saveAccessToken:(NSString *)token
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:token forKey:kAccessToken];
    [userDefaults synchronize];
}

+ (void)updateProfile:(eyemoreUser *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:user.nickName forKey:kUserName];
    [userDefaults setURL:user.avatorURL forKey:kPortraitURL];
    [userDefaults setObject:user.gender forKey:kGender];
    [userDefaults setObject:user.followerList forKey:kFollowerList];
    [userDefaults setObject:user.fansList forKey:kFansList];
    
    [userDefaults synchronize];
}

+ (void)clearProfile:(eyemoreUser *)user
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:@(0) forKey:kUserID];
    [userDefaults setObject:@"点击头像登录" forKey:kUserName];

    [userDefaults synchronize];
}

+ (eyemoreUser *)myProfile
{
    eyemoreUser *user = [eyemoreUser new];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    user.userID = [userDefaults integerForKey:kUserID];
    user.nickName = [userDefaults objectForKey:kUserName];
    user.gender = [userDefaults objectForKey:kGender];
    user.avatorURL = [userDefaults URLForKey:kPortraitURL];
    user.followerList = [userDefaults arrayForKey:kFollowerList];
    user.fansList = [userDefaults arrayForKey:kFansList];
    
    if (!user.nickName) {
        user.nickName = @"点击头像登录";
    }
    if (user.followerList == nil || user.followerList.count == 0) {
        user.followerList = [NSArray new];
    }
    if (user.fansList == nil || user.fansList.count == 0) {
        user.fansList = [NSArray new];
    }
    
    return user;
}

+ (NSString *)myAccessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:kAccessToken];
}

+ (void)clearCookies
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"sessionCookies"];
}

+ (void)savePortrait:(UIImage *)protrait
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:UIImagePNGRepresentation(protrait) forKey:kPortrait];
    [userDefaults synchronize];
}

+ (void)saveName:(NSString *)actorName sex:(NSInteger)sex phoneNumber:(NSString *)phoneNumber corporation:(NSString *)corporation andPosition:(NSString *)position
{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    
//    [userDefaults setObject:actorName forKey:kTrueName];
//    [userDefaults setObject:@(sex) forKey:kSex];
//    [userDefaults setObject:phoneNumber forKey:kPhoneNumber];
//    [userDefaults setObject:corporation forKey:kCorporation];
//    [userDefaults setObject:position forKey:kPosition];
//    [userDefaults synchronize];
}

+ (void)saveTweetText:(NSString *)tweetText forUser:(ino64_t)userID
{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    
//    NSString *key = [NSString stringWithFormat:@"tweetTmp_%lld", userID];
//    [userDefaults setObject:tweetText forKey:key];
//    
//    [userDefaults synchronize];
}

+ (NSArray *)getOwnAccountAndPassword
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *account = [userDefaults objectForKey:kAccount];
    NSString *password = [SSKeychain passwordForService:kService account:kAccount];
    
    if (account) {
        return @[account, password];
    }
    else return nil;
}

+ (int64_t)getOwnID
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault integerForKey:kUserID];
}

+ (NSString *)getOwnUserName
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault objectForKey:kUserName];
}

//+ (NSArray *)getActivitySignUpInfomation
//{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    
//    NSString *name = [userDefaults objectForKey:kTrueName] ?: @"";
//    NSNumber *sex = [userDefaults objectForKey:kSex] ?: @(0);
//    NSString *phoneNumber = [userDefaults objectForKey:kPhoneNumber] ?: @"";
//    NSString *corporation = [userDefaults objectForKey:kCorporation] ?: @"";
//    NSString *position = [userDefaults objectForKey:kPosition] ?: @"";
//    
//    return @[name, sex, phoneNumber, corporation, position];
//}

+ (UIImage *)getPortrait
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [UIImage imageWithData:[userDefault objectForKey:kPortrait]];
}

//+ (NSString *)getTweetText
//{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    
//    NSString *IdStr = [NSString stringWithFormat:@"tweetTmp_%lld", [Config getOwnID]];
//    NSString *tweetText = [userDefaults objectForKey:IdStr];
//    
//    return tweetText;
//}

@end

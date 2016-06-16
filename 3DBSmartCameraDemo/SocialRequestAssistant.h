//
//  SocialRequestAssistant.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/6/14.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "Config.h"
#import "ProgressHUD.h"
#import "eyemoreAPI.h"
#import "eyemoreNotificaitions.h"
#import <ShareSDK/ShareSDK.h>

#define EYEMORE_LOGIN_PLATFORM_QQ @"qq"
#define EYEMORE_LOGIN_PLATFORM_WECHAT @"weixin"


@interface SocialRequestAssistant : NSObject

+ (void)requestLikeBlogWithID:(NSInteger)blogID
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

+ (void)requestDeleteBlogWithID:(NSInteger)blogID
                        success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

+ (void)requestOauthLoginWithType:(SSDKPlatformType)type
                           openID:(NSString *)openid
                            token:(NSString *)token
                        expiresIn:(NSString *)expires_in
                         nickName:(NSString *)nickname
                           avator:(NSString *)avator
                          success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

+ (void)requestCommentWithBlogID:(NSString *)blogID
                         content:(NSString *)content
                        toUserID:(NSInteger)uid
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

+ (void)shareImage:(UIImage *)image onPlatForm:(SSDKPlatformType)platFormtype;

+ (void)requestValidCodeWithPhoneNumber:(NSString *)phone;

@end

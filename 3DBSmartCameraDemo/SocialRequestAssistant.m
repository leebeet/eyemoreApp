//
//  SocialRequestAssistant.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/6/14.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "SocialRequestAssistant.h"

@implementation SocialRequestAssistant

+ (void)requestLikeBlogWithID:(NSInteger)blogID
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_LIKE]
       parameters:@{@"bid": [NSString stringWithFormat:@"%ld", (long)blogID]}
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject){
              
              NSDictionary *result = (NSDictionary *)responseObject;
              NSLog(@"like result: %@", result);
              NSInteger status = [[result objectForKey:@"status"] integerValue];
              if (status == 1) {
                  if (success) {
                      success(task, responseObject);
                  }
                  //cell.likeLabel.text = [NSString stringWithFormat:@"%ld", [cell.likeLabel.text integerValue] + 1];
              }
              else {
                  [ProgressHUD showSuccess:NSLocalizedString(@"Liked", nil) Interaction:YES];
                  if (failure) {
                      failure(task, [[NSError alloc] initWithDomain:@"status = 0" code:0 userInfo:nil]);
                  }
              }
          }
          failure:^(NSURLSessionDataTask *task, NSError *error){
              [ProgressHUD showError:NSLocalizedString(@"Like Error", nil) Interaction:YES];
              NSLog(@"点赞失败: %@", error);
              if (failure) {
                  failure(task, error);
              }
          }];

}

+ (void)requestDeleteBlogWithID:(NSInteger)blogID
                        success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                        failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_V2_DELETE_BLOG]
      parameters:@{@"bid": [NSString stringWithFormat:@"%ld", (long)blogID]}
        progress:nil
         success:^(NSURLSessionDataTask *task, id responseObject){
             NSDictionary *result = (NSDictionary *)responseObject;
             NSInteger status = [[result objectForKey:@"status"] integerValue];
             if (status == 1) {
                 NSLog(@"%@", [result objectForKey:@"results"]);
                 [ProgressHUD showSuccess:NSLocalizedString(@"Deleted", nil) Interaction:YES];
             }
             else {
                 [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
             }
             if (success) {
                 success(task, responseObject);
             }
         }
         failure:^(NSURLSessionDataTask *task, NSError *error){
             [ProgressHUD showError:@"无法获取用户信息" Interaction:YES];
             NSLog(@"fetch profile error: %@", error);
             if (failure) {
                 failure(task, error);
             }
         }];
}

+ (void)requestValidCodeWithPhoneNumber:(NSString *)phone
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[NSString stringWithFormat:@"%@%@",eyemoreAPI_ValidCode, phone]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask *task, id responseObject){
             NSLog(@"fetch valid code response: %@", responseObject);
             NSDictionary *result = (NSDictionary *)responseObject;
             NSInteger status = [[result objectForKey:@"status"] integerValue];
             if (status == 1) {
                 [ProgressHUD showSuccess:NSLocalizedString(@"Sent", nil) Interaction:YES];
             }
             else {
                 [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
             }
         }
         failure:^(NSURLSessionDataTask *task, NSError *error){
             NSLog(@"fetch valid code error: %@", error);
         }];
}

+ (void)requestOauthLoginWithType:(SSDKPlatformType)type
                           openID:(NSString *)openid
                            token:(NSString *)token
                        expiresIn:(NSString *)expires_in
                         nickName:(NSString *)nickname
                           avator:(NSString *)avator
                          success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSString *loginType;
    if (type == SSDKPlatformTypeQQ) {
        loginType = EYEMORE_LOGIN_PLATFORM_QQ;
    }
    else {
        loginType = EYEMORE_LOGIN_PLATFORM_WECHAT;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@%@",eyemoreAPI_HTTP_PREFIX, eyemoreAPI_V2_OAUTH_LOGIN]
      parameters:@{@"type":        loginType,
                   @"openid":      openid,
                   @"access_token":token,
                   @"expires_in":  expires_in,
                   @"nickname":    nickname,
                   @"avator":      avator,
                   @"deviceos":    @"ios",
                   @"deviceid":    @"000"}
        progress:nil
         success:^(NSURLSessionDataTask *task, id responseObject){
             NSLog(@"oauth login response: %@", responseObject);
             NSDictionary *result = (NSDictionary *)responseObject;
             NSInteger status = [[result objectForKey:@"status"] integerValue];
             if (status == 1) {
                 [ProgressHUD showSuccess:NSLocalizedString(@"Sign in success", nil) Interaction:YES];
                 if (success) {
                     success(task, responseObject);
                 }
             }
             else {
                 [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
                 if (failure) {
                     failure(task, [[NSError alloc] initWithDomain:@"status = 0" code:0 userInfo:nil]);
                 }
             }
         }
         failure:^(NSURLSessionDataTask *task, NSError *error){
             NSLog(@"oauth login code error: %@", error);
             if (failure) {
                 failure(task, error);
             }
         }];
}

+ (void)requestCommentWithBlogID:(NSString *)blogID
                         content:(NSString *)content
                        toUserID:(NSInteger)uid
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    NSString *tuid;
    if (uid == 0) {
        tuid = nil;
    }
    else {
        tuid = [NSString stringWithFormat:@"%ld",uid];
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_V2_COMMENT]
       parameters:@{@"bid": blogID, @"tuid":tuid, @"comment": content}
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject){
              
              NSDictionary *result = (NSDictionary *)responseObject;
              NSLog(@"like result: %@", result);
              NSInteger status = [[result objectForKey:@"status"] integerValue];
              if (status == 1) {
                  [ProgressHUD showSuccess:NSLocalizedString(@"Post Success", nil) Interaction:YES];
                  if (success) {
                      success(task, responseObject);
                  }
              }
              else {
                  [ProgressHUD showSuccess:NSLocalizedString(@"Service Error", nil) Interaction:YES];
                  if (failure) {
                      failure(task, [[NSError alloc] initWithDomain:@"status = 0" code:0 userInfo:nil]);
                  }
              }
          }
          failure:^(NSURLSessionDataTask *task, NSError *error){
              [ProgressHUD showError:NSLocalizedString(@"Post Failed", nil) Interaction:YES];
              NSLog(@"评论失败: %@", error);
              if (failure) {
                  failure(task, error);
              }
          }];

}

+ (void)shareImage:(UIImage *)image onPlatForm:(SSDKPlatformType)platFormtype
{
    //创建分享参数
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKEnableUseClientShare];
    NSArray* imageArray = @[image];
    
    if (imageArray) {
        
        [shareParams SSDKSetupShareParamsByText:@""
                                         images:imageArray
                                            url:nil
                                          title:@""
                                           type:SSDKContentTypeImage];
                
        //进行分享
        [ShareSDK share:platFormtype
             parameters:shareParams
         onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
             
             switch (state) {
                 case SSDKResponseStateSuccess:
                 {
                     break;
                 }
                 case SSDKResponseStateFail:
                 {
                     break;
                 }
                 case SSDKResponseStateCancel:
                 {
                     break;
                 }
                 default:
                     break;
             }
         }];
    }
}

@end

//
//  eyemoreAPI.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/16.
//  Copyright © 2016年 3DB. All rights reserved.
//

#ifndef eyemoreAPI_h
#define eyemoreAPI_h

#define eyemoreAPI_ValidCode                @"http://120.25.219.198:8081/api/code?mobile="
#define eyemoreAPI_HTTP_PREFIX              @"http://120.25.163.59:8081/" //official:120.25.219.198 beta:120.25.163.59

//eyemore api 1.0
#define eyemoreAPI_ACCOUNT_REGISTER         @"account/register"
#define eyemoreAPI_ACCOUNT_LOG_IN           @"account/login"
#define eyemoreAPI_ACCOUNT_RESET_PASSWORD   @"account/password"
#define eyemoreAPI_ACCOUNT_FETCH_PROFILE    @"account/profile"
#define eyemoreAPI_ACCOUNT_UPDATE_PROFILE   @"account/update-profile"
#define eyemoreAPI_ACCOUNT_USER_PROFILE     @"account/user-profile"
#define eyemoreAPI_ACCOUNT_AVATAR_UPDATE    @"account/update-avator"
#define eyemoreAPI_ACCOUNT_UPDATE_NOTICE    @"account/update-notice"
#define eyemoreAPI_ACCOUNT_SIGN_IN          @"account/signin"
#define eyemoreAPI_ACCOUNT_LOG_OUT          @"account/logout"
#define eyemoreAPI_ACCOUNT_FEEDBACK         @"account/feedback"
#define eyemoreAPI_ACCOUNT_UPLOADS          @"account/uploads"
#define eyemoreAPI_ACCOUNT_UPLOAD           @"account/upload"
#define eyemoreAPI_ACCOUNT_LIKE             @"account/like"
#define eyemoreAPI_ACCOUNT_COMMENT          @"account/comment"
#define eyemoreAPI_ACCOUNT_FOLLOW           @"account/follow"
#define eyemoreAPI_ACCOUNT_FOLLOWLIST       @"account/follows"
#define eyemoreAPI_ACCOUNT_FANSLIST         @"account/fans"
#define eyemoreAPI_ACCOUNT_BLOGS            @"account/blogs"

//eyemore api 2.0
#define eyemoreAPI_V2_BLOGS                 @"v2/blog/list"
#define eyemoreAPI_V2_DELETE_BLOG           @"v2/blog/delete"
#define eyemoreAPI_V2_COMMENT               @"v2/blog/comment"
#define eyemoreAPI_V2_OAUTH_LOGIN           @"v2/oauth/login"

#endif /* eyemoreAPI_h */

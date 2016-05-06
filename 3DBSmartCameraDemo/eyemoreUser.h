//
//  ThreeDBUser.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 16/2/24.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface eyemoreUser : NSObject

@property (nonatomic, assign)     NSInteger userID;
@property (nonatomic, copy)       NSString *nickName;
@property (nonatomic, assign) int           followersCount;
@property (nonatomic, assign) int           fansCount;
@property (nonatomic, assign) int           favoriteCount;
@property (nonatomic, strong)     NSURL    *avatorURL;
@property (nonatomic, copy)       NSString *gender;
@property (nonatomic, copy)       NSString *location;
@property (nonatomic, strong)     NSDate   *joinTime;
@property (nonatomic, strong)     NSDate   *latestOnlineTime;
@property (nonatomic, strong)     NSArray  *followerList;

- (instancetype)initWithProfileDict:(NSDictionary *)dict;

@end

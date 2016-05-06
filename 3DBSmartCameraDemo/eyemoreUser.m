//
//  ThreeDBUser.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 16/2/24.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "eyemoreUser.h"

@implementation eyemoreUser

- (instancetype)initWithProfileDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
      
        NSDictionary *dictProfile = [dict objectForKey:@"results"];
        self.userID               = [[dictProfile objectForKey:@"uid"] integerValue];
        self.nickName             = [NSString stringWithFormat:@"%@", [dictProfile objectForKey:@"nickname"]];
        self.gender               = [dictProfile objectForKey:@"gender"];
        self.avatorURL            = [NSURL URLWithString:[dictProfile objectForKey:@"avator"]];
        self.followerList         = [NSArray new];
        self.fansList             = [NSArray new];
    }
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([self class] == [object class]) {
        return _userID == ((eyemoreUser *)object).userID;
    }
    
    return NO;
}

@end

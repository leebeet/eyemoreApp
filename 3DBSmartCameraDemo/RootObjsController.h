//
//  RootObjsController.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/24.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "eyemoreAPI.h"
#import "Config.h"
#import "DiscoverLoadMoreView.h"
#import "MJRefresh.h"

@interface RootObjsController : UITableViewController

@property (nonatomic, strong) NSMutableArray       *objects;
@property (nonatomic, assign) BOOL                  needAutoRefresh;
@property (nonatomic, assign) NSUInteger            page;
@property (nonatomic, strong) DiscoverLoadMoreView *lastCell;
@property (nonatomic, strong) UILabel              *label;
@property (nonatomic, copy)   NSString             *kLastRefreshTime;

@property (nonatomic, assign) NSInteger             loadUid;
- (void)refreshAction;

@end

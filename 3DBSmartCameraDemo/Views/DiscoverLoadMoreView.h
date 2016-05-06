//
//  DiscoverLoadMoreView.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/28.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LoadMoreViewStatus)
{
    LastCellStatusNotVisible,
    LastCellStatusMore,
    LastCellStatusLoading,
    LastCellStatusError,
    LastCellStatusFinished,
    LastCellStatusEmpty,
};
@interface DiscoverLoadMoreView : UIView

@property (nonatomic, assign) LoadMoreViewStatus status;
@property (readonly, nonatomic, assign) BOOL shouldResponseToTouch;
@property (nonatomic, copy) NSString *emptyMessage;
@property (nonatomic, strong) UILabel *textLabel;

@end

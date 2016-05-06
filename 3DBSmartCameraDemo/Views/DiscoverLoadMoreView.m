//
//  DiscoverLoadMoreView.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/28.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "DiscoverLoadMoreView.h"

@interface DiscoverLoadMoreView ()
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@end

@implementation DiscoverLoadMoreView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
        
        _status = LastCellStatusNotVisible;
        
        [self setLayout];
    }
    
    return self;
}

- (void)setLayout
{
    _textLabel.textColor = [UIColor darkGrayColor];
    _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _textLabel.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.font = [UIFont boldSystemFontOfSize:14];
    [self addSubview:_textLabel];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin  | UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _indicator.color = [UIColor redColor];
    _indicator.center = self.center;
    [self addSubview:_indicator];
}


- (BOOL)shouldResponseToTouch
{
    return _status == LastCellStatusMore || _status == LastCellStatusError;
}

- (void)setStatus:(LoadMoreViewStatus)status
{
    if (status == LastCellStatusLoading) {
        [_indicator startAnimating];
        _indicator.hidden = NO;
    } else {
        [_indicator stopAnimating];
        _indicator.hidden = YES;
    }
    
    _textLabel.text = @[
                        @"",
                        @"点击加载更多",
                        @"",
                        @"加载数据出错",
                        @"全部加载完毕",
                        _emptyMessage ?: @"",
                        ][status];
    _status = status;
}


@end

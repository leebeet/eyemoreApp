//
//  LJieSeeImagesView.h
//  LJieSeeImages
//
//  Created by liangjie on 14/11/27.
//  Copyright (c) 2014年 liangjie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLSeeImageView : UIScrollView

@property (assign, nonatomic) NSUInteger currentIndex;
@property (assign, nonatomic) BOOL       shouldEnterSleep;
@property (nonatomic, strong) NSTimer     *timer;

- (id)init;
- (id)initWithDirection:(UIDeviceOrientation)orientation;

- (void)scanImagesMode:(NSMutableArray *)imageArray WithImageIndex:(NSUInteger )index;
- (void)addImageWithPath:(NSMutableArray *)array;

- (NSString *)removeCurrentImage;
- (NSUInteger )returnCurrentImageIndex;
- (NSString *)returnCurrentImagePath;

- (void)reMonitoringSleeping;
@end

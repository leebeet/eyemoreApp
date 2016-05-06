//
//  LJieSeeImagesView.m
//  LJieSeeImages
//
//  Created by liangjie on 14/11/27.
//  Copyright (c) 2014年 liangjie. All rights reserved.
//

#import "BLSeeImageView.h"
#import "ImageClient.h"

#define IMAGEVIEWCOUNT  2   // 只有2个imageView

@interface BLSeeImageView() <UIScrollViewDelegate>

@property (nonatomic, strong) ImageClient *imgClient;

@end

@implementation BLSeeImageView
{
    NSUInteger _w;
    NSUInteger _h;
    NSUInteger _nImageCount;

    NSMutableArray * _imageViews;
    NSMutableArray * _imageArray;
    
    int _curImageViewNum;
    // 纪录上一次坐标
    CGFloat _preOption;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        
//        if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight){
//            //横屏
//            _h = [UIScreen mainScreen].bounds.size.width;
//            _w = [UIScreen mainScreen].bounds.size.height;
//        
//        }
//        
//        else {
//            //竖屏
            _w = [UIScreen mainScreen].bounds.size.width;
            _h = [UIScreen mainScreen].bounds.size.height;
//        }
    
        _imageViews = [[NSMutableArray alloc] init];
        self.frame = CGRectMake(0, 0, _w, _h);
        self.delegate = self;
        self.imgClient = [ImageClient sharedImageClient];
        for (int i=0; i<IMAGEVIEWCOUNT; ++i) {
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_w * i, 0, _w, _h)];
            [_imageViews addObject:imageView];
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.timer invalidate];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(didEnterSleepDelegate) userInfo:nil repeats:NO];
        });
    }
    
    return self;
}

- (id)initWithDirection:(UIDeviceOrientation)orientation
{
    self = [super init];
    if (self) {
        
//        if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight){
//            //横屏
//            _h = [UIScreen mainScreen].bounds.size.width;
//            _w = [UIScreen mainScreen].bounds.size.height;
//            
//        }
//        
//        else {
            //竖屏
            _w = [UIScreen mainScreen].bounds.size.width;
            _h = [UIScreen mainScreen].bounds.size.height;
//        }
        _imageViews = [[NSMutableArray alloc] init];
        self.frame = CGRectMake(0, 0, _w, _h);
        self.delegate = self;
        self.imgClient = [ImageClient sharedImageClient];
        for (int i=0; i<IMAGEVIEWCOUNT; ++i) {
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_w * i, 0, _w, _h)];
            [_imageViews addObject:imageView];
        }
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.timer invalidate];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(didEnterSleepDelegate) userInfo:nil repeats:NO];
        });
    }
    
    return self;
}


#pragma mark - Private Methods

- (void)initScollViewDisplayWithArray:(NSMutableArray *)imageArray
{
    _imageArray = imageArray;
    _nImageCount = imageArray.count;
    self.contentSize = CGSizeMake(_w * _nImageCount, 0);
    self.showsHorizontalScrollIndicator = NO;
    self.pagingEnabled = YES;
}

- (void)setTwoImageViewsDisplay
{
    for (int i=0; i<IMAGEVIEWCOUNT; i++) {
        UIImageView * imageView = _imageViews[i];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        //imageView.image = [UIImage imageWithContentsOfFile:imageArray[i]];

        
        dispatch_async(dispatch_get_main_queue(), ^(){
            //imageView.image = [self.imgClient.imgCache imageFromDiskCacheForKey:_imageArray[i]];
            //imageView.image = [UIImage imageWithCGImage:[self.imgClient.imgCache imageFromDiskCacheForKey:_imageArray[i]].CGImage scale:1 orientation:UIImageOrientationRight];
            imageView.image = [UIImage imageWithCGImage:[self.imgClient getImageForKey:_imageArray[[self returnCurrentImageIndex]]].CGImage scale:1 orientation:UIImageOrientationLeft];
            [self addSubview:imageView];
        });
    }
}

- (void)setTwoImageViewsDisplayWithIndex:(NSUInteger )index
{
    [self setTwoImageViewsDisplay];
    [self setContentOffset:CGPointMake(_w * index, 0) animated:YES];
    [self setImagesIntoImageViews];
}

- (void)setOneImageViewDisplay
{
    UIImageView * imageView = _imageViews[0];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    //imageView.image = [UIImage imageWithContentsOfFile:imageArray[0]];

    
    dispatch_async(dispatch_get_main_queue(), ^(){
            //imageView.image = [self.imgClient.imgCache imageFromDiskCacheForKey:_imageArray[0]];
            //imageView.image = [UIImage imageWithCGImage:[self.imgClient.imgCache imageFromDiskCacheForKey:_imageArray[0]].CGImage scale:1 orientation:UIImageOrientationRight];
            imageView.image = [UIImage imageWithCGImage:[self.imgClient getImageForKey:_imageArray[0]].CGImage scale:1 orientation:UIImageOrientationLeft];
        [self addSubview:imageView];
    });
}

- (void)scanImagesMode:(NSMutableArray *)imageArray WithImageIndex:(NSUInteger )index
{
    if (imageArray.count > 2) {
        //NSAssert(imageArray.count!=0 && imageArray.count>IMAGEVIEWCOUNT, @"imageArray is nil, Should not be so! And imageArray.count must be greater than/equal to IMAGEVIEWCOUNT!");
        [self initScollViewDisplayWithArray:imageArray];
        if (index) {
            [self setTwoImageViewsDisplayWithIndex:index];
        }
        else{
            [self setTwoImageViewsDisplay];
        }
    }
    else if(imageArray.count == 2){
        NSLog(@"image array count == %lu", (unsigned long)imageArray.count);
        [self initScollViewDisplayWithArray:imageArray];
        [self setContentOffset:CGPointMake(_w * 1, 0) animated:YES];
        [self setTwoImageViewsDisplay];
    }
    else if(imageArray.count == 1){
        
        [self initScollViewDisplayWithArray:imageArray];
        [self setOneImageViewDisplay];
    }
        NSLog(@"cur image view num :%d",_curImageViewNum);
}

- (void)setImagesIntoImageViews;
{
    // 3. 判断使用哪个imageView显示图片
    if (_curImageViewNum % 2) {
        UIImageView * imv = _imageViews[1];
        imv.frame = CGRectMake(_curImageViewNum*_w, 0, _w, _h);
        //imv.image = [UIImage imageNamed:_imageArray[_curImageViewNum]];
        //imv.image = [UIImage imageWithCGImage:[self.imgClient.imgCache imageFromDiskCacheForKey:_imageArray[_curImageViewNum]].CGImage scale:1 orientation:UIImageOrientationRight];
        imv.image = [UIImage imageWithCGImage:[self.imgClient getImageForKey:_imageArray[_curImageViewNum]].CGImage scale:1 orientation:UIImageOrientationLeft];
        //imv.image = [self.imgClient.imgCache imageFromDiskCacheForKey:_imageArray[_curImageViewNum]];
    } else {
        UIImageView * imv = _imageViews[0];
        imv.frame = CGRectMake(_curImageViewNum*_w, 0, _w, _h);
        //imv.image = [UIImage imageNamed:_imageArray[_curImageViewNum]];
        //imv.image = [UIImage imageWithCGImage:[self.imgClient.imgCache imageFromDiskCacheForKey:_imageArray[_curImageViewNum]].CGImage scale:1 orientation:UIImageOrientationRight];
        imv.image = [UIImage imageWithCGImage:[self.imgClient getImageForKey:_imageArray[_curImageViewNum]].CGImage scale:1 orientation:UIImageOrientationLeft];
        //imv.image = [self.imgClient.imgCache imageFromDiskCacheForKey:_imageArray[_curImageViewNum]];
    }
}
- (void)addImageWithPath:(NSMutableArray *)imageArray
{
    if (imageArray.count > 2) {
        NSAssert(imageArray.count!=0 && imageArray.count>IMAGEVIEWCOUNT, @"imageArray is nil, Should not be so! And imageArray.count must be greater than IMAGEVIEWCOUNT!");
        [self initScollViewDisplayWithArray:imageArray];
        _curImageViewNum = (int)imageArray.count - 1;
        [self setContentOffset:CGPointMake(_w * _curImageViewNum, 0) animated:YES];
        // 3. 判断使用哪个imageView显示图片
        [self setImagesIntoImageViews];
    }
    else if(imageArray.count == 2){
    
        [self initScollViewDisplayWithArray:imageArray];
        [self setContentOffset:CGPointMake(_w * 1, 0) animated:YES];
        [self setTwoImageViewsDisplay];
    }
    else if(imageArray.count == 1){
        
        [self initScollViewDisplayWithArray:imageArray];
        [self setOneImageViewDisplay];
    }
}

- (NSString *)removeCurrentImage
{
    NSMutableArray *array = [_imageArray mutableCopy];
    NSString *string = [NSString stringWithString: _imageArray[_curImageViewNum]];
    [array removeObjectAtIndex:_curImageViewNum];
    //[self setContentOffset:CGPointMake(_w * (_curImageViewNum - 1), 0) animated:YES];
    
    if (array.count > 2) {
        NSAssert(array.count!=0 && array.count>IMAGEVIEWCOUNT, @"imageArray is nil, Should not be so! And imageArray.count must be greater than IMAGEVIEWCOUNT!");
        _imageArray = array;
        _nImageCount = array.count;
        self.contentSize = CGSizeMake(_w * _nImageCount, 0);
        // 3. 判断使用哪个imageView显示图片
        [self setImagesIntoImageViews];
    }
    else if (array.count == 2)
    {
        
        [self initScollViewDisplayWithArray:array];
        [self setTwoImageViewsDisplay];
        [self setImagesIntoImageViews];
    }
    else if (array.count == 1){
        
        //[self setContentOffset:CGPointMake(_w * 0, 0) animated:YES];
        [self initScollViewDisplayWithArray:array];
        [self setOneImageViewDisplay];
        [self setImagesIntoImageViews];
    }
    else{
        
    }
    return string;
}

- (NSUInteger )returnCurrentImageIndex
{
    //self.currentIndex = _curImageViewNum;
    NSLog(@"_curImageViewNum : %d", _curImageViewNum);
    return _curImageViewNum;
}
- (NSString *)returnCurrentImagePath
{
    return _imageArray[_curImageViewNum];
}
#pragma mark - Scroll View delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _curImageViewNum = scrollView.contentOffset.x / _w;
    self.currentIndex = _curImageViewNum;
    
    
    
    // 1. 首先判断方向
    // 2. 判断边界
    // 3. 判断使用哪个imageView显示图片
    
    if (scrollView.contentOffset.x == _curImageViewNum*_w) {
        _preOption = scrollView.contentOffset.x;
        NSLog(@"pre option : %f", _preOption);
    } else if (scrollView.contentOffset.x < _preOption) {
        NSLog(@"scroll view contentOffSet : %f", scrollView.contentOffset.x);
        [self setImagesIntoImageViews];
        return;
    }

    if (scrollView.contentOffset.x >= _curImageViewNum*_w) {
        if (scrollView.contentOffset.x < _nImageCount*_w-_w) {
            if (_curImageViewNum % 2) {
                UIImageView * imv = _imageViews[0];
                imv.frame = CGRectMake(_curImageViewNum*_w+_w, 0, _w, _h);
                //imv.image = [UIImage imageNamed:_imageArray[_curImageViewNum+1]];
                //imv.image = [UIImage imageWithCGImage:[self.imgClient.imgCache imageFromDiskCacheForKey:_imageArray[_curImageViewNum+1]].CGImage scale:1 orientation:UIImageOrientationRight];
                imv.image = [UIImage imageWithCGImage:[self.imgClient getImageForKey:_imageArray[_curImageViewNum+1]].CGImage scale:1 orientation:UIImageOrientationLeft];
                //imv.image = [self.imgClient.imgCache imageFromDiskCacheForKey:_imageArray[_curImageViewNum+1]];
            } else {
                UIImageView * imv = _imageViews[1];
                imv.frame = CGRectMake(_curImageViewNum*_w+_w, 0, _w, _h);
                //imv.image = [UIImage imageNamed:_imageArray[_curImageViewNum+1]];
                //imv.image = [UIImage imageWithCGImage:[self.imgClient.imgCache imageFromDiskCacheForKey:_imageArray[_curImageViewNum+1]].CGImage scale:1 orientation:UIImageOrientationRight];
                imv.image = [UIImage imageWithCGImage:[self.imgClient getImageForKey:_imageArray[_curImageViewNum+1]].CGImage scale:1 orientation:UIImageOrientationLeft];
                //imv.image = [self.imgClient.imgCache imageFromDiskCacheForKey:_imageArray[_curImageViewNum+1]];
            }
        }
    }
    
    //monitoring enter sleeping
    dispatch_async(dispatch_get_main_queue(), ^(){
        self.shouldEnterSleep = NO;
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(didEnterSleepDelegate) userInfo:nil repeats:NO];
    });
}

- (void)reMonitoringSleeping
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        self.shouldEnterSleep = NO;
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(didEnterSleepDelegate) userInfo:nil repeats:NO];
    });
}
#pragma mark - BLSee image view delegate

- (void)didEnterSleepDelegate
{
    NSLog(@"did enter sleep");
    self.shouldEnterSleep = YES;
}

@end

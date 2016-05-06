//
//  BLMovieEncoder.h
//  BLMovieEncoder
//
//  Created by 李伯通 on 15/12/30.
//  Copyright © 2015年 Beet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^BLMovieEncoderCompletion)(NSURL *fileURL);

@interface BLMovieEncoder : NSObject

//  Exsample CMTimeMake(1, 25) is equal to 25FPS.
//
@property (nonatomic, assign) CMTime frameTime;

//  Video setting

@property (nonatomic, strong) NSDictionary *videoSettings;

//  Output Video file path
@property (nonatomic, strong) NSURL *fileURL;

@property (nonatomic, copy) BLMovieEncoderCompletion completionBlock;

//
//  Convert the images collection into a movie.

- (instancetype)initWithSettings:(NSDictionary *)videoSettings
                   withFrameTime:(CMTime)frameTime
                   OutputFileURL:(NSURL *)fURL;

- (instancetype)initWithEncodec:(NSString *)codec
                            FPS:(CMTime)frameTime
                          Width:(CGFloat)width
                         Height:(CGFloat)height
                  OutputFileURL:(NSURL *)fURL;

- (instancetype)initWithEncodec:(NSString *)codec
                           Rate:(NSString *)rate
                            FPS:(CMTime)frameTime
                          Width:(CGFloat)width
                         Height:(CGFloat)height
                OutputFileURL:(NSURL *)fURL;

- (void)encodeMovieWithImages:(NSArray *)images withCompletion:(BLMovieEncoderCompletion)completion;

@end

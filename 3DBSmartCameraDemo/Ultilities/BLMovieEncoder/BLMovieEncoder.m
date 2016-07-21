//
//  BLMovieEncoder.m
//  BLMovieEncoder
//
//  Created by 李伯通 on 15/12/30.
//  Copyright © 2015年 Beet. All rights reserved.
//

#import "BLMovieEncoder.h"

@interface BLMovieEncoder()

@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *writerInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *bufferAdapter;


@end

@implementation BLMovieEncoder

- (instancetype)initWithSettings:(NSDictionary *)videoSettings withFrameTime:(CMTime)frameTime OutputFileURL:(NSURL *)fURL;
{
    self = [self init];
    if (self) {
        
        NSError *error;
        _fileURL = fURL;
        NSLog(@"Start building video from defined frames.");
        _assetWriter = [[AVAssetWriter alloc] initWithURL:fURL
                                                 fileType:AVFileTypeQuickTimeMovie error:&error];
        if (error) {
            NSLog(@"Assetwriter allocate Error: %@", error.debugDescription);
        }
        NSParameterAssert(self.assetWriter);
        
        _videoSettings = videoSettings;
        _writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                          outputSettings:videoSettings];
        NSParameterAssert(self.writerInput);
        NSParameterAssert([self.assetWriter canAddInput:self.writerInput]);
        
        [self.assetWriter addInput:self.writerInput];
        
        NSDictionary *bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
        
        _bufferAdapter = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:self.writerInput sourcePixelBufferAttributes:bufferAttributes];
        _frameTime = frameTime;
    }
    return self;
}

- (instancetype)initWithEncodec:(NSString *)codec Rate:(NSString *)rate FPS:(CMTime)frameTime Width:(CGFloat)width Height:(CGFloat)height OutputFileURL:(NSURL *)fURL
{
    
    if ((int)width % 16 != 0 ) {
        NSLog(@"Warning: video settings width must be divisible by 16.");
    }
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   codec, AVVideoCodecKey,
                                   [NSNumber numberWithInt:(int)width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:(int)height], AVVideoHeightKey,
                                   nil];

    
    return
    [self initWithSettings:videoSettings
             withFrameTime:frameTime
             OutputFileURL:fURL];
}

- (instancetype)initWithEncodec:(NSString *)codec FPS:(CMTime)frameTime Width:(CGFloat)width Height:(CGFloat)height OutputFileURL:(NSURL *)fURL
{
    
    if ((int)width % 16 != 0 ) {
        NSLog(@"Warning: video settings width must be divisible by 16.");
    }
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   codec, AVVideoCodecKey,
                                   [NSNumber numberWithInt:(int)width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:(int)height], AVVideoHeightKey,
                                   nil];
    
    
    return
    [self initWithSettings:videoSettings
             withFrameTime:frameTime
             OutputFileURL:fURL];
}

- (void)encodeMovieWithImages:(NSArray *)images withCompletion:(BLMovieEncoderCompletion)completion
{
    self.completionBlock = completion;
    
    self.writerInput.expectsMediaDataInRealTime = YES;
    [self.assetWriter startWriting];
    [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    
    __block NSInteger i = 0;
    __block NSInteger b = 0;
    
    NSInteger frameNumber = [images count];
    
    [self.writerInput requestMediaDataWhenReadyOnQueue:mediaInputQueue usingBlock:^{
        BOOL append_ok = NO;
        while (YES){
            if (i >= frameNumber) {
                break;
            }
            if (self.writerInput.readyForMoreMediaData) {
                NSLog(@"Processing video frame (%ld,%lu)", (long)i, (unsigned long)images.count);
                //CVPixelBufferRef sampleBuffer = [self newPixelBufferFromCGImage:[[images objectAtIndex:i] CGImage]];
                @autoreleasepool {
                    CGImageRef image = [[self imageWithURL:[images objectAtIndex:i]] CGImage];
                    CVPixelBufferRef sampleBuffer = [self newPixelBufferFromCGImage:image];
                
                    if (sampleBuffer) {
                        if (b == 0) {
                            append_ok = [self.bufferAdapter appendPixelBuffer:sampleBuffer withPresentationTime:kCMTimeZero];
                        }
                        else{
                            CMTime lastTime;
                            if (self.frameTime.value == 2) {
                                //带浮点型帧数
                                lastTime = CMTimeMake(2 * (b-1), self.frameTime.timescale);
                            }
                            else {
                                //不带浮点型帧数
                                lastTime = CMTimeMake(1 * (b-1), self.frameTime.timescale);}
                            CMTime presentTime = CMTimeAdd(lastTime, self.frameTime);
                            append_ok = [self.bufferAdapter appendPixelBuffer:sampleBuffer withPresentationTime:presentTime];
                        }
                        
                        if (append_ok) {
                            CVPixelBufferRelease(sampleBuffer);
                            //CGImageRelease(image);
                            b++;
                        }
                        else {
                            NSError *error = self.assetWriter.error;
                            if (error != nil) {
                                NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
                            }
                            NSLog(@"error appending image %ld, with error.", (long)i);
                            break;
                        }
                        i++;
                    }
                    else {
                        i ++;
                    }
                }

            }
        }
        
        [self.writerInput markAsFinished];
        [self.assetWriter finishWritingWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completionBlock(self.fileURL);
            });
        }];
        
        CVPixelBufferPoolRelease(self.bufferAdapter.pixelBufferPool);
    }];

}

- (CVPixelBufferRef)newPixelBufferFromCGImage:(CGImageRef)image
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = [[self.videoSettings objectForKey:AVVideoWidthKey] floatValue];
    CGFloat frameHeight = [[self.videoSettings objectForKey:AVVideoHeightKey] floatValue];
    
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    if (status != kCVReturnSuccess){
        NSLog(@"Failed to create pixel buffer, dropping this Buffer");
        return nil;
    }
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 4 * frameWidth,
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           CGImageGetWidth(image),
                                           CGImageGetHeight(image)),
                       image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    //CGImageRelease(image);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (UIImage *)imageWithURL:(NSURL *)url
{
    if (url) {
        return [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    }
    else {
        NSLog(@"load image failed with url: %@", url);
        return nil;
    }
}

@end

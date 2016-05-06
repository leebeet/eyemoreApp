//
//  WIFIDetector.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/11/10.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import "WIFIDetector.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <UIKit/UIKit.h>


@implementation WIFIDetector

+ (WIFIDetector *)sharedWIFIDetector
{
    static WIFIDetector *instance = nil;
    if (instance == nil) {
        instance = [[WIFIDetector alloc] init];
    }
    return instance;
}

- (NSString *)getDeviceSSID

{
    
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    
    
    
    id info = nil;
    
    for (NSString *ifnam in ifs) {
        
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        if (info && [info count]) {
            
            break;
            
        }
        
    }
    
    NSDictionary *dctySSID = (NSDictionary *)info;
    
    NSString *ssid = [[dctySSID objectForKey:@"SSID"] lowercaseString];
    
    return ssid;
    
}

- (void)openWIFISetting
{
    NSURL *url = [NSURL URLWithString:@"prefs:root=WIFI"];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (BOOL)isConnecting3dbCamera
{
    NSString *string = [self getDeviceSSID];
    
    if (string == nil) {
        return NO;
    }
    
    NSString *cam = @"3db";
    NSRange foundObj=[string rangeOfString:cam options:NSCaseInsensitiveSearch];
    
    if(foundObj.length>0) {
        NSLog(@"Yes ! device is connecting to 3db cam");
        return YES;
    }
    else
    {
        NSLog(@"Oops ! device isn't connecting to 3db cam");
        return NO;
    }
}

@end

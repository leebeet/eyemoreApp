//
//  ActionSheetHelper.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/6/23.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "ActionSheetHelper.h"
#import "JGActionSheet.h"
#import "Config.h"

@implementation ActionSheetHelper

+ (void)actionShareSheetWithUserID:(NSInteger)userID blogID:(NSInteger)blogID image:(UIImage *)image inView:(UIView *)view
{
    NSArray *array = [[NSArray alloc] init];
    if (userID == [Config getOwnID]) {
        array = @[NSLocalizedString(@"Share with Wechat friends", nil),
                  NSLocalizedString(@"Share with Wechat time line", nil),
                  NSLocalizedString(@"Share with QQ friends", nil),
                  NSLocalizedString(@"Delete", nil)];
    }
    else{
        array = @[NSLocalizedString(@"Share with Wechat friends", nil),
                  NSLocalizedString(@"Share with Wechat time line", nil),
                  NSLocalizedString(@"Share with QQ friends", nil),];
    }
    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:@"" message:@"" buttonTitles:array buttonStyle:JGActionSheetButtonStyleCustomer];
    NSLog(@"array section: %@", array);
    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[NSLocalizedString(@"Cancel", nil)] buttonStyle:JGActionSheetButtonStyleCustomer];
    NSArray *sections = @[section1, cancelSection];
    JGActionSheet *actionSheet = [JGActionSheet actionSheetWithSections:sections];
    
    __weak JGActionSheet *weakSelfAction = actionSheet;
    [actionSheet setOutsidePressBlock:^(JGActionSheet *sheet){
        [weakSelfAction dismissAnimated:YES];
    }];
    [actionSheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *sheetIndexPath) {
        if (sheetIndexPath.section == 0 && sheetIndexPath.row == 0) {
            NSLog(@"sharing with wechat friend tapped");
            [SocialRequestAssistant shareImage:image onPlatForm:SSDKPlatformSubTypeWechatSession];
        }
        else if (sheetIndexPath.section == 0 && sheetIndexPath.row == 1) {
            [SocialRequestAssistant shareImage:image onPlatForm:SSDKPlatformSubTypeWechatTimeline];
        }
        
        else if (sheetIndexPath.section == 0 && sheetIndexPath.row == 2) {
            [SocialRequestAssistant shareImage:image onPlatForm:SSDKPlatformSubTypeQQFriend];
        }
        
        if (sheetIndexPath.section == 0 && sheetIndexPath.row == 3) {
            [SocialRequestAssistant requestDeleteBlogWithID:blogID
                                                    success:^(NSURLSessionDataTask *task, id responseObject){
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:eyemoreDeleteBlogNoti object:nil];
                                                    }
                                                    failure:nil];
        }
        [weakSelfAction dismissAnimated:YES];
    }];
    if (!actionSheet.isVisible) {
        [actionSheet showInView:view animated:YES];
    }
}

@end

//
//  eyemoreLaunchScreen.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/5/4.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "eyemoreLaunchScreen.h"

@interface eyemoreLaunchScreen ()

@property (nonatomic, strong) UIImageView *logo;
@property (nonatomic, strong) UILabel *slogon;

@end

@implementation eyemoreLaunchScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self lazyLoadLogo];
    [self lazyLoadSlogon];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)lazyLoadLogo
{
    if (self.logo == nil) {
        self.logo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 80)];
        self.logo.contentMode = UIViewContentModeScaleAspectFit;
        self.logo.center = CGPointMake(self.view.center.x, self.view.frame.size.height / 10 * 4.2);
        self.logo.image = [UIImage imageNamed:@"eyemore2.png"];
        [self.view addSubview:self.logo];
    }
    self.logo.alpha = 0;
    [UIView animateWithDuration:1.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         self.logo.alpha = 1;
                         self.logo.center = CGPointMake(self.view.center.x, self.view.frame.size.height / 10 * 4.5);
                     }
                     completion:^(BOOL finished){}];
}

- (void)lazyLoadSlogon
{
    if (self.slogon == nil) {
        self.slogon = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        self.slogon.center = CGPointMake(self.view.center.x, self.view.frame.size.height / 10 * 5.5);
        self.slogon.textAlignment = NSTextAlignmentCenter;
        self.slogon.textColor = [UIColor darkGrayColor];
        self.slogon.font = [UIFont systemFontOfSize:20.0];
        self.slogon.text = NSLocalizedString(@"Slogon", nil);
        [self.view addSubview:self.slogon];
    }
    self.slogon.alpha = 0;
    [UIView animateWithDuration:1.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(){
                         self.slogon.alpha = 1;
                         self.slogon.center = CGPointMake(self.view.center.x, self.logo.center.y + 60);
                     }
                     completion:^(BOOL finished){
                     
                         [UIView animateWithDuration:0.2
                                               delay:1.8
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^(){
                                              self.view.alpha = 0;
                                          }
                                          completion:^(BOOL finished){}];
                         
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            UIWindow *window = [UIApplication sharedApplication].keyWindow;
                            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                            window.rootViewController = [storyboard instantiateInitialViewController];
                             
                         });
                     
                     }];
}

@end

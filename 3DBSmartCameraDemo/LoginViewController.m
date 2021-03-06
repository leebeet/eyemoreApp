//
//  LoginViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 16/2/23.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "LoginViewController.h"
#import "DeformationButton.h"
#import "AFNetworking.h"
#import "eyemoreAPI.h"
#import "Config.h"
#import "ProgressHUD.h"
#import "TCPSocketManager.h"
#import "CMDManager.h"
#import "PolicyViewController.h"
#import "ResetPasswordController.h"
#import "RegisterViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "SocialRequestAssistant.h"

@interface LoginViewController ()<TCPSocketManagerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

//@property (weak, nonatomic) IBOutlet UITextField *codeField;
//@property (weak, nonatomic) IBOutlet UITextField *nicknameField;
//@property (weak, nonatomic) IBOutlet UIButton    *getCodeButton;
@property (weak, nonatomic) IBOutlet UIButton    *loginButton;
//@property (strong, nonatomic)        UIButton    *registerNewUserButton;
@property (strong, nonatomic) UIButton    *forgetPasswordButton;

@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *codeString;

//@property (weak, nonatomic) IBOutlet UIView *policyHintView;
@property (nonatomic, strong) TCPSocketManager *socketManager;

@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UITextFieldTextDidChanged:) name:@"UITextFieldTextDidChangeNotification" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self setUpLoginButton];
    //[self setUpRegisterNewUserButton];
    [self setUpforgetPasswordButton];
    [self setUpNaviBar];
    [self setUpBottomBar];
    [self setUpSubViews];
    //[self setCameraWorkingState];
    
//    self.codeField.alpha     = 0;
//    self.getCodeButton.alpha = 0;
//    self.nicknameField.alpha = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginAfterRegistering:) name:@"Register success" object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCameraWorkingState
{
    //self.imgClient = [ImageClient sharedImageClient];
    //self.imgClient.delegate = self;
    //self.imgClient.cameraMode = DOWNLOADMODE;
    self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    self.socketManager.delegate = self;
    //设置相机工作模式
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
}

- (void)setUpNaviBar
{
    self.navigationController.navigationBar.subviews.firstObject.alpha = 0;
}

- (void)setUpBottomBar
{
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedSpace.width = 60;
    

    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 35)];
    btn1.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentLeft;
    [btn1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btn1.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [btn1 setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(dismissButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:btn1];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 35)];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [btn setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(registerNewUserButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [toolBar setItems:@[item1, flexibleSpace, item2, flexibleSpace, fixedSpace]];
    [self.view addSubview:toolBar];
}

- (void)setUpSubViews
{
    self.accountField.delegate = self;
    self.passwordField.delegate = self;
    
    [self.accountField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
//    [self.codeField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = self;
    [self.view addGestureRecognizer:gesture];
}

#pragma mark - 键盘操作

- (void)hidenKeyboard
{
    [self.accountField resignFirstResponder];
    [self.passwordField resignFirstResponder];
//    [self.codeField resignFirstResponder];
//    [self.nicknameField resignFirstResponder];
}

- (void)returnOnKeyboard:(UITextField *)sender
{
//    if ([self.loginButton.titleLabel.text isEqualToString:NSLocalizedString(@"Sign in", nil)]) {
        if (sender == self.accountField) {
            [self.passwordField becomeFirstResponder];
        }
        else if (sender == self.passwordField) {
            [self hidenKeyboard];
            if (self.loginButton.enabled) {
                [self loginButtonTapped];
            }
        }
//    }
//    else {
//        if (sender == self.accountField) {
//            [self.passwordField becomeFirstResponder];
//        }
//        else if (sender == self.passwordField) {
//            [self.nicknameField becomeFirstResponder];
//        }
//        else if (sender == self.nicknameField) {
//            [self.codeField becomeFirstResponder];
//        }
//        else if (sender == self.codeField) {
//            [self hidenKeyboard];
//        }
//    }
}

- (IBAction)loginButtonTapped{
    
//    if ([self.loginButton.titleLabel.text isEqualToString:NSLocalizedString(@"Sign in", nil)]) {
        
        [self login];
//    }
//    else {
//        [self registerAccount];
//    }
    
}
- (IBAction)registerNewUserButtonTapped:(id)sender {
//    if ([self.registerNewUserButton.titleLabel.text isEqualToString:NSLocalizedString(@"Register", nil)]) {
        //[self updateUIToRegister];

    UIStoryboard *board = [UIStoryboard storyboardWithName:@"RegitserViewController" bundle:nil];
    RegisterViewController *controller = [board instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    [self.navigationController pushViewController:controller animated:YES];
//    }
//    else {
//        [self updateUIToLogin];
//    }
}

//- (IBAction)getCodeButtonTapped:(id)sender {
//    
//    if ([self.accountField.text length]) {
//        [self fetchValidCode];
//    }
//}

- (IBAction)dismissButtonTapped:(id)sender {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (IBAction)policyButtonTapped:(id)sender {
//    
//    PolicyViewController *controller = [[PolicyViewController alloc] init];
//    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:controller];
//    UIButton *btn = (UIButton *)sender;
//    if (btn.tag == 100) {
//        controller.policyStyle = USER_SERVICE_POLICY;
//    }
//    else {
//        controller.policyStyle = USER_PRIVACY_POLICY;
//    }
//    [self presentViewController:navi animated:YES completion:nil];
//}

- (void)forgetPasswordButtonTapped
{
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"ResetPassword" bundle:nil];
    ResetPasswordController *controller = [board instantiateViewControllerWithIdentifier:@"ResetPasswordController"];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navi animated:YES completion:nil];
}

- (IBAction)oauthLoginButtonTapped:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    SSDKPlatformType loginType;
    if (btn.tag == 1) {
        loginType = SSDKPlatformTypeQQ;
    }
    else {
        loginType = SSDKPlatformTypeWechat;
    }
    [ShareSDK authorize:loginType settings:nil onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error){
        switch (state) {
            case SSDKResponseStateSuccess:
            {
                
                [SocialRequestAssistant requestOauthLoginWithType:loginType
                                                           openID:user.uid
                                                            token:user.credential.token
                                                        expiresIn:[user.credential.rawData objectForKey:@"expires_in"]
                                                         nickName:user.nickname
                                                           avator:user.icon
                                                          success:^(NSURLSessionDataTask *task, id responseObject){
                                                              NSDictionary *loginDict = [(NSDictionary *)responseObject objectForKey:@"results"];
                                                              [self fetchProfileWithDict:loginDict];
                                                          }
                                                          failure:^(NSURLSessionDataTask *task, NSError *error){}];
                //NSLog(@"user.rawData: %@", user.rawData);
                //NSLog(@"user.credential: %@", user.credential.rawData);
                break;
            }
            case SSDKResponseStateFail:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"授权失败"
                                                                    message:[NSString stringWithFormat:@"%@", error]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                [alertView show];
                
                break;
            }
            case SSDKResponseStateCancel:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"授权已取消"
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                [alertView show];
                break;
            }
            default:
                break;
        }
    }];
    
}
#pragma mark - Set Up Instance

//- (void)setUpLoginButton
//{
//    self.loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 45)];
//    [self.loginButton setBackgroundColor:[UIColor grayColor]];
//    self.loginButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:3];
//    [self.loginButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
//    [self.loginButton setTitle:NSLocalizedString(@"Sign in", nil) forState:UIControlStateNormal];
//    [self.loginButton addTarget:self action:@selector(loginButtonTapped) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.loginButton];
//    self.loginButton.layer.masksToBounds = YES;
//    self.loginButton.layer.cornerRadius = 5;
//    self.loginButton.center = CGPointMake(self.view.frame.size.width / 2, self.nicknameField.center.y + 27);
//    [self.loginButton setEnabled:NO];
//    
//}

//- (void)setUpRegisterNewUserButton
//{
//    self.registerNewUserButton = [[UIButton alloc] initWithFrame:CGRectMake(18, self.loginButton.center.y + 25, 75, 30)];
//    self.registerNewUserButton.titleLabel.font = [UIFont systemFontOfSize:14];
//    [self.registerNewUserButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    [self.registerNewUserButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    [self.registerNewUserButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
//    [self.registerNewUserButton setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
//    [self.registerNewUserButton addTarget:self action:@selector(registerNewUserButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.registerNewUserButton];
//}

- (void)setUpforgetPasswordButton
{
    self.forgetPasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 18 - 130, self.loginButton.center.y + 45, 130, 30)];
    self.forgetPasswordButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.forgetPasswordButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.forgetPasswordButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.forgetPasswordButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.forgetPasswordButton setTitle:NSLocalizedString(@"Forgot Password?", nil) forState:UIControlStateNormal];
    [self.forgetPasswordButton addTarget:self action:@selector(forgetPasswordButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.forgetPasswordButton];
}

#pragma mark - UI Updating

// - (void)updateUIToRegister
//{
//    self.codeField.alpha     = 0;
//    self.getCodeButton.alpha = 0;
//    self.nicknameField.alpha = 0;
//    self.policyHintView.alpha = 0;
//    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^(){
//        self.registerNewUserButton.center = CGPointMake(self.registerNewUserButton.center.x, self.registerNewUserButton.center.y + 100);
//        self.forgetPasswordButton.center  = CGPointMake(self.forgetPasswordButton.center.x, self.forgetPasswordButton.center.y + 100);
//        self.loginButton.center           = CGPointMake(self.loginButton.center.x, self.loginButton.center.y + 100);
//        
//    } completion:^(BOOL finished){
//        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^(){
//            [self.registerNewUserButton setTitle:NSLocalizedString(@"Sign in", nil)forState:UIControlStateNormal];
//            [self.loginButton setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
//            self.codeField.alpha = 1;
//            self.getCodeButton.alpha = 1;
//            self.nicknameField.alpha = 1;
//            self.policyHintView.alpha = 1;
//            
//        } completion:^(BOOL finished){}];
//    }];
//}
//
//- (void)updateUIToLogin
//{
//    self.codeField.alpha     = 1;
//    self.getCodeButton.alpha = 1;
//    self.nicknameField.alpha = 1;
//    self.policyHintView.alpha = 1;
//    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^(){
//
//        self.codeField.alpha = 0;
//        self.getCodeButton.alpha = 0;
//        self.nicknameField.alpha = 0;
//        
//    } completion:^(BOOL finished){
//        
//        [UIView animateWithDuration:0.3f delay:0.2f options:UIViewAnimationOptionAllowUserInteraction animations:^(){
//            [self.registerNewUserButton setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
//            [self.loginButton setTitle:NSLocalizedString(@"Sign in", nil) forState:UIControlStateNormal];
//            
//            self.registerNewUserButton.center = CGPointMake(self.registerNewUserButton.center.x, self.registerNewUserButton.center.y - 100);
//            self.forgetPasswordButton.center  = CGPointMake(self.forgetPasswordButton.center.x, self.forgetPasswordButton.center.y - 100);
//            self.loginButton.center           = CGPointMake(self.loginButton.center.x, self.loginButton.center.y - 100);
//            
//            self.codeField.alpha = 0;
//            self.getCodeButton.alpha = 0;
//            self.policyHintView.alpha = 0;
//            
//        } completion:^(BOOL finished){}];
//    }];
//}

- (void)loginAfterRegistering:(NSNotification *)noti
{
    NSArray *array = [noti object];
    self.accountField.text = array[0];
    self.passwordField.text = array[1];
    [self login];    
}
#pragma mark - Account operation

- (void)login
{
    [ProgressHUD show:NSLocalizedString(@"Signing in", nil) Interaction:YES];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_LOG_IN]
       parameters:@{@"mobile": self.accountField.text, @"password": self.passwordField.text, @"deviceos":@"ios", @"deviceid": @"000"}
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject){
              
              NSDictionary *result = (NSDictionary *)responseObject;
              NSLog(@"login response object :%@", result);
              NSInteger status = [[result objectForKey:@"status"] integerValue];
              if (status == 1) {
                  NSDictionary *loginDict = [(NSDictionary *)responseObject objectForKey:@"results"];
                  [self fetchProfileWithDict:loginDict];
              }
              else {
                  [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
              }
          }
          failure:^(NSURLSessionDataTask *task, NSError *error){
              [ProgressHUD showError:NSLocalizedString(@"Login Failed", nil) Interaction:YES];
              NSLog(@"login error: %@", error);
        }];
}

//- (void)registerAccount
//{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_REGISTER]
//       parameters:@{@"mobile": self.accountField.text, @"password": self.passwordField.text, @"code": self.codeField.text, @"nickname": self.nicknameField.text}
//         progress:nil
//          success:^(NSURLSessionDataTask * task, id responseObject){
//              NSDictionary *result = (NSDictionary *)responseObject;
//              NSInteger status = [[result objectForKey:@"status"] integerValue];
//              if (status == 1) {
//                  NSLog(@"%@", [result objectForKey:@"results"]);
//                  [self login];
//                  [ProgressHUD showSuccess:NSLocalizedString(@"Registered", nil) Interaction:YES];
//              }
//              else {
//                  [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
//              }
//          }
//          failure:^(NSURLSessionDataTask *task, NSError *error){
//              [ProgressHUD showError:NSLocalizedString(@"Register Failed", nil) Interaction:YES];
//              NSLog(@"注册失败: %@", error);
//          }];
//}

- (void)fetchProfileWithDict:(NSDictionary *)loginDict
{
    
    [Config saveAccessToken:[loginDict objectForKey:@"access_token"]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager GET:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_FETCH_PROFILE]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask *task, id responseObject){
             NSDictionary *result = (NSDictionary *)responseObject;
             NSInteger status = [[result objectForKey:@"status"] integerValue];
             if (status == 1) {
                 NSLog(@"%@", [result objectForKey:@"results"]);
                 [self renewUserWithDict:result];
                 [Config saveOwnAccount:self.accountField.text andPassword:self.passwordField.text];
                 [ProgressHUD showSuccess:NSLocalizedString(@"Sign in success", nil) Interaction:YES];
             }
             else {
                 [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
             }
         }
         failure:^(NSURLSessionDataTask *task, NSError *error){
             [ProgressHUD showError:@"无法获取用户信息" Interaction:YES];
             NSLog(@"fetch profile error: %@", error);
         }];
}

- (void)fetchFollowerListWith:(eyemoreUser *)user
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_FOLLOWLIST]
       parameters:@{ @"uid": [NSString stringWithFormat:@"%ld", (long)user.userID]}
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject){

              NSDictionary *result = (NSDictionary *)responseObject;
              NSInteger status = [[result objectForKey:@"status"] integerValue];
              NSArray *followList = [result valueForKey:@"results"];
              NSLog(@"%@", result);
              if (status == 1) {
                  if (followList != nil && followList.count > 0) {
                      user.followerList = followList;
                      [Config saveProfile:user];
                  }
                  [self fetchFansListWith:[Config myProfile]];
//                  dispatch_async(dispatch_get_main_queue(), ^(){
//                      [self dismissViewControllerAnimated:YES completion:nil];
//                  });
              }
              else {
                  [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
              }
          }
          failure:^(NSURLSessionDataTask *task, NSError *error){
              [ProgressHUD showError:@"获取关注列表失败" Interaction:YES];
              dispatch_async(dispatch_get_main_queue(), ^(){
                  [self dismissViewControllerAnimated:YES completion:nil];
              });
              NSLog(@"获取失败: %@", error);
          }];
}

- (void)fetchFansListWith:(eyemoreUser *)user
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_FANSLIST]
       parameters:@{ @"uid": [NSString stringWithFormat:@"%ld", (long)user.userID]}
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject){
              
              NSDictionary *result = (NSDictionary *)responseObject;
              NSInteger status = [[result objectForKey:@"status"] integerValue];
              NSArray *fansList = [result valueForKey:@"results"];
              NSLog(@"%@", result);
              if (status == 1) {
                  if (fansList != nil && fansList.count > 0) {
                      user.fansList = fansList;
                      [Config saveProfile:user];
                  }
                  dispatch_async(dispatch_get_main_queue(), ^(){
                      [self dismissViewControllerAnimated:YES completion:nil];
                      [[NSNotificationCenter defaultCenter] postNotificationName:@"userRefresh" object:@(YES)];
                  });                  
              }
              else {
                  [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
              }
          }
          failure:^(NSURLSessionDataTask *task, NSError *error){
              [ProgressHUD showError:@"获取关注列表失败" Interaction:YES];
              dispatch_async(dispatch_get_main_queue(), ^(){
                  [self dismissViewControllerAnimated:YES completion:nil];
              });
              NSLog(@"获取失败: %@", error);
          }];
}

//- (void)fetchValidCode
//{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager GET:[NSString stringWithFormat:@"%@%@",eyemoreAPI_ValidCode, self.accountField.text]
//       parameters:nil
//         progress:nil
//          success:^(NSURLSessionDataTask *task, id responseObject){
//              NSLog(@"fetch valid code response: %@", responseObject);
//              NSDictionary *result = (NSDictionary *)responseObject;
//              NSInteger status = [[result objectForKey:@"status"] integerValue];
//              if (status == 1) {
//                  [ProgressHUD showSuccess:NSLocalizedString(@"Sent", nil) Interaction:YES];
//              }
//              else {
//                  [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
//              }
//              
//          }
//          failure:^(NSURLSessionDataTask *task, NSError *error){
//              NSLog(@"fetch valid code error: %@", error);
//          }];
//}

- (void)renewUserWithDict:(NSDictionary *)dict
{
    [Config saveProfile:[[eyemoreUser alloc] initWithProfileDict:dict]];
    [self saveCookies];
    [self fetchFollowerListWith:[Config myProfile]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userRefresh" object:@(YES)];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Texting Notification

- (void)UITextFieldTextDidChanged:(NSNotification *)noti
{
    UITextField *textField = [noti  object];
    static BOOL isAccountTexted = NO;
    static BOOL isPasswordTexted = NO;
//    static BOOL isNickNameTexted = NO;
//    static BOOL isCodeTexted = NO;
//    if ([self.loginButton.titleLabel.text isEqualToString:NSLocalizedString(@"Sign in", nil)]) {
        if (textField == self.accountField) {
            if (self.accountField.text.length > 0) {
                isAccountTexted = YES;
            }
            else isAccountTexted = NO;
        }
        else if (textField == self.passwordField) {
            if (self.passwordField.text.length > 0) {
                isPasswordTexted = YES;
            }
            else isPasswordTexted = NO;
        }
        if (isPasswordTexted && isAccountTexted) {
            [self.loginButton setEnabled:YES];
            [self.loginButton setBackgroundColor:[UIColor darkGrayColor]];
        }
        else {
            [self.loginButton setEnabled:NO];
            [self.loginButton setBackgroundColor:[UIColor grayColor]];
        }
//    }
//    else {
//        if (textField == self.accountField) {
//            if (self.accountField.text.length > 0) {
//                isAccountTexted = YES;
//            }
//            else isAccountTexted = NO;
//        }
//        else if (textField == self.passwordField) {
//            if (self.passwordField.text.length > 0) {
//                isPasswordTexted = YES;
//            }
//            else isPasswordTexted = NO;
//        }
//        else if (textField == self.nicknameField) {
//            if (self.nicknameField.text.length > 0) {
//                isNickNameTexted = YES;
//            }
//            else isNickNameTexted = NO;
//        }
//        else if (textField == self.codeField) {
//            if (self.codeField.text.length > 0) {
//                isCodeTexted = YES;
//            }
//            else isCodeTexted = NO;
//        }
//
//        if (isPasswordTexted && isAccountTexted && isCodeTexted && isNickNameTexted) {
//            [self.loginButton setEnabled:YES];
//            [self.loginButton setBackgroundColor:[UIColor darkGrayColor]];
//        }
//        else {
//            [self.loginButton setEnabled:NO];
//            [self.loginButton setBackgroundColor:[UIColor grayColor]];
//        }
//    }
}

/*** 不知为何有时退出应用后，cookie不保存，所以这里手动保存cookie ***/

- (void)saveCookies
{
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: cookiesData forKey: @"sessionCookies"];
    [defaults synchronize];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Socket Manager Delegate

- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command
{
    [self.socketManager receiveMessageWithTimeOut:-1];
}

- (void)didReceiveACKWithState:(CTL_MESSAGE_PACKET)ACK
{}

- (void)didFinishConnectToHost
{}

- (void)didDisconnectSocket
{}

- (void)didReceiveDevInfo:(DEV_INFO)decInfo
{}

- (void)didReceiveLensStatus:(LENS_PARAMS)lensStatus
{}

- (void)didFinishSingleFileDownloadingWithImageData:(NSData *)imageData
{}

- (void)didLoseAlive
{}

@end

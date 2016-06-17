//
//  RegisterViewController.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/6/8.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "RegisterViewController.h"
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
#import "SocialRequestAssistant.h"

@interface RegisterViewController ()<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic)  UIView      *loginView;
@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *codeField;
@property (weak, nonatomic) IBOutlet UITextField *nicknameField;
@property (weak, nonatomic) IBOutlet UIButton    *registerButton;

@end

@implementation RegisterViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    self.navigationItem.hidesBackButton = YES;
    [self setUpBottomBar];
    [self setUpSubViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpBottomBar
{
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 35)];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [btn setTitle:NSLocalizedString(@"Sign in", nil) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(signInItemTapped:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [toolBar setItems:@[flexibleSpace, item, flexibleSpace]];
    [self.view addSubview:toolBar];
}

- (void)setUpSubViews
{
    self.accountField.delegate = self;
    self.passwordField.delegate = self;
    self.nicknameField.delegate = self;
    self.codeField.delegate = self;
    
    [self.accountField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.codeField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.nicknameField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = self;
    [self.view addGestureRecognizer:gesture];
}

- (void)signInItemTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)registerButtonTapped:(id)sender {
    
    [self registerAccount];
}

- (IBAction)policyButtonTapped:(id)sender {
    
    PolicyViewController *controller = [[PolicyViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:controller];
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 100) {
        controller.policyStyle = USER_SERVICE_POLICY;
    }
    else {
        controller.policyStyle = USER_PRIVACY_POLICY;
    }
    [self presentViewController:navi animated:YES completion:nil];
}

- (IBAction)getVaildCodeButtonTapped:(id)sender {
    
    if (self.accountField.text != nil) {
        [SocialRequestAssistant requestValidCodeWithPhoneNumber:self.accountField.text];
    }
    else {
        [ProgressHUD showError:NSLocalizedString(@"Wrong number", nil)];
    }
}
#pragma mark - 键盘操作

- (void)hidenKeyboard
{
    [self.accountField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.codeField resignFirstResponder];
    [self.nicknameField resignFirstResponder];
}

- (void)returnOnKeyboard:(UITextField *)sender
{
    if (sender == self.accountField) {
        [self.passwordField becomeFirstResponder];
    }
    else if (sender == self.passwordField) {
        [self.nicknameField becomeFirstResponder];
    }
    else if (sender == self.nicknameField) {
        [self.codeField becomeFirstResponder];
    }
    else if (sender == self.codeField) {
        [self hidenKeyboard];
    }
}

- (void)UITextFieldTextDidChanged:(NSNotification *)noti
{
    UITextField *textField = [noti  object];
    static BOOL isAccountTexted = NO;
    static BOOL isPasswordTexted = NO;
    static BOOL isNickNameTexted = NO;
    static BOOL isCodeTexted = NO;
    
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
    else if (textField == self.nicknameField) {
        if (self.nicknameField.text.length > 0) {
            isNickNameTexted = YES;
        }
        else isNickNameTexted = NO;
    }
    else if (textField == self.codeField) {
        if (self.codeField.text.length > 0) {
            isCodeTexted = YES;
        }
        else isCodeTexted = NO;
    }
    
    if (isPasswordTexted && isAccountTexted && isCodeTexted && isNickNameTexted) {
        [self.registerButton setEnabled:YES];
        [self.registerButton setBackgroundColor:[UIColor darkGrayColor]];
    }
    else {
        [self.registerButton setEnabled:NO];
        [self.registerButton setBackgroundColor:[UIColor grayColor]];
    }

}

- (void)registerAccount
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_REGISTER]
       parameters:@{@"mobile": self.accountField.text, @"password": self.passwordField.text, @"code": self.codeField.text, @"nickname": self.nicknameField.text}
         progress:nil
          success:^(NSURLSessionDataTask * task, id responseObject){
              NSDictionary *result = (NSDictionary *)responseObject;
              NSInteger status = [[result objectForKey:@"status"] integerValue];
              if (status == 1) {
                  NSLog(@"%@", [result objectForKey:@"results"]);
                  [ProgressHUD showSuccess:NSLocalizedString(@"Registered", nil) Interaction:YES];
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"Register success" object:@[self.accountField.text, self.passwordField.text]];
                  [self.navigationController popViewControllerAnimated:YES];
              }
              else {
                  [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
              }
          }
          failure:^(NSURLSessionDataTask *task, NSError *error){
              [ProgressHUD showError:NSLocalizedString(@"Register Failed", nil) Interaction:YES];
              NSLog(@"注册失败: %@", error);
          }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

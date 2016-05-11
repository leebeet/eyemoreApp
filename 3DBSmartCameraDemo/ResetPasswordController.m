//
//  ResetPasswordController.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/5/11.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "ResetPasswordController.h"
#import "AFNetworking.h"
#import "eyemoreAPI.h"
#import "Config.h"
#import "TCPSocketManager.h"
#import "CMDManager.h"
#import "ProgressHUD.h"

@interface ResetPasswordController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *validCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *validCodeButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;

@end

@implementation ResetPasswordController

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
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                               target:self
                                               action:@selector(dismissController)]];
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    [self setUpSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpSubviews
{
    self.phoneTextField.delegate      = self;
    self.validCodeTextField.delegate  = self;
    self.passwordTextField.delegate   = self;
    self.rePasswordTextField.delegate = self;
    
    [self.phoneTextField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.validCodeTextField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordTextField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.rePasswordTextField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];
}

- (void)returnOnKeyboard:(UITextField *)sender
{
    if (sender == self.phoneTextField) {
        [self.validCodeTextField becomeFirstResponder];
    }
    else if (sender == self.validCodeTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (sender == self.passwordTextField) {
        [self.rePasswordTextField becomeFirstResponder];
    }
    else if (sender == self.rePasswordTextField) {
        [self hidenKeyboard];
    }
}

- (void)hidenKeyboard
{
    [self.phoneTextField resignFirstResponder];
    [self.validCodeTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.rePasswordTextField resignFirstResponder];
}

- (void)dismissController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)validCodeButtonTapped:(id)sender {
    [self fetchValidCode];
}

- (IBAction)resetButtonTapped:(id)sender {
    if ([self.passwordTextField.text isEqualToString:self.rePasswordTextField.text]) {
        [self resetPasswordOperation];
    }
    else {
        [ProgressHUD showError:@"密码不相同"];
    }
}

- (void)UITextFieldTextDidChanged:(NSNotification *)noti
{
    UITextField *textField = [noti  object];
    static BOOL isAccountTexted = NO;
    static BOOL isPasswordTexted = NO;
    static BOOL isRepasswordTexted = NO;
    static BOOL isCodeTexted = NO;
    if (textField == self.phoneTextField) {
        if (self.phoneTextField.text.length > 0) {
            isAccountTexted = YES;
        }
        else isAccountTexted = NO;
    }
    else if (textField == self.passwordTextField) {
        if (self.passwordTextField.text.length > 0) {
            isPasswordTexted = YES;
        }
        else isPasswordTexted = NO;
    }
    else if (textField == self.rePasswordTextField) {
        if (self.rePasswordTextField.text.length > 0) {
            isRepasswordTexted = YES;
        }
        else isRepasswordTexted = NO;
    }
    else if (textField == self.validCodeTextField) {
        if (self.validCodeTextField.text.length > 0) {
            isCodeTexted = YES;
        }
        else isCodeTexted = NO;
    }
    if (isAccountTexted) {
        [self.validCodeButton setEnabled:YES];
        [self.validCodeButton setBackgroundColor:[UIColor darkGrayColor]];
    }
    else {
        [self.validCodeButton setEnabled:NO];
        [self.validCodeButton setBackgroundColor:[UIColor grayColor]];
    }
    
    if (isAccountTexted && isPasswordTexted && isRepasswordTexted && isCodeTexted) {
        [self.resetButton setEnabled:YES];
        [self.resetButton setBackgroundColor:[UIColor darkGrayColor]];
    }
    else {
        [self.resetButton setEnabled:NO];
        [self.resetButton setBackgroundColor:[UIColor grayColor]];
    }
}

- (void)fetchValidCode
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[NSString stringWithFormat:@"%@%@",eyemoreAPI_ValidCode, self.phoneTextField.text]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask *task, id responseObject){
             NSLog(@"fetch valid code response: %@", responseObject);
             NSDictionary *result = (NSDictionary *)responseObject;
             NSInteger status = [[result objectForKey:@"status"] integerValue];
             if (status == 1) {
                 [ProgressHUD showSuccess:@"发送成功" Interaction:YES];
             }
             else {
                 [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
             }
             
         }
         failure:^(NSURLSessionDataTask *task, NSError *error){
             NSLog(@"fetch valid code error: %@", error);
         }];
}

- (void)resetPasswordOperation
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:[NSString stringWithFormat:@"%@%@",eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_RESET_PASSWORD]
       parameters:@{@"mobile": self.phoneTextField.text, @"password": self.passwordTextField.text, @"code":self.validCodeTextField.text}
        progress:nil
         success:^(NSURLSessionDataTask *task, id responseObject){
             NSLog(@"fetch valid code response: %@", responseObject);
             NSDictionary *result = (NSDictionary *)responseObject;
             NSInteger status = [[result objectForKey:@"status"] integerValue];
             if (status == 1) {
                 [ProgressHUD showSuccess:@"重置成功" Interaction:YES];
                 [self dismissController];
             }
             else {
                 [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
             }
             
         }
         failure:^(NSURLSessionDataTask *task, NSError *error){
             NSLog(@"fetch valid code error: %@", error);
         }];

}

@end

//
//  MyProfileTableController.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/21.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "MyProfileTableController.h"
#import "AFNetworking.h"
#import "SDWebImageManager.h"
#import "Config.h"
#import "eyemoreUser.h"
#import "FSMediaPicker.h"
#import "eyemoreAPI.h"
#import "ProgressHUD.h"
#import "ResetPasswordController.h"

@interface MyProfileTableController ()<FSMediaPickerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) eyemoreUser *myProfile;
@property (nonatomic, strong) FSMediaPicker *imagePicker;
@property (nonatomic, strong) NSIndexPath *selectedAvatorIndex;
@property (nonatomic, strong) UIImage *updateAvatar;
@property (nonatomic, strong) NSArray *genderArray;
@property (nonatomic, strong) UIPickerView *genderPicker;
@end

@implementation MyProfileTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.myProfile = [Config myProfile];
    // setup background color
    self.view.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
    [self setUpNavigationBar];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userRefresh" object:@(YES)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpNavigationBar
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [btn setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self.navigationItem setRightBarButtonItem:btnItem];

}

- (void)configureTextField:(UITextField *)textfield
{
    textfield.delegate = self;
    [textfield addTarget:self action:@selector(returnOnKeyBoard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidEndEditingNotification:) name:@"UITextFieldTextDidEndEditingNotification" object:nil];
}

- (void)returnOnKeyBoard:(id)sender
{
    [(UITextField *)sender resignFirstResponder];
}

- (void)textFieldTextDidEndEditingNotification:(NSNotification *)noti
{
    UITextField *textField = [noti object];
    if (textField.tag == 2) {
        self.myProfile.nickName = textField.text;
    }
}

- (void)hidenKeyboard
{

}

- (void)saveButtonTapped:(id)sender
{
    if (self.updateAvatar) {
        [self updateProfileWithImageData:self.updateAvatar];
    }
    else [self updateUserProfile:self.myProfile];
}

- (void)setUpGenderPicker
{
    
    if (self.genderPicker == nil) {
        self.genderPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 64, self.view.frame.size.width, self.view.frame.size.height / 4)];
        self.genderPicker.delegate = self;
        self.genderPicker.dataSource = self;
        self.genderArray = @[@"男", @"女"];
    }
    [self.view addSubview:self.genderPicker];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(){
        self.genderPicker.frame = CGRectMake(0, self.view.frame.size.height / 4 * 3, self.view.frame.size.width, self.view.frame.size.height / 4);
    } completion:^(BOOL finished){}];
    
}

- (void)unSetUpGenderPicker
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(){
        self.genderPicker.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height / 4);
    } completion:^(BOOL finished){
        [self.genderPicker removeFromSuperview];
        self.genderPicker = nil;
    }];
    
}

- (void)logOut
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager GET:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_LOG_OUT]
      parameters:nil
        progress:nil
         success:^(NSURLSessionDataTask *task, id responseObject){
             NSDictionary *result = (NSDictionary *)responseObject;
             NSInteger status = [[result objectForKey:@"status"] integerValue];
             if (status == 1) {
                 NSLog(@"%@", [result objectForKey:@"results"]);
                 
                 self.myProfile.userID = 0;
                 [Config saveProfile:self.myProfile];
                 dispatch_async(dispatch_get_main_queue(), ^(){
                     [ProgressHUD showSuccess:@"已退出登录"];
                     [self.navigationController popViewControllerAnimated:YES];
                 });
             }
             else {
                 [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
             }
             
         }
         failure:^(NSURLSessionDataTask *task, NSError *error){
             [ProgressHUD showError:@"无法登出" Interaction:YES];
             NSLog(@"无法登出 error: %@", error);
         }];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        self.selectedAvatorIndex = indexPath;
        UIView *avatorView = [cell.contentView viewWithTag:1];
        UIImageView *avator = [avatorView viewWithTag:0];
        if (![self.myProfile.avatorURL.absoluteString isEqualToString:@""]) {
            [[SDWebImageManager sharedManager] downloadImageWithURL:self.myProfile.avatorURL
                                                            options:0
                                                           progress:nil
                                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
                                                              [avator setImage:image];
                                                          }];
        } 
    }
    if (indexPath.section == 1 &&indexPath.row == 0) {
        UITextField *nickName = [cell.contentView viewWithTag:2];
        [nickName setText:self.myProfile.nickName];
        [self configureTextField:nickName];
        
    }
    if (indexPath.section == 1 &&indexPath.row == 1) {
         UILabel *gender = [cell.contentView viewWithTag:2];
        if ([self.myProfile.gender integerValue] == 1) {
            [gender setText:@"男"];
        }
        else [gender setText:@"女"];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did selected row : %ld and section : %ld", (long)indexPath.row, (long)indexPath.section);
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        FSMediaPicker *mediaPicker = [[FSMediaPicker alloc] init];
        mediaPicker.mediaType = FSMediaTypePhoto;
        mediaPicker.editMode = FSEditModeStandard;
        mediaPicker.delegate = self;
        [mediaPicker showFromView:self.view];
    }
    if (indexPath.section == 1 &&indexPath.row == 0) {

    }
    if (indexPath.section == 1 &&indexPath.row == 1) {
        static BOOL isPickering = NO;
        if (isPickering == NO) {
            [self setUpGenderPicker];
            isPickering = YES;
        }
        else {
            [self unSetUpGenderPicker];
            isPickering = NO;
        }
    }
    if (indexPath.section == 1 &&indexPath.row == 2) {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"ResetPassword" bundle:nil];
        ResetPasswordController *controller = [board instantiateViewControllerWithIdentifier:@"ResetPasswordController"];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navi animated:controller completion:nil];
    }
    if (indexPath.section == 2 && indexPath.row == 0) {
        [self logOut];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UI PickerView delegate & data source

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 45;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.genderArray.count;;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.genderArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *selectGender = self.genderArray[row];
    if ([selectGender isEqualToString:@"男"]) {
        self.myProfile.gender = @"1";
    }
    else self.myProfile.gender = @"0";
    [self.tableView reloadData];
}

//返回每行view，可以设置view的外观
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        [pickerLabel setTextColor:[UIColor whiteColor]];
        [pickerLabel setBackgroundColor:[UIColor darkGrayColor]];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setFont:[UIFont fontWithName:@"Trebuchet MS" size:20]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

#pragma mark - FSMediaPicker Delegate

- (void)mediaPicker:(FSMediaPicker *)mediaPicker didFinishWithMediaInfo:(NSDictionary *)mediaInfo
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.selectedAvatorIndex];
    UIView *avatorView = [cell.contentView viewWithTag:1];
    UIImageView *avator = [avatorView viewWithTag:0];
    avator.image = mediaInfo.editedImage;
    self.updateAvatar = mediaInfo.editedImage;
}

- (void)updateProfileWithImageData:(UIImage *)image
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_AVATAR_UPDATE]
       parameters:@{@"avator":@"avator"} constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
                          NSData *data = UIImageJPEGRepresentation(image, 0.99);
                          [formData appendPartWithFileData:data name:@"avator" fileName:@"avator.jpg" mimeType:@"image/png"];
    }
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject){
                NSDictionary *result = (NSDictionary *)responseObject;
                NSInteger status = [[result objectForKey:@"status"] integerValue];
                if (status == 1) {
                    NSLog(@"%@", [result objectForKey:@"results"]);
                    self.myProfile.avatorURL = [NSURL URLWithString:[[result objectForKey:@"results"] objectForKey:@"avator"]];
//                    [Config updateProfile:self.myProfile];
//                    [ProgressHUD showSuccess:@"上传成功" Interaction:YES];
                    [self updateUserProfile:self.myProfile];
                }
                else {
                    [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
                }
            }
            failure:^(NSURLSessionDataTask *task, NSError *error){
                [ProgressHUD showError:@"更新头像失败" Interaction:YES];
                NSLog(@"update avator error: %@", error);
            }];
}

- (void)updateUserProfile:(eyemoreUser *)profile
{
    NSString *nickname = profile.nickName;
    NSString *genger = profile.gender;

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_UPDATE_PROFILE]
       parameters:@{@"nickname": nickname, @"gender": genger}
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject){
              NSDictionary *result = (NSDictionary *)responseObject;
              NSInteger     status = [[result objectForKey:@"status"] integerValue];
              if (status == 1) {
                  NSLog(@"%@", [result objectForKey:@"results"]);
                  //self.myProfile.avatorURL = [NSURL URLWithString:[[result objectForKey:@"results"] objectForKey:@"avator"]];
                  //[Config updateProfile:self.myProfile];
                  //[ProgressHUD showSuccess:@"更新资料成功" Interaction:YES];
                  [self getUserProfile];
              }
              else {
                  [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
              }

          }
          failure:^(NSURLSessionDataTask *task, NSError *error){
              [ProgressHUD showError:@"更新失败" Interaction:YES];
              NSLog(@"update avator error: %@", error);

          }];
}

- (void)getUserProfile
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_FETCH_PROFILE]
       parameters:nil
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject){
              NSDictionary *result = (NSDictionary *)responseObject;
              NSInteger     status = [[result objectForKey:@"status"] integerValue];
              if (status == 1) {
                  NSLog(@"%@", [result objectForKey:@"results"]);
                  self.myProfile.avatorURL = [NSURL URLWithString:[[result objectForKey:@"results"] objectForKey:@"avator"]];
                  [Config updateProfile:self.myProfile];
                  [ProgressHUD showSuccess:@"更新资料成功" Interaction:YES];
              }
              else {
                  [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
              }
              
          }
          failure:^(NSURLSessionDataTask *task, NSError *error){
              [ProgressHUD showError:@"更新失败" Interaction:YES];
              NSLog(@"update avator error: %@", error);
              
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

//
//  UserCenterController.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/21.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "UserCenterController.h"
#import "eyemoreUser.h"
#import "UserCenterView.h"
#import "Config.h"
#import "SDWebImageManager.h"
#import "AFNetworking.h"
#import "eyemoreAPI.h"
#import "ProgressHUD.h"
#import "YJSegmentedControl.h"
#import "UserCenterView.h"
#import "DiscoverTableViewCell.h"
#import "DetailBlogController.h"
#import "UserListCell.h"
#import "JGActionSheet.h"
#import "ImageAlbumManager.h"
#import "JTSImageViewController.h"

static NSString *kNewsCellID = @"NewsCell";
static NSString *kFollowCellID = @"FollowersCell";
static NSString *kFanCellID = @"FansCell";

static CGFloat   kfixedPartHeight = 123.0;

@interface UserCenterController ()<YJSegmentedControlDelegate, DiscoverTableViewCellDelegate, JTSImageViewControllerInteractionsDelegate>

@property (strong, nonatomic) YJSegmentedControl *scrollSegment;
@property (strong, nonatomic) UserCenterView *myProfileView;
@property (strong, nonatomic) JGActionSheet *actionSheet;
@property (strong, nonatomic) NSMutableArray *followList;
@property (strong, nonatomic) NSMutableArray *ownerFollowList;
@property (strong, nonatomic) NSMutableArray *ownerFansList;
@property (strong, nonatomic) NSMutableArray *fanList;

@end

@implementation UserCenterController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.subviews.firstObject.alpha = 0;
    self.tableView.mj_header.alpha = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self layoutBlurBackground];
    [self setUpSegmentControl];
    //self.view.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1];
    [self.tableView registerNib:[UINib nibWithNibName:@"DiscoverTableViewCell" bundle:nil] forCellReuseIdentifier:kNewsCellID];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserListCell" bundle:nil] forCellReuseIdentifier:kFollowCellID];
    self.loadUid = self.myProfile.userID;
    [self refreshMyProfile];
    self.fanList = [NSMutableArray new];
    self.navigationController.navigationBar.subviews.firstObject.alpha = 0;
    
    self.ownerFollowList = [[Config myProfile].followerList mutableCopy];
    self.ownerFansList = [[Config myProfile].fansList mutableCopy];
    NSLog(@"my followlist: %@", self.ownerFollowList);
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.subviews.firstObject.alpha = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutBlurBackground
{
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height / 2)];
    backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    backgroundImageView.image = self.avatarImage;

    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = backgroundImageView.frame;
    effectView.alpha = 1.0;
    //[backgroundImageView addSubview:effectView];
    
    self.tableView.backgroundView = effectView;
    self.tableView.backgroundColor=[UIColor colorWithPatternImage:self.avatarImage];
}

- (void)setUpSegmentControl
{
    if (self.scrollSegment == nil) {
        NSArray * btnDataSource = @[@"照片 ", @"已关注", @"粉丝"];
        UIFont *titleFont ;//= [UIFont fontWithName:@".Helvetica Neue Interface" size:18.0f];
        //6p,6sp界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 414) {
            titleFont = [UIFont fontWithName:@".Helvetica Neue Interface" size:15.5];
        }
        //5,5s界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 320) {
            titleFont = [UIFont fontWithName:@".Helvetica Neue Interface" size:14.0];
        }
        //6,6s界面优化
        if ([[UIScreen mainScreen] bounds].size.width == 375) {
            titleFont = [UIFont fontWithName:@".Helvetica Neue Interface" size:14.0];
        }
        self.scrollSegment = [YJSegmentedControl segmentedControlFrame:CGRectMake(0, 148, self.view.bounds.size.width, 40)
                                                       titleDataSource:btnDataSource
                                                       backgroundColor:[UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:0]
                                                            titleColor:[UIColor grayColor]
                                                             titleFont:titleFont
                                                           selectColor:[UIColor redColor]
                                                       buttonDownColor:[UIColor redColor]
                                                              Delegate:self];
    }
    [self.view addSubview:self.scrollSegment];
}

- (BOOL)checkingFollowingButtonState
{
    for (NSDictionary *obj in self.ownerFollowList) {
        if ([[obj objectForKey:@"uid"] integerValue] == self.myProfile.userID) {
            return YES;
        }
    }
    return NO;
}

- (void)updateFollowingButton:(BOOL)hasFollowed
{
    if (hasFollowed) {
        [self.myProfileView.followButton setTitle:@"已关注" forState:UIControlStateNormal];
        [self.myProfileView.followButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
    }
    else {
        [self.myProfileView.followButton setTitle:@"关注" forState:UIControlStateNormal];
        [self.myProfileView.followButton setImage:nil forState:UIControlStateNormal];
    }
}


#pragma mark - YJSegmentedControl Delegate

- (void)segumentSelectionChange:(NSInteger)selection{
    
    if (selection == 0) {
        [self refreshAction];
    }
    if (selection == 1) {
        [self refreshFollowListAction];
    }
    if (selection == 2) {
        [self refreshFansListAction];
    }
}

#pragma mark - User Data Refreshing

- (void)refreshFansListAction
{
    [self fetchFansWithRefresh:YES];
}
- (void)refreshFollowListAction
{
    [self fetchFollowersWithrefresh:YES];
}

- (void)fetchFollowersWithrefresh:(BOOL)isRefresh
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_FOLLOWLIST]
      parameters:@{ @"uid": [NSString stringWithFormat:@"%ld", (long)self.myProfile.userID]}
        progress:nil
         success:^(NSURLSessionDataTask *task, id responseObject){
             [self.followList removeAllObjects];
             NSDictionary *result = (NSDictionary *)responseObject;
             NSInteger status = [[result objectForKey:@"status"] integerValue];
             NSArray *followList = [result valueForKey:@"results"];
             NSLog(@"%@", result);
             if (status == 1) {
                 if (followList != nil && followList.count > 0) {
                     self.followList = [followList mutableCopy];
                 }
                 //更新自己的本地已关注列表
                 if (self.myProfile.userID == [Config myProfile].userID) {
                     eyemoreUser *owner = [Config myProfile];
                     owner.followerList = self.followList;
                     [Config saveProfile:owner];
                 }
                 dispatch_async(dispatch_get_main_queue(), ^(){
                     [self.tableView reloadData];
                 });
             }
             else {
                 [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
             }
         }
         failure:^(NSURLSessionDataTask *task, NSError *error){
             [ProgressHUD showError:@"获取超时" Interaction:YES];
             NSLog(@"获取失败: %@", error);
         }];
}

- (void)fetchFansWithRefresh:(BOOL)isRefresh
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_FANSLIST]
      parameters:@{ @"uid": [NSString stringWithFormat:@"%ld", (long)self.myProfile.userID]}
        progress:nil
         success:^(NSURLSessionDataTask *task, id responseObject){
             [self.fanList removeAllObjects];
             NSDictionary *result = (NSDictionary *)responseObject;
             NSInteger status = [[result objectForKey:@"status"] integerValue];
             NSArray *fansList = [result valueForKey:@"results"];
             NSLog(@"%@", result);
             if (status == 1) {
                 if (fansList != nil && fansList.count > 0) {
                     self.fanList = [fansList mutableCopy];
                 }
                 //更新自己的本地粉丝列表
                 if (self.myProfile.userID == [Config myProfile].userID) {
                     eyemoreUser *owner = [Config myProfile];
                     owner.fansList = self.fanList;
                     [Config saveProfile:owner];
                 }
                 dispatch_async(dispatch_get_main_queue(), ^(){
                     [self.tableView reloadData];
                 });
             }
             else {
                 [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
             }
         }
         failure:^(NSURLSessionDataTask *task, NSError *error){
             [ProgressHUD showError:@"获取超时" Interaction:YES];
             NSLog(@"获取失败: %@", error);
         }];
}

- (void)refreshMyProfileView
{
    if (self.myProfileView == nil) {
        self.myProfileView = [UserCenterView instantiateFromNib];
    }
    [self.myProfileView changeStateToUserCenterWithName:self.myProfile.nickName
                                                  Image:self.avatarImage
                                             LeftString:nil
                                            RightString:nil];
    
    [self.myProfileView.followButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(followButtonTapped)]];
    [self updateFollowingButton:[self checkingFollowingButtonState]];
}

- (void)followButtonTapped
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_FOLLOW]
       parameters:@{@"fuid": [NSString stringWithFormat:@"%ld", (long)self.myProfile.userID]}
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject){
              NSDictionary *result = (NSDictionary *)responseObject;
              NSInteger status = [[result objectForKey:@"status"] integerValue];
              if (status == 1) {
                  NSLog(@"%@", [result objectForKey:@"results"]);
                  eyemoreUser *owner = [Config myProfile];
                  dispatch_async(dispatch_get_main_queue(), ^(){
                      if ([self.myProfileView.followButton.titleLabel.text isEqualToString:@"关注"]) {
                          [self updateFollowingButton:YES];
                          [self.ownerFollowList addObject: @{@"uid": @(self.myProfile.userID)}];
                      }
                      else {
                          
                          for (NSDictionary *obj in self.ownerFollowList) {
                              if ([[obj objectForKey:@"uid"] integerValue] == self.myProfile.userID) {
                                  [self.ownerFollowList removeObject:obj];
                                  [self updateFollowingButton:NO];
                                  break;
                              }
                          }
                      }
                      owner.followerList = [self.ownerFollowList copy];
                      [Config saveProfile:owner];
                  });
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

- (void)refreshMyProfile
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    if (self.myProfile.userID == [Config getOwnID]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
        [manager GET:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_FETCH_PROFILE]
          parameters:nil
            progress:nil
             success:^(NSURLSessionDataTask *task, id responseObject){
                 NSDictionary *result = (NSDictionary *)responseObject;
                 NSInteger status = [[result objectForKey:@"status"] integerValue];
                 if (status == 1) {
                     NSLog(@"%@", [result objectForKey:@"results"]);
                     self.myProfile = [[eyemoreUser alloc] initWithProfileDict:result];
                     [self refreshMyProfileView];
                     [self.tableView reloadData];
                     dispatch_async(dispatch_get_main_queue(), ^(){});
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
    if (self.myProfile.userID != [Config getOwnID]) {
        [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_USER_PROFILE]
          parameters:@{@"uid":[NSString stringWithFormat:@"%ld", (long)self.myProfile.userID]}
            progress:nil
             success:^(NSURLSessionDataTask *task, id responseObject){
                 NSDictionary *result = (NSDictionary *)responseObject;
                 NSInteger status = [[result objectForKey:@"status"] integerValue];
                 if (status == 1) {
                     NSLog(@"%@", [result objectForKey:@"results"]);
                     self.myProfile = [[eyemoreUser alloc] initWithProfileDict:result];
                     [self refreshMyProfileView];
                     [self.tableView reloadData];
                     dispatch_async(dispatch_get_main_queue(), ^(){});
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
}

- (NSString *)stringWithDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [formatter stringFromDate:date];
}
- (CGFloat)calculateHeightForCell:(DiscoverTableViewCell *)cell
{
    CGFloat flexiblePartHeight = 0;
    if (cell) {
        //UIFont *font = cell.imageTitleLabel.font;
        //CGSize stringSize = [cell.imageTitleLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil]];
        //[cell.imageTitleLabel setFrame:CGRectMake(0, 0, cell.imageTitleLabel.frame.size.width, stringSize.height)];
        //cell.imageTitleLabel.center = CGPointMake(cell.imageTitleLabel.center.x, cell.postImage.center.y + cell.postImage.image.size.height / 2 + cell.imageTitleLabel.frame.size.height / 2 + 8);
        //flexiblePartHeight = cell.postImage.image.size.height * self.view.frame.size.width / cell.postImage.image.size.width;
        //flexiblePartHeight = flexiblePartHeight + cell.imageTitleLabel.frame.size.height;
    }
    return kfixedPartHeight + 1080 * self.view.frame.size.width / 1920 + flexiblePartHeight;
    
    
}
#pragma mark - Scroll View Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat alaph = (scrollView.contentOffset.y - 128.0  + 64) / 64.0;
    self.navigationController.navigationBar.subviews.firstObject.alpha = alaph;
    self.scrollSegment.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:(alaph)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    self.tableView.mj_header.alpha = 0;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger selectedUid = 0;
    if (self.scrollSegment.selectSeugment == 1) {
        selectedUid = [[self.followList[indexPath.row] objectForKey:@"uid"] integerValue];
    }
    if (self.scrollSegment.selectSeugment == 2) {
        selectedUid = [[self.fanList[indexPath.row] objectForKey:@"uid"] integerValue];
    }
    if (self.scrollSegment.selectSeugment) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserCenterController" bundle:nil];
        UserCenterController *controller = [storyboard instantiateViewControllerWithIdentifier:@"UserCenterController"];
        controller.myProfile = [[eyemoreUser alloc] init];
        controller.myProfile.userID = selectedUid;
        UserListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        controller.avatarImage = cell.avatar.image;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 150.0;
    }
    else {
        if (self.scrollSegment.selectSeugment == 0) {
            return kfixedPartHeight + 181;
        }
        else {
            return 70;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 150.0;
    }
    else {
        if (self.scrollSegment.selectSeugment == 0) {
            DiscoverTableViewCell *cell = (DiscoverTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            return [self calculateHeightForCell:cell];
        }
        else {
            return 70;
        }
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else {
        if (self.scrollSegment.selectSeugment == 0) {
            return self.objects.count;
        }
        else if (self.scrollSegment.selectSeugment == 1){
            if (self.followList.count > 0) {
                return self.followList.count;
            }
            else{
                return 1;
            }
        }
        else {
            if (self.fanList.count > 0) {
                return self.fanList.count;
            }
            else{
                return 1;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"headerCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //cell.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1];
        cell.backgroundColor = [UIColor clearColor];
        self.myProfileView.frame = CGRectMake(0, 0, cell.frame.size.width - 14, cell.frame.size.height);
        [cell addSubview:self.myProfileView];
        self.myProfileView.center = CGPointMake(cell.frame.size.width / 2, cell.frame.size.height / 2);
        return cell;
    }
    else {
        if (self.scrollSegment.selectSeugment == 0) {
            DiscoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNewsCellID];
            
            if (cell == nil) {
                cell = [DiscoverTableViewCell instantiateFromNib];
            }
            NSArray  *likes = [self.objects[indexPath.row] objectForKey:@"likes"];
            NSArray  *images = [self.objects[indexPath.row] objectForKey:@"images"];
            NSArray  *comments = [self.objects[indexPath.row] objectForKey:@"comments"];
            NSString *dateString = [self.objects[indexPath.row] objectForKey:@"create_at"];
            NSDate   *postedDate = [NSDate dateWithTimeIntervalSince1970:[dateString integerValue]];
            
            cell.blogID = [[self.objects[indexPath.row] objectForKey:@"id"] integerValue];
            cell.imageTitleLabel.text  = [self.objects[indexPath.row] objectForKey:@"title"];
            cell.likeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)likes.count];
            cell.commentCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)comments.count];
            cell.postedDateLabel.text = [self stringWithDate:postedDate];
            cell.userName.text = [self.objects[indexPath.row] objectForKey:@"nickname"];
            [cell.postImage setImage:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[images firstObject]]
                                                            options:0
                                                           progress:nil
                                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
                                                              [cell.postImage setImage:image];
                                                              //[self reloadVisibleCellsFortableView:tableView];
                                                              
                                                          }
             ];
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[self.objects[indexPath.row] objectForKey:@"avator"]]
                                                            options:0
                                                           progress:nil
                                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
                                                              [cell.userAvatar setImage:image];
                                                              //[self reloadVisibleCellsFortableView:tableView];
                                                              
                                                          }
             ];
            cell.delegate = self;
            return cell;
        }
        else if (self.scrollSegment.selectSeugment == 1){
            if (self.followList.count > 0) {
                UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:kFollowCellID];
                if (cell == nil) {
                    cell = [UserListCell instantiateFromNib];
                }
                cell.userName.text = [self.followList[indexPath.row] objectForKey:@"nickname"];
                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[self.followList[indexPath.row] objectForKey:@"avator"]]
                                                                options:0
                                                               progress:nil
                                                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
                                                                  [cell.avatar setImage:image];
                                                                  
                                                              }
                 ];
                return cell;

            }
            else {
                
                UITableViewCell *cell = [[UITableViewCell alloc] init];
                cell.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1];
                cell.textLabel.text = NSLocalizedString(@"No Following", nil);
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.textColor = [UIColor darkGrayColor];
                return cell;
            }
        }
        
        else{
            if (self.fanList.count > 0) {
                UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:kFanCellID];
                if (cell == nil) {
                    cell = [UserListCell instantiateFromNib];
                }
                cell.userName.text = [self.fanList[indexPath.row] objectForKey:@"nickname"];
                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[self.fanList[indexPath.row] objectForKey:@"avator"]]
                                                                options:0
                                                               progress:nil
                                                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
                                                                  [cell.avatar setImage:image];
                                                                  
                                                              }
                 ];
                return cell;
            }
            else {
                
                UITableViewCell *cell = [[UITableViewCell alloc] init];
                cell.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1];
                cell.textLabel.text = NSLocalizedString(@"No Followers", nil);
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.textColor = [UIColor darkGrayColor];
                return cell;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 40;
    }
    else return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        [self setUpSegmentControl];
        return self.scrollSegment;
    }
    else return nil;
}

#pragma mark - Discover Table View Cell Delegate

- (void)didTappedCommentButtonOnCell:(DiscoverTableViewCell *)cell
{
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    DetailBlogController *controller = [[DetailBlogController alloc] init];
    controller.detailObject = self.objects[index.row];
    controller.objectIndex = index.row;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)didTappedLikeButtonOnCell:(DiscoverTableViewCell *)cell
{
    NSLog(@"tapped cell.blogid :%ld", (long)cell.blogID);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_LIKE]
       parameters:@{@"bid": [NSString stringWithFormat:@"%ld", (long)cell.blogID]}
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject){
              
              NSDictionary *result = (NSDictionary *)responseObject;
              NSLog(@"like result: %@", result);
              NSInteger status = [[result objectForKey:@"status"] integerValue];
              if (status == 1) {
                  cell.likeLabel.text = [NSString stringWithFormat:@"%ld", [cell.likeLabel.text integerValue] + 1];
              }
              else {
                  [ProgressHUD showSuccess:NSLocalizedString(@"Liked", nil) Interaction:YES];
              }
          }
          failure:^(NSURLSessionDataTask *task, NSError *error){
              [ProgressHUD showError:NSLocalizedString(@"Like Error", nil) Interaction:YES];
              NSLog(@"点赞失败: %@", error);
          }];
}

- (void)didActionAvatarViewOnCell:(DiscoverTableViewCell *)cell
{
    NSLog(@"tapped avatar");
}

- (void)didActionPostImageOnCell:(DiscoverTableViewCell *)cell
{
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
#if TRY_AN_ANIMATED_GIF == 1
    imageInfo.imageURL = [NSURL URLWithString:@"http://media.giphy.com/media/O3QpFiN97YjJu/giphy.gif"];
#else
    imageInfo.image = cell.postImage.image;
#endif
    imageInfo.referenceRect = cell.postImage.frame;
    imageInfo.referenceView = cell.postImage.superview;
    imageInfo.referenceContentMode = cell.postImage.contentMode;
    imageInfo.referenceCornerRadius = cell.postImage.layer.cornerRadius;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    imageViewer.interactionsDelegate = self;
}

#pragma mark - JTSImageViewControllerInteractionsDelegate

- (void)imageViewerDidLongPress:(JTSImageViewController *)imageViewer atRect:(CGRect)rect
{
    [self presentActionsForItem:imageViewer.imageInfo.image OnController:imageViewer];
}

- (void)presentActionsForItem:(UIImage *)image OnController:(JTSImageViewController *)controller
{
    if (self.actionSheet == nil) {
        JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:@"" message:@"" buttonTitles:@[@"保存"] buttonStyle:JGActionSheetButtonStyleCustomer];
        JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"取消"] buttonStyle:JGActionSheetButtonStyleCustomer];
        
        NSArray *sections = @[section1, cancelSection];
        self.actionSheet = [JGActionSheet actionSheetWithSections:sections];
    }
    
    ImageAlbumManager *albumManager = [ImageAlbumManager sharedImageAlbumManager];
    __weak JGActionSheet *weakSelfAction = self.actionSheet;
    
    [self.actionSheet setOutsidePressBlock:^(JGActionSheet *sheet){
        [weakSelfAction dismissAnimated:YES];
    }];
    [self.actionSheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *sheetIndexPath) {
        if (sheetIndexPath.section == 0 && sheetIndexPath.row == 0) {
            
            //dispatch_async(dispatch_get_global_queue(0, 0), ^(){
            [albumManager saveToAlbumWithMetadata:nil
                                        imageData:UIImagePNGRepresentation(image)
                                  customAlbumName:@"eyemore Album"
                                  completionBlock:^{}
                                     failureBlock:^(NSError *error)
             {
                 //处理添加失败的方法显示alert让它回到主线程执行，不然那个框框死活不肯弹出来
                 dispatch_async(dispatch_get_main_queue(), ^{
                     //添加失败一般是由用户不允许应用访问相册造成的，这边可以取出这种情况加以判断一下
                     if([error.localizedDescription rangeOfString:@"User denied access"].location != NSNotFound ||[error.localizedDescription rangeOfString:@"用户拒绝访问"].location!=NSNotFound){
                         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:error.localizedDescription
                                                                      message:error.localizedFailureReason
                                                                     delegate:nil
                                                            cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                            otherButtonTitles: nil];
                         [alert show];
                     }
                 });
             }];
        }
        [weakSelfAction dismissAnimated:YES];
    }];
    if (!self.actionSheet.isVisible) {
        [self.actionSheet showInView:controller.view animated:YES];
    }
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

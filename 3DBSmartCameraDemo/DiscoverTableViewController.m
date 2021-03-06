//
//  DiscoverTableViewController.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/17.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "DiscoverTableViewController.h"
#import "DiscoverTableViewCell.h"
#import "SDWebImageManager.h"
#import "ProgressHUD.h"
#import "DetailBlogController.h"
#import "UserCenterController.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import "JGActionSheet.h"
#import "ImageAlbumManager.h"
#import "MeTableViewController.h"
#import "SocialRequestAssistant.h"
#import "ActionSheetHelper.h"
#import "BLImageEditor.h"
#import "UserSettingConfig.h"

static NSString *kNewsCellID = @"NewsCell";
static CGFloat   kfixedPartHeight = 123.0;

@interface DiscoverTableViewController ()<DiscoverTableViewCellDelegate , JTSImageViewControllerInteractionsDelegate>
@property (nonatomic, strong) JGActionSheet *actionSheet;
@end

@implementation DiscoverTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // setup background color
    self.view.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAction) name:eyemoreDeleteBlogNoti object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"DiscoverTableViewCell" bundle:nil] forCellReuseIdentifier:kNewsCellID];
    self.loadUid = -1;
    
    [self instantiateRightBarItem];
}

- (void)instantiateRightBarItem
{
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"me_active.png"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarItemTapped)]];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor redColor];
}

- (void)rightBarItemTapped
{
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MeTableViewController *controller = [board instantiateViewControllerWithIdentifier:@"MeTableViewController"];
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)sharingAction
{

}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kfixedPartHeight + 181;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DiscoverTableViewCell *cell = (DiscoverTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    return [self calculateHeightForCell:cell];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    cell.userID = [[self.objects[indexPath.row] objectForKey:@"uid"] integerValue];
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
                                                      cell.imageURLString = [images firstObject];
                                                      //[self reloadVisibleCellsFortableView:tableView];
                                                      if (cell.postImage.image.size.width < cell.postImage.image.size.height) {
                                                          cell.postImage.contentMode = UIViewContentModeScaleAspectFill;
                                                          cell.postImage.layer.masksToBounds = YES;
                                                      }
                                                      
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

//- (void)reloadVisibleCellsFortableView:(UITableView *)tableView
//{
//    NSArray *cells = [tableView visibleCells];
//    NSMutableArray *array = [NSMutableArray new];
//    for (DiscoverTableViewCell *cell in cells) {
//        if (cell.postImage.image.size.width < cell.postImage.image.size.height) {
//            [array addObject:[tableView indexPathForCell:cell]];
//        }
//        //[array addObject:[tableView indexPathForCell:cell]];
//    }
//    NSLog(@"%@", array);
//    [tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
//}

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
        if (cell.postImage.image.size.width < cell.postImage.image.size.height) {
            return kfixedPartHeight + 1920 * (self.view.frame.size.width) / 1080 - 120;
        }
    }
    return kfixedPartHeight + 1080 * self.view.frame.size.width / 1920 + flexiblePartHeight;
    

}

- (NSString *)stringWithDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [formatter stringFromDate:date];
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
    [SocialRequestAssistant requestLikeBlogWithID:cell.blogID
                                          success:^(NSURLSessionDataTask *task, id responseObject){
                                              cell.likeLabel.text = [NSString stringWithFormat:@"%ld", [cell.likeLabel.text integerValue] + 1];}
                                          failure:nil];
}

- (void)didTappedMoreButtonOnCell:(DiscoverTableViewCell *)cell
{
//    NSArray *array = [[NSArray alloc] init];
//    if (cell.userID == [Config getOwnID]) {
//        array = @[NSLocalizedString(@"Share with Wechat friends", nil),
//                  NSLocalizedString(@"Share with Wechat time line", nil),
//                  NSLocalizedString(@"Share with QQ friends", nil),
//                  NSLocalizedString(@"Delete", nil)];
//    }
//    else{
//        array = @[NSLocalizedString(@"Share with Wechat friends", nil),
//                  NSLocalizedString(@"Share with Wechat time line", nil),
//                  NSLocalizedString(@"Share with QQ friends", nil),];
//    }
//    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:@"" message:@"" buttonTitles:array buttonStyle:JGActionSheetButtonStyleCustomer];
//    NSLog(@"array section: %@", array);
//    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"取消"] buttonStyle:JGActionSheetButtonStyleCustomer];
//    NSArray *sections = @[section1, cancelSection];
//    JGActionSheet *actionSheet = [JGActionSheet actionSheetWithSections:sections];
//    
//    __weak JGActionSheet *weakSelfAction = actionSheet;
//    [actionSheet setOutsidePressBlock:^(JGActionSheet *sheet){
//        [weakSelfAction dismissAnimated:YES];
//    }];
//    [actionSheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *sheetIndexPath) {
//        if (sheetIndexPath.section == 0 && sheetIndexPath.row == 0) {
//            NSLog(@"sharing with wechat friend tapped");
//            [SocialRequestAssistant shareImage:cell.postImage.image onPlatForm:SSDKPlatformSubTypeWechatSession];
//        }
//        else if (sheetIndexPath.section == 0 && sheetIndexPath.row == 1) {
//            [SocialRequestAssistant shareImage:cell.postImage.image onPlatForm:SSDKPlatformSubTypeWechatTimeline];
//        }
//        
//        else if (sheetIndexPath.section == 0 && sheetIndexPath.row == 2) {
//            [SocialRequestAssistant shareImage:cell.postImage.image onPlatForm:SSDKPlatformSubTypeQQFriend];
//        }
//        
//        if (sheetIndexPath.section == 0 && sheetIndexPath.row == 3) {
//            [SocialRequestAssistant requestDeleteBlogWithID:cell.blogID
//                                                    success:^(NSURLSessionDataTask *task, id responseObject){
//                                                        [self.navigationController popViewControllerAnimated:YES];
//                                                        [[NSNotificationCenter defaultCenter] postNotificationName:eyemoreDeleteBlogNoti object:nil];
//                                                    }
//                                                    failure:nil];
//        }
//        [weakSelfAction dismissAnimated:YES];
//    }];
//    if (!actionSheet.isVisible) {
//        [actionSheet showInView:self.tabBarController.view animated:YES];
//    }
    [ActionSheetHelper actionShareSheetWithUserID:cell.userID blogID:cell.blogID image:cell.postImage.image inView:self.tabBarController.view];
}

- (void)didActionAvatarViewOnCell:(DiscoverTableViewCell *)cell
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserCenterController" bundle:nil];
    UserCenterController *controller = [storyboard instantiateViewControllerWithIdentifier:@"UserCenterController"];
    controller.myProfile = [[eyemoreUser alloc] init];
    controller.myProfile.userID = cell.userID;
    controller.avatarImage = cell.userAvatar.image;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didActionPostImageOnCell:(DiscoverTableViewCell *)cell
{
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];

    imageInfo.imageURL = [NSURL URLWithString:cell.imageURLString];
    imageInfo.image = cell.postImage.image;
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
    [self presentActionsForItem:imageViewer.imageInfo.imageURL OnController:imageViewer];
}

- (void)presentActionsForItem:(NSURL *)imageURL OnController:(JTSImageViewController *)controller
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
            
            [ProgressHUD show:NSLocalizedString(@"Saving", nil) Interaction:NO];
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:imageURL
                                                                  options:SDWebImageDownloaderLowPriority
                                                                 progress:nil
                                                                completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished){
                                                                    if (error) {
                                                                        [ProgressHUD showError:NSLocalizedString(@"Save Failed", nil)];
                                                                    }
                                                                    
                                                                    if ([UserSettingConfig waterMarkIsEnabled]) {
                                                                        
                                                                        UIImage *markImage = [BLImageEditor waterMarkImageWithBackgroundImage:image
                                                                                                                                    waterMark:[UIImage imageNamed:@"waterMark.png"]
                                                                                                                                 markPosition:PositionRightBottom];
                                                                        data = [BLImageEditor dataFromImage:markImage metadata:nil mimetype:@"image/jpeg"];
                                                                    }
                                                                    
                                                                    [albumManager saveToAlbumWithMetadata:nil
                                                                                                imageData:data
                                                                                          customAlbumName:@"eyemore Album"
                                                                                          completionBlock:^{
                                                                                              dispatch_async(dispatch_get_main_queue(), ^(){
                                                                                                  [ProgressHUD showSuccess:NSLocalizedString(@"Saved", nil)];
                                                                                              });
                                                                                          }
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
                                                                 }];
                    }
        [weakSelfAction dismissAnimated:YES];
    }];
    if (!self.actionSheet.isVisible) {
        [self.actionSheet showInView:controller.view animated:YES];
    }
}

@end

//
//  DetailBlogController.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/18.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "DetailBlogController.h"
#import "DiscoverTableViewCell.h"
#import "SDWebImageManager.h"
#import "ProgressHUD.h"
#import "CommentTableCell.h"
#import "BLEdittingView.h"
#import "AFNetworking.h"
#import "JGActionSheet.h"
#import "SocialRequestAssistant.h"
#import "ActionSheetHelper.h"

static NSString *kNewsCellID = @"NewsCell";
static NSString *kCommentCellID = @"CommentCell";
static CGFloat   kfixedPartHeight = 123.0;

@interface DetailBlogController ()<DiscoverTableViewCellDelegate, UITextViewDelegate, BLEdittingViewDeledate, UITableViewDelegate, UITableViewDataSource, CommentTableCellDelegare>

@property (nonatomic, strong) NSMutableArray *blogComments;

@property (nonatomic, strong) UITextView     *textView;
@property (nonatomic, strong) UIView         *textContainView;
@property (nonatomic, strong) BLEdittingView *edittingView;
@property (nonatomic, strong) UITableView    *tableView;
@property (nonatomic, assign) NSInteger       toUid;
@property (nonatomic, strong) NSString       *toNickname;
@end

@implementation DetailBlogController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // setup background color
    self.view.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetCenterButtonHiden" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44)];
    self.tableView.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight  = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"DiscoverTableViewCell" bundle:nil] forCellReuseIdentifier:kNewsCellID];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTableCell" bundle:nil] forCellReuseIdentifier:kCommentCellID];
    self.tableView.userInteractionEnabled = YES;
    [self.view addSubview:self.tableView];
    self.blogComments = [[self.detailObject objectForKey:@"comments"] mutableCopy];
    //[self setUpTextContainView];
    [self setUpEdittinView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetCenterButtonShow" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetCenterButtonShow" object:nil];
}

- (void)setUpEdittinView
{
    self.edittingView = [[BLEdittingView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44) actionTitle:NSLocalizedString(@"Send", nil) inSuperView:self.view];
    self.edittingView.delegate = self;
    [self.view addSubview:self.edittingView];
    //初始化回复他人uid
    self.toUid = 0;
}

- (float)calculationHeightForComment:(NSString *)comment
{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:13];
    label.text = comment;
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = [label sizeThatFits:CGSizeMake(self.view.frame.size.width - 8 * 3 - 44 , MAXFLOAT)];
    return size.height;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        self.toUid = [[self.blogComments[indexPath.row] objectForKey:@"uid"] integerValue];
        [self.edittingView becomeEditting];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kfixedPartHeight + 181;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DiscoverTableViewCell *cell = (DiscoverTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        return [self calculateHeightForCell:cell];
    }
    else{
        if (self.blogComments != nil && self.blogComments.count != 0) {
            return 55 + [self calculationHeightForComment:[self.blogComments[indexPath.row] objectForKey:@"comment"]];
            //return 75;
        }
        else return 200;
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
        if (self.blogComments != nil && self.blogComments.count != 0) {
            return self.blogComments.count;
        }
        else return 1;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        DiscoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNewsCellID];
        
        if (cell == nil) {
            cell = [DiscoverTableViewCell instantiateFromNib];
        }
        NSArray  *likes      = [self.detailObject objectForKey:@"likes"];
        NSArray  *images     = [self.detailObject objectForKey:@"images"];
        NSString *dateString = [self.detailObject objectForKey:@"create_at"];
        NSDate   *postedDate = [NSDate dateWithTimeIntervalSince1970:[dateString integerValue]];
        
        cell.userID = [[self.detailObject objectForKey:@"uid"] integerValue];
        cell.blogID = [[self.detailObject objectForKey:@"id"] integerValue];
        cell.imageTitleLabel.text = [self.detailObject objectForKey:@"title"];
        cell.likeLabel.text       = [NSString stringWithFormat:@"%lu", (unsigned long)likes.count];
        cell.postedDateLabel.text = [self stringWithDate:postedDate];
        cell.userName.text        = [self.detailObject objectForKey:@"nickname"];
        [cell.postImage setImage:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[images firstObject]]
                                                        options:0
                                                       progress:nil
                                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL){
                                                          [cell.postImage setImage:image];
                                                          //[self reloadVisibleCellsFortableView:tableView];
                                                          if (cell.postImage.image.size.width < cell.postImage.image.size.height) {
                                                              cell.postImage.contentMode = UIViewContentModeScaleAspectFill;
                                                              cell.postImage.layer.masksToBounds = YES;
                                                          }
                                                      }
         ];
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[self.detailObject objectForKey:@"avator"]]
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
    else {
        if (self.blogComments.count != 0) {
            CommentTableCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommentCellID];
            if (cell == nil) {
                cell = [CommentTableCell instantiateFromNib];
            }
            NSString *postedName = [self.blogComments[indexPath.row] objectForKey:@"nickname"];
            NSString *toUserName = [self.blogComments[indexPath.row] objectForKey:@"tnickname"];
            NSString *dateString = [self.blogComments[indexPath.row] objectForKey:@"create_at"];
            NSString *content    = [self.blogComments[indexPath.row] objectForKey:@"comment"];
            NSInteger userid     = [[self.blogComments[indexPath.row] objectForKey:@"uid"] integerValue];
            NSInteger toUserid   = [[self.blogComments[indexPath.row] objectForKey:@"tuid"] integerValue];
            NSDate   *postedDate = [NSDate dateWithTimeIntervalSince1970:[dateString integerValue]];
            
            
            if (toUserid == 0) {
                cell.userNameLabel.text = postedName;
            }
            else {
                cell.userNameLabel.text = [NSString stringWithFormat:@"%@ %@ %@", postedName, NSLocalizedString(@"reply", nil), toUserName];
            }
            
            cell.commentDateLabel.text = [self stringWithDate:postedDate];
            cell.CommentLabel.text = content;
            cell.commentUserID = userid;
            
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[self.blogComments[indexPath.row] objectForKey:@"avator"]]
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
        else {
            UITableViewCell *cell        = [[UITableViewCell alloc] init];
            cell.backgroundColor         = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1];
            cell.textLabel.text          = NSLocalizedString(@"Please Comment", nil);
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor     = [UIColor darkGrayColor];
            return cell;
        }
    }
}

#pragma mark - Table View Section Configuration

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 35;
    }
    else return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
        header.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:24/255.0 alpha:1];
        UILabel *label1  = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 35)];
        label1.textColor = [UIColor darkGrayColor];
        label1.font      = [UIFont systemFontOfSize:15.0];
        label1.text      = NSLocalizedString(@"Comments", nil);
        [header addSubview:label1];
        return header;
    }
    else return nil;
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

- (NSString *)stringWithDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [formatter stringFromDate:date];
}

#pragma mark - Comment table cell delegate

- (void)didSelectCommentTableCell:(CommentTableCell *)cell
{
    self.toUid = cell.commentUserID;
    NSArray *arry = [cell.userNameLabel.text componentsSeparatedByString:[NSString stringWithFormat:@" %@ ", NSLocalizedString(@"reply", nil)]];
    self.toNickname = arry[0];
    self.edittingView.placeHolder.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"reply", nil), self.toNickname];
    [self.edittingView becomeEditting];
}

#pragma mark - Discover Table View Cell Delegate

- (void)didTappedCommentButtonOnCell:(DiscoverTableViewCell *)cell
{
    [self.edittingView becomeEditting];
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
    NSArray *array = [[NSArray alloc] init];
    if (cell.userID == [Config getOwnID]) {
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
    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"取消"] buttonStyle:JGActionSheetButtonStyleCustomer];
    NSArray *sections = @[section1, cancelSection];
    JGActionSheet *actionSheet = [JGActionSheet actionSheetWithSections:sections];
    
    __weak JGActionSheet *weakSelfAction = actionSheet;
    [actionSheet setOutsidePressBlock:^(JGActionSheet *sheet){
        [weakSelfAction dismissAnimated:YES];
    }];
    [actionSheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *sheetIndexPath) {
        if (sheetIndexPath.section == 0 && sheetIndexPath.row == 0) {
            NSLog(@"sharing with wechat friend tapped");
            [SocialRequestAssistant shareImage:cell.postImage.image onPlatForm:SSDKPlatformSubTypeWechatSession];
        }
        else if (sheetIndexPath.section == 0 && sheetIndexPath.row == 1) {
            [SocialRequestAssistant shareImage:cell.postImage.image onPlatForm:SSDKPlatformSubTypeWechatTimeline];
        }
        
        else if (sheetIndexPath.section == 0 && sheetIndexPath.row == 2) {
            [SocialRequestAssistant shareImage:cell.postImage.image onPlatForm:SSDKPlatformSubTypeQQFriend];
        }
        
        if (sheetIndexPath.section == 0 && sheetIndexPath.row == 3) {
            [SocialRequestAssistant requestDeleteBlogWithID:cell.blogID
                                                    success:^(NSURLSessionDataTask *task, id responseObject){
                                                        [self.navigationController popViewControllerAnimated:YES];
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:eyemoreDeleteBlogNoti object:nil];
                                                    }
                                                    failure:nil];
        }
        [weakSelfAction dismissAnimated:YES];
    }];
    if (!actionSheet.isVisible) {
        [actionSheet showInView:self.view animated:YES];
    }
}
- (void)didActionAvatarViewOnCell:(DiscoverTableViewCell *)cell
{
}

- (void)didActionPostImageOnCell:(DiscoverTableViewCell *)cell
{
}

#pragma mark - BL Edditing View Delegate

- (void)BLEdittingView:(BLEdittingView *)edittingView didActionForTextContent:(NSString *)content
{
    [SocialRequestAssistant requestCommentWithBlogID:[self.detailObject objectForKey:@"id"]
                                             content:content
                                            toUserID:self.toUid
                                             success:^(NSURLSessionDataTask *task, id responseObject){
                                                 
                                                 [self.edittingView resetPlaceHolder];
                                                 NSString *name = [Config getOwnUserName];
                                                 NSString *date = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
                                                 if (self.toUid == 0) {
                                                     [self.blogComments insertObject:@{@"nickname":name,
                                                                                       @"create_at":date,
                                                                                       @"comment":content}
                                                                             atIndex:0];
                                                 }
                                                 else {
                                                     [self.blogComments insertObject:@{@"nickname":name,
                                                                                       @"create_at":date,
                                                                                       @"comment":content,
                                                                                       @"tuid": [NSString stringWithFormat:@"%ld", self.toUid],
                                                                                       @"tnickname":self.toNickname}
                                                                             atIndex:0];
                                                 }
                                                 if (self.blogComments.count == 1) {
                                                     [self.tableView reloadData];
                                                 }
                                                 else [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationRight];
                                             }
                                             failure:^(NSURLSessionDataTask *task, NSError *error){}];


}

- (void)BLEdittingView:(BLEdittingView *)edittingView didHideKeyBoardWithContent:(NSString *)content
{
    self.toUid = 0;
}

@end

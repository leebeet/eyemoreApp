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

static NSString *kNewsCellID = @"NewsCell";
static NSString *kCommentCellID = @"CommentCell";
static CGFloat   kfixedPartHeight = 123.0;

@interface DetailBlogController ()<DiscoverTableViewCellDelegate, UITextViewDelegate, BLEdittingViewDeledate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *blogComments;

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *textContainView;
@property (nonatomic, strong) BLEdittingView *edittingView;
@property (nonatomic, strong) UITableView *tableView;
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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"DiscoverTableViewCell" bundle:nil] forCellReuseIdentifier:kNewsCellID];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTableCell" bundle:nil] forCellReuseIdentifier:kCommentCellID];
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
    self.edittingView = [[BLEdittingView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44) actionTitle:@"发送" inSuperView:self.view];
    self.edittingView.delegate = self;
    [self.view addSubview:self.edittingView];
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
        NSArray  *likes = [self.detailObject objectForKey:@"likes"];
        NSArray  *images = [self.detailObject objectForKey:@"images"];
        NSString *dateString = [self.detailObject objectForKey:@"create_at"];
        NSDate   *postedDate = [NSDate dateWithTimeIntervalSince1970:[dateString integerValue]];
        
        cell.blogID = [[self.detailObject objectForKey:@"id"] integerValue];
        cell.imageTitleLabel.text  = [self.detailObject objectForKey:@"title"];
        cell.likeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)likes.count];
        cell.postedDateLabel.text = [self stringWithDate:postedDate];
        cell.userName.text = [self.detailObject objectForKey:@"nickname"];
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
            NSString *dateString = [self.blogComments[indexPath.row] objectForKey:@"create_at"];
            NSDate   *postedDate = [NSDate dateWithTimeIntervalSince1970:[dateString integerValue]];
            NSString *content    = [self.blogComments[indexPath.row] objectForKey:@"comment"];
            
            cell.userNameLabel.text = postedName;
            cell.commentDateLabel.text = [self stringWithDate:postedDate];
            cell.CommentLabel.text = content;
            
            return cell;
        }
        else {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            cell.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1];
            cell.textLabel.text = @"快来发表你的评论吧";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor darkGrayColor];
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
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 35)];
        label1.textColor = [UIColor darkGrayColor];
        label1.font = [UIFont systemFontOfSize:15.0];
        label1.text = @"评论";
        [header addSubview:label1];
        return header;
    }
    else return nil;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 1) {
//        return @"评论";
//    }
//    else return nil;
//}


//- (void)reloadVisibleCellsFortableView:(UITableView *)tableView
//{
//    NSArray *cells = [tableView visibleCells];
//    NSMutableArray *array = [NSMutableArray new];
//    for (DiscoverTableViewCell *cell in cells) {
//        [array addObject:[tableView indexPathForCell:cell]];
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
    [self.edittingView becomeEditting];
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
                  [ProgressHUD showSuccess:@"已赞过" Interaction:YES];
              }
          }
          failure:^(NSURLSessionDataTask *task, NSError *error){
              [ProgressHUD showError:@"点赞失败" Interaction:YES];
              NSLog(@"点赞失败: %@", error);
          }];
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
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager POST:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_COMMENT]
       parameters:@{@"bid": [self.detailObject objectForKey:@"id"], @"comment": content}
         progress:nil
          success:^(NSURLSessionDataTask *task, id responseObject){
              
              NSDictionary *result = (NSDictionary *)responseObject;
              NSLog(@"like result: %@", result);
              NSInteger status = [[result objectForKey:@"status"] integerValue];
              if (status == 1) {
                  [ProgressHUD showSuccess:@"评论成功" Interaction:YES];
                  [self.edittingView resetPlaceHolder];
                  NSString *name = [Config getOwnUserName];
                  NSString *date = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
                  [self.blogComments insertObject:@{@"nickname":name, @"create_at":date, @"comment":content} atIndex:0];
                  if (self.blogComments.count == 1) {
                      [self.tableView reloadData];
                  }
                  else [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationRight];
              }
              else {
                  [ProgressHUD showSuccess:@"评论响应出错" Interaction:YES];
              }
          }
          failure:^(NSURLSessionDataTask *task, NSError *error){
              [ProgressHUD showError:@"评论失败" Interaction:YES];
              NSLog(@"评论失败: %@", error);
          }];
    
}



@end

//
//  RootObjsController.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/3/24.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "RootObjsController.h"
#import "ProgressHUD.h"
#import "LogViewController.h"

@interface RootObjsController ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSUserDefaults       *userDefaults;
@property (nonatomic, strong) NSDate               *lastRefreshTime;

@property (assign, nonatomic) NSInteger            totalPage;

@end

@implementation RootObjsController

- (id)init
{
    self = [super init];
    if (self) {
        _objects = [NSMutableArray new];
        _page = 1;
        _needAutoRefresh = YES;
        _loadUid = -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.mj_header = ({
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshAction)];
        //header.lastUpdatedTimeLabel.hidden = YES;
        //header.stateLabel.hidden = YES;
        header.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        header;
    });
    
    _lastCell = [[DiscoverLoadMoreView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    [_lastCell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fetchMore)]];
    self.tableView.tableFooterView = _lastCell;
    
    _label = [UILabel new];
    _label.numberOfLines = 0;
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    _label.font = [UIFont boldSystemFontOfSize:14];
    _lastCell.textLabel.textColor = [UIColor darkGrayColor];
    
    _objects = [NSMutableArray new];
    _page = 0;
    _needAutoRefresh = YES;
    
    /*** 自动刷新 ***/
//    if (_needAutoRefresh) {
//        _userDefaults = [NSUserDefaults standardUserDefaults];
//        _lastRefreshTime = [_userDefaults objectForKey:_kLastRefreshTime];
//        
//        if (!_lastRefreshTime) {
//            _lastRefreshTime = [NSDate date];
//            [_userDefaults setObject:_lastRefreshTime forKey:_kLastRefreshTime];
//        }
//    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView.mj_header beginRefreshing];
    //[self fetchObjectsOnPage:1 refresh:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 刷新

- (void)refreshAction
{
    [self refresh];
}

- (void)refresh
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self fetchObjectsOnPage:1 refresh:YES];
    });
}

#pragma mark - 上拉加载更多

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height - 150)) {
        [self fetchMore];
    }
}

- (void)fetchMore
{
    if (!_lastCell.shouldResponseToTouch) {return;}
    _page++;
    if (self.totalPage >= _page) {
        _lastCell.status = LastCellStatusLoading;
        //_manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        [self fetchObjectsOnPage:_page refresh:NO];
    }
    else {
        _lastCell.status = LastCellStatusFinished;
    }
}

#pragma mark - 请求数据

- (void)fetchObjectsOnPage:(NSUInteger)page refresh:(BOOL)isRefresh
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Config myAccessToken]] forHTTPHeaderField:@"Authorization"];
    [manager GET:[NSString stringWithFormat:@"%@%@", eyemoreAPI_HTTP_PREFIX, eyemoreAPI_ACCOUNT_BLOGS]
      parameters:@{@"page": [NSString stringWithFormat:@"%lu", (unsigned long)page], @"sort":@"new", @"uid": [NSString stringWithFormat:@"%ld", (long)_loadUid]}
        progress:nil
         success:^(NSURLSessionDataTask *task, id responseObject){
             
             if (isRefresh) {
                 _page = 1;
                 [_objects removeAllObjects];
                 [self.tableView.mj_header endRefreshing];
             }
             NSDictionary *result = (NSDictionary *)responseObject;
             NSInteger status = [[result objectForKey:@"status"] integerValue];
             NSLog(@"%@", result);
             if (status == 1) {
                 
                 NSDictionary *results = [result valueForKey:@"results"];
                 NSLog(@"results -%@-",[results isEqual:@""] ? @"yes":@"no");
                 
                 if (![results isEqual:@""]) {
                     if ([[results objectForKey:@"total_count"] integerValue]) {
                         NSDictionary *results = [result objectForKey:@"results"];
                         NSLog(@"fetchObjects: %@", results);
                         [self extractObjects:results];
                     }
                     else {
                         dispatch_async(dispatch_get_main_queue(), ^(){ [ProgressHUD showError:@"无更新" Interaction:YES];});
                     }
                 }
                 else {
                     dispatch_async(dispatch_get_main_queue(), ^(){ [ProgressHUD showError:@"无照片" Interaction:YES];});
                 }

             }
             else {
                 [ProgressHUD showError:[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] Interaction:YES];
                 if ([[NSString stringWithFormat:@"%@",[result objectForKey:@"error"]] isEqualToString:@"token不存在"]) {
                     dispatch_async(dispatch_get_main_queue(), ^(){
                         [self presentLoginController];
                     });
                 }
             }
         }
         failure:^(NSURLSessionDataTask *task, NSError *error){
             [ProgressHUD showError:@"获取超时,请检查网络" Interaction:YES];
             NSLog(@"获取失败: %@", error);
             [self.tableView.mj_header endRefreshing];
         }];
}

- (void)extractObjects:(NSDictionary *)result
{
    NSInteger pageSize = [[result objectForKey:@"page_size"] integerValue];
    self.totalPage = [[result objectForKey:@"total_page"] integerValue];
    for (int i = 0; i < pageSize; i++) {
        NSDictionary *object = [result objectForKey:[NSString stringWithFormat:@"%d", i]];
        NSLog(@"extractObject: %@", object);
        if (object) {
            [_objects addObject: object];
        } 
    }
    dispatch_async(dispatch_get_main_queue(), ^(){
        _lastCell.status = LastCellStatusMore;
        [self.tableView reloadData];
        
    });
}

- (void)presentLoginController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    LogViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self presentViewController:loginVC animated:YES completion:nil];
}
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

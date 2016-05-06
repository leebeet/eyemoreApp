//
//  RootVideoBrowseViewController.m
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/12/7.
//  Copyright © 2015年 3DB. All rights reserved.
//

#import "RootVideoBrowseViewController.h"
#import "MGSwipeButton.h"
#import "MGSwipeTableCell.h"
#import "JBParallaxCell.h"
#import "VideoClient.h"
#import "SaveLoadInfoManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FSSyncSpinner.h"
#import "ProgressHUD.h"
#import "VideoConfig.h"
#import "eyemoreVideo.h"

@interface RootVideoBrowseViewController ()<MGSwipeTableCellDelegate>

@property (weak,   nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tableItems;
@property (nonatomic, strong) VideoClient *videoManager;
@property (nonatomic, strong) UIToolbar    *toolBar;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;
@property (nonatomic, strong) NSMutableDictionary *savedMovie;
@property (nonatomic, strong) NSIndexPath *selectedIndex;

@property (nonatomic, strong) NSMutableArray *array;
@end

@implementation RootVideoBrowseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.videoManager = [VideoClient sharedVideoClient];
    self.tableItems = [[NSMutableArray alloc] init];
    for (int i = 0; i < [[VideoConfig sharedVideoConfig] myEyemoreVideos].count; i ++) {
         [self.tableItems addObject:[self.videoManager getThumbnailImageWithEyemoeVideo:[[VideoConfig sharedVideoConfig] myEyemoreVideoAtIndex:i]]];
    }
    //[self setUpToolBar];
    [self setUpNaviBar];
    self.array = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpToolBar
{
    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 18, self.view.frame.size.width, 44)];
    [self.toolBar setTranslucent:NO];
    self.toolBar.barTintColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1];
    self.toolBar.tintColor = [UIColor whiteColor];
    [self.view addSubview:self.toolBar];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(DismissVideoBrowser)];
    NSArray *arr1=[[NSArray alloc]initWithObjects:btn1, nil];
    [self.toolBar setItems:arr1 animated:YES];
}

- (void)setUpNaviBar
{
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1];
    UIBarButtonItem *btn1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(DismissVideoBrowser)];
    btn1.tintColor = [UIColor whiteColor];
    NSArray *arr1=[[NSArray alloc]initWithObjects:btn1, nil];
    self.navigationItem.leftBarButtonItems = arr1;
}

- (void)DismissVideoBrowser
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    NSString *key = [self.videoManager.videoList[indexPath.row] objectForKey:@"MoviePath"];
//    
//    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", key]];
//    NSURL *furl = [[NSURL alloc] initFileURLWithPath:path];
    //NSLog(@"self.videoManager.videoList [%ld]: %@",(long)indexPath.row,self.videoManager.videoList[indexPath.row]);
    
    self.moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[self.videoManager getCompleteVideFileURLWithEyemoreVideo:[[VideoConfig sharedVideoConfig] myEyemoreVideoAtIndex:indexPath.row]]];
    //[self.view addSubview:self.moviePlayer.view];
    [self.moviePlayer.moviePlayer play];
    [self presentMoviePlayerViewControllerAnimated:self.moviePlayer];
    [self.moviePlayer.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    
    [self.moviePlayer.view setBackgroundColor:[UIColor clearColor]];
    [self.moviePlayer.view setFrame:self.view.frame];
    
    [self.moviePlayer.moviePlayer play];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"parallaxCell";
    JBParallaxCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[JBParallaxCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Movie.png"]];
    [cell.titleLabel addSubview:view];
    //UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Movie.png"]];
    cell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@" ",)];
    //[cell.titleLabel setBackgroundColor:color];
    
    cell.subtitleLabel.text = [[VideoConfig sharedVideoConfig] myEyemoreVideoAtIndex:indexPath.row].createdDate;
    cell.parallaxImage.image = self.tableItems[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@" 删除  " backgroundColor:[UIColor colorWithRed:255/255.0 green:56/255.0 blue:36/255.0 alpha:1]],
                          [MGSwipeButton buttonWithTitle:@" 保存  " backgroundColor:[UIColor colorWithRed:68/255.0 green:219/255.0 blue:94/255.0 alpha:1]]];
    
    cell.rightSwipeSettings.transition = MGSwipeTransitionStatic;
    cell.delegate = self; //optional
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Get visible cells on table view.
    NSArray *visibleCells = [self.tableView visibleCells];
    
    for (JBParallaxCell *cell in visibleCells) {
        [cell cellOnTableView:self.tableView didScrollOnView:self.view];
    }
}

-(BOOL)swipeTableCell:(JBParallaxCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
{
    NSLog(@"Delegate: button tapped, %@ position, index %d, from Expansion: %@",
          direction == MGSwipeDirectionLeftToRight ? @"left" : @"right", (int)index, fromExpansion ? @"YES" : @"NO");
    
    if (direction == MGSwipeDirectionRightToLeft && index == 0)
    {
        //delete button 删除视频
        NSIndexPath * path = [self.tableView indexPathForCell:cell];
        [self.tableItems removeObjectAtIndex:path.row];
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.videoManager removeVideoWithEyemoreVideo:[[VideoConfig sharedVideoConfig] myEyemoreVideoAtIndex:path.row]];
        });
        
        return NO; //Don't autohide to improve delete expansion animation
    }
    else if(direction == MGSwipeDirectionRightToLeft && index == 1)
    {
        //保存视频到本地后再删除
        NSIndexPath * path = [self.tableView indexPathForCell:cell];
        NSLog(@"%li", (long)path.row);
        dispatch_async(dispatch_get_global_queue(0, 0), ^(){
            
            UISaveVideoAtPathToSavedPhotosAlbum([self.videoManager getCompleteVideoFilePathWithEyemoreVideo:[[VideoConfig sharedVideoConfig] myEyemoreVideoAtIndex:path.row]],
                                                self,
                                                @selector(videoSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:),
                                                (__bridge void *)cell);

        });
        
        cell.syncSpinner = [[FSSyncSpinner alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        cell.syncSpinner.center = CGPointMake(cell.contentView.frame.size.width / 10 * 9.4, cell.contentView.frame.size.height / 5 * 4);
        [cell.contentView addSubview:cell.syncSpinner];
//        [cell.syncSpinner setTranslatesAutoresizingMaskIntoConstraints:NO];
//        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.syncSpinner
//                                                                     attribute:NSLayoutAttributeRight
//                                                                     relatedBy:NSLayoutRelationEqual
//                                                                        toItem:cell.contentView
//                                                                     attribute:NSLayoutAttributeRight
//                                                                    multiplier:1
//                                                                      constant:-30]];
//        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.syncSpinner
//                                                                     attribute:NSLayoutAttributeBottom
//                                                                     relatedBy:NSLayoutRelationEqual
//                                                                        toItem:cell.contentView
//                                                                     attribute:NSLayoutAttributeBottom
//                                                                    multiplier:1
//                                                                      constant:-20]];
        cell.syncSpinner.hidesWhenFinished = NO;
        [cell.syncSpinner startAnimating];
//      [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    }
    return YES;
}

- (void)videoSavedToPhotosAlbum:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{

    JBParallaxCell  *cell = (__bridge JBParallaxCell *)contextInfo;
    dispatch_async(dispatch_get_main_queue(), ^(){
    
        [cell.syncSpinner finish];
        [self performSelector:@selector(deleteSelectedCell:) withObject:(id)cell afterDelay:1.5f];
    });
}

- (void)deleteSelectedCell:(id)object
{

    JBParallaxCell *cell = (JBParallaxCell *)object;
    NSIndexPath    *path = [self.tableView indexPathForCell:cell];
    [self.videoManager removeVideoWithEyemoreVideo:[[VideoConfig sharedVideoConfig] myEyemoreVideoAtIndex:path.row]];
    [self.tableItems   removeObjectAtIndex:path.row];
    [self.tableView    deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    [cell.syncSpinner removeFromSuperview];
}

#pragma mark - Rotation Setting

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
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

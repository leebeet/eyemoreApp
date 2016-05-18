//
//  VideoBrowserController.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/7.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "VideoBrowserController.h"
#import "TCPSocketManager.h"
#import "VideoRecorder.h"
#import "VideoConfig.h"
#import "VideoClient.h"
#import "eyemoreVideo.h"
#import "VideoSectionHeader.h"
#import "VideoDownloadedCell.h"
#import "VideoUndownloadCell.h"
#import "JGActionSheet.h"
#import "ProgressHUD.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MJRefresh.h"
#import "BLUIkitTool.h"

@interface VideoBrowserController ()<UICollectionViewDelegate, UICollectionViewDataSource, TCPSocketManagerDelegate, VideoRecorderDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) VideoConfig *undownloadConfig;
@property (nonatomic, strong) VideoConfig *downloadedConfig;
@property (nonatomic, strong) VideoRecorder *videoRecorder;
@property (nonatomic, strong) TCPSocketManager *socketManager;
@property (nonatomic, strong) VideoClient *videoClient;
@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) UIProgressView *savingProgress;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;

@property (assign, nonatomic) BOOL shouldRefresh;

@end

@implementation VideoBrowserController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"VideoBrowserController will appear...");
    [self setCameraWorkingState];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.automaticallyAdjustsScrollViewInsets = YES;//    自动滚动调整，默认为YES
    //self.edgesForExtendedLayout = UIRectEdgeBottom;
    //初始化collection view
    [self setUpVideoCollection];
    [VideoConfig sharedVideoConfig];
    self.videoClient = [VideoClient sharedVideoClient];
    self.shouldRefresh = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldUpdateVideoList) name:@"EyemoreVideosUpdated" object:nil];
    
    self.collectionView.mj_header = ({
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshCollectionView)];
        //header.lastUpdatedTimeLabel.hidden = YES;
        //header.stateLabel.hidden = YES;
        header.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        header;
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setCameraWorkingState
{
    self.socketManager = [TCPSocketManager sharedTCPSocketManager];
    self.videoRecorder = [VideoRecorder sharedVideoRecorder];
    self.videoRecorder.delegate = self;
    self.socketManager.delegate = self.videoRecorder;
    [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDSetPhotoToSDCard];
    [self updateVideoList];
}

- (void)setUpVideoCollection
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.minimumLineSpacing = 2;
    flowLayout.minimumInteritemSpacing = 0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:flowLayout];
    UIEdgeInsets insets = UIEdgeInsetsMake(64, 0, 44, 0);
    self.collectionView.contentInset = insets;
    self.collectionView.dataSource = self;
    self.collectionView.delegate   = self;
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    self.collectionView.scrollEnabled = YES;
    self.collectionView.alwaysBounceVertical = YES;
    NSLog(@"[self.collectionView setContentSize : %f", self.collectionView.contentSize.height);
    //注册Cell，必须要有
    [self.collectionView registerNib:[UINib nibWithNibName:@"VideoDownloadedCell" bundle:nil] forCellWithReuseIdentifier:@"UICollectionViewCellDownloaded"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"VideoUndownloadCell" bundle:nil] forCellWithReuseIdentifier:@"UICollectionViewCellUndownload"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"VideoSectionHeader"  bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.view addSubview:self.collectionView];
}

- (void)setUpSavingProgressView
{
    self.savingProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    self.savingProgress.progressViewStyle = UIProgressViewStyleBar;
    self.savingProgress.progressTintColor = [UIColor redColor];
    self.savingProgress.trackTintColor = [UIColor grayColor];
    self.savingProgress.progress = 0;
    self.savingProgress.transform = CGAffineTransformMakeScale(1, 3);
}

- (void)presentActionsForItem:(NSIndexPath *)indexPath
{
//    UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"请选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    if (indexPath.section == 0) {
//        UIAlertAction *playAction = [UIAlertAction actionWithTitle:@"播放" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//            NSLog(@"play movie action");
//        }];
//        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//            NSLog(@"save movie action");
//        }];
//        UIAlertAction *deleAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//            NSLog(@"dele movie action");
//        }];
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
//            NSLog(@"cancel movie action");
//        }];
//        [alertCtl addAction:playAction];
//        [alertCtl addAction:saveAction];
//        [alertCtl addAction:deleAction];
//        [alertCtl addAction:cancelAction];
//        
//    }
//    [self presentViewController:alertCtl animated:YES completion:nil];
    if (indexPath.section == 0) {
        JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:@"" message:@"请选择" buttonTitles:@[@"播放", @"保存", @"删除"] buttonStyle:JGActionSheetButtonStyleCustomer];
        JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"取消"] buttonStyle:JGActionSheetButtonStyleCustomer];
        
        NSArray *sections = @[section1, cancelSection];
        JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:sections];
        [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *sheetIndexPath) {
            if (sheetIndexPath.section == 0 && sheetIndexPath.row == 0) {
                [self playMovieWithIndex:indexPath];
            }
            if (sheetIndexPath.section == 0 && sheetIndexPath.row == 1) {
                [self saveDownloadedVideo:indexPath];
            }
            if (sheetIndexPath.section == 0 && sheetIndexPath.row == 2) {
                [self deleteDownloadedVideWithIndex:indexPath];
            }
            [sheet dismissAnimated:YES];
        }];
        [sheet setOutsidePressBlock:^(JGActionSheet *sheet){
            [sheet dismissAnimated:YES];
        }];
        [sheet showInView:[BLUIkitTool currentRootViewController].view animated:YES];
    }
    else if (indexPath.section == 1) {
        JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"下载", @"删除"] buttonStyle:JGActionSheetButtonStyleCustomer];
        JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"取消"] buttonStyle:JGActionSheetButtonStyleCustomer];
        NSArray *sections = @[section1, cancelSection];
        JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:sections];
        
        [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *sheetIndexPath) {
            [sheet dismissAnimated:YES];
            if (sheetIndexPath.section == 0 && sheetIndexPath.row == 0) {
                [self downloadRecordWithIndexPath:indexPath];
            }
            if (sheetIndexPath.section == 0 && sheetIndexPath.row == 1) {
                [self deleteRecordWithIndex:indexPath];
            }
        }];
        [sheet setOutsidePressBlock:^(JGActionSheet *sheet){
            [sheet dismissAnimated:YES];
        }];
        [sheet showInView:[BLUIkitTool currentRootViewController].view animated:YES];
    }
}

- (void)playMovieWithIndex:(NSIndexPath *)indexPath
{
    self.moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[self.videoClient getCompleteVideFileURLWithEyemoreVideo:[[VideoConfig sharedVideoConfig] myEyemoreVideoAtIndex:indexPath.row]]];
    //[self.view addSubview:self.moviePlayer.view];
    [self.moviePlayer.moviePlayer play];
    [self presentMoviePlayerViewControllerAnimated:self.moviePlayer];
    [self.moviePlayer.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    
    [self.moviePlayer.view setBackgroundColor:[UIColor clearColor]];
    [self.moviePlayer.view setFrame:self.view.frame];
    
    [self.moviePlayer.moviePlayer play];
}

- (void)saveDownloadedVideo:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^(){
        
        UISaveVideoAtPathToSavedPhotosAlbum([self.videoClient getCompleteVideoFilePathWithEyemoreVideo:[[VideoConfig sharedVideoConfig] myEyemoreVideoAtIndex:indexPath.row]],
                                            self,
                                            @selector(videoSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:),
                                            (__bridge void *)[self.collectionView cellForItemAtIndexPath:indexPath]);
        
    });
}

- (void)videoSavedToPhotosAlbum:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    
    VideoDownloadedCell  *cell = (__bridge VideoDownloadedCell *)contextInfo;
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self deleteDownloadedVideWithIndex:[self.collectionView indexPathForCell:cell]];
        [ProgressHUD showSuccess:@"保存成功"];
    });
}

- (void)deleteDownloadedVideWithIndex:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EyemoreVideosUpdated" object:nil];
    [self.videoClient removeVideoWithEyemoreVideo:[[VideoConfig sharedVideoConfig] myEyemoreVideoAtIndex:indexPath.row]];
    [[VideoConfig sharedVideoConfig] removeEyemoreVideoAtIndex:indexPath.row];
    [[VideoConfig sharedVideoConfig] synchonizeEyemoreVideos];
    [self deleteCollectionItem:indexPath];
}


- (void)deleteRecordWithIndex:(NSIndexPath *)indexPath
{
    [self.videoRecorder deleteRecordWithID:(int)[self.undownloadConfig myEyemoreVideoAtIndex:indexPath.row].uid completeHandler:^(BOOL isDeleted){
        if (isDeleted) {
            [self.undownloadConfig removeEyemoreVideo:[self.undownloadConfig myEyemoreVideoAtIndex:indexPath.row]];
            NSLog(@"self.undownloadConfig.videoList.count: %lu",(unsigned long)self.undownloadConfig.videoList.count);
            [self deleteCollectionItem:indexPath];
        }
    }];
}

- (void)downloadRecordWithIndexPath:(NSIndexPath *)indexPath
{
    [self setUpSavingProgressView];
    [ProgressHUD show:@"正在下载..." view:self.savingProgress Interaction:NO];
    [self downloadVideoWithIndex:indexPath];
}

- (void)downloadVideoWithIndex:(NSIndexPath *)indexPath
{
    [self.videoRecorder downloadFramesWithEyemoreVide:[self.undownloadConfig myEyemoreVideoAtIndex:indexPath.row]
                                             Progress:^(float progressing){
                                                 dispatch_async(dispatch_get_main_queue(), ^(){
                                                     [self.savingProgress setProgress:progressing animated:YES];
                                                 });
                                             }
                                           completion:^(EyemoreVideo *video, BOOL isSuccess){
                                               if (isSuccess) {
                                                   if (video.resolution.height == 540.0f) {
                                                       video.videoType = @"HD_RECORDING";
                                                   }
                                                   else video.videoType = @"LD_RECORDING";
                                                   [self makeMovieWithVideo:video];
                                                   //[[VideoConfig sharedVideoConfig] addEyemoreVideos:video];
                                                   //[[VideoConfig sharedVideoConfig] synchonizeEyemoreVideos];
                                                   dispatch_async(dispatch_get_main_queue(), ^(){
                                                    [ProgressHUD show:@"正在封装..." Interaction:NO];
                                                   });
                                               }
                                               else {
                                                   dispatch_async(dispatch_get_main_queue(), ^(){
                                                       [ProgressHUD showError:@"下载失败" Interaction:NO];
                                                   });
                                               }
                                           }];
}

- (void)makeMovieWithVideo:(EyemoreVideo *)video
{
    [self.videoClient composeCompleteMovieFileWithEyemoreVideo:video withCallBackBlock:^(BOOL success){
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [ProgressHUD showSuccess:@"封装成功"];
                [self reloadDownloadedSection];
            });
        }
    }];
}

- (void)deleteCollectionItem:(NSIndexPath *)index
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self.collectionView deleteItemsAtIndexPaths:@[index]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EyemoreVideosUpdated" object:nil];
    });
}

#pragma mark - unit convert

- (NSString *)stringForTimeScaleValue:(NSInteger)scale
{
    int minute,second;
        scale = scale / 600;
    NSLog(@"timescale: %ld", (long)scale);

    if (scale >= 60) {
        minute = (int)(scale / 60.0);
        second = (int)(scale - minute * 60);
    }
    else {
        minute = 0;
        second = (int)scale;
    }
    return [NSString stringWithFormat:@"%.2d:%.2d",minute, second];
}

#pragma mark - Data Reloading

- (void)reloadDownloadedSection
{
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)reloadUndownloadedSection
{
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
}

- (void)shouldUpdateVideoList
{
    self.shouldRefresh = YES;
}

- (void)updateVideoList
{
    if (self.shouldRefresh ) {
        [self refreshCollectionView];
    }
}

- (void)refreshCollectionView
{
    [self reloadDownloadedSection];
    [self.videoRecorder getRecordDesList];
    self.shouldRefresh = NO;
    [self.collectionView.mj_header endRefreshing];
}

#pragma mark - UICollectionView Data Source

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        NSLog(@"[VideoConfig sharedVideoConfig].count refresh: %lu",(unsigned long)[VideoConfig sharedVideoConfig].videoList.count);
        return [VideoConfig sharedVideoConfig].videoList.count;
    }
    else if (section == 1) {
        NSLog(@"self.undownloadConfig.videoList.count refresh: %lu",(unsigned long)[VideoConfig sharedVideoConfig].videoList.count);
        return self.undownloadConfig.videoList.count;
    }
    else return 1;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.socketManager.isLost) {
        return 1;
    }
    else {
        return 2; 
    }
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * DownloadedCellIdentifier = @"UICollectionViewCellDownloaded";
    static NSString * UndownloadCellIdentifier = @"UICollectionViewCellUndownload";
    if (indexPath.section == 0) {
        VideoDownloadedCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:DownloadedCellIdentifier forIndexPath:indexPath];
        cell.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:34/255.0 alpha:1];
        cell.backgroundImageView.alpha = 0;
        EyemoreVideo *video = [[VideoConfig sharedVideoConfig] myEyemoreVideoAtIndex:indexPath.row];
        dispatch_async(dispatch_get_global_queue(0, 0), ^(){
            UIImage *image = [self.videoClient getThumbnailImageWithEyemoeVideo:video];
            dispatch_async(dispatch_get_main_queue(), ^(){
                cell.lengthLabel.text = [self stringForTimeScaleValue:video.timeScale];
                if ([video.videoType isEqualToString:@"HD_RECORDING"]) {
                    [cell.HDLabel setHidden:NO];
                }
                else [cell.HDLabel setHidden:YES];
                [UIView animateWithDuration:0.1f delay:0.2f options:UIViewAnimationOptionAllowAnimatedContent animations:^(){
                    cell.backgroundImageView.alpha = 1;
                    [cell.backgroundImageView setImage:image];
                } completion:^(BOOL finished){
                }];
            });
        });
        return cell;
    }
    else {
        VideoUndownloadCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:UndownloadCellIdentifier forIndexPath:indexPath];
        UIImageView *cellImage = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
        cellImage.contentMode = UIViewContentModeScaleAspectFit;
        cell.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:34/255.0 alpha:1];
        cellImage.alpha = 0;
        NSLog(@"undownload items");
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^(){
            EyemoreVideo *video = [self.undownloadConfig myEyemoreVideoAtIndex:indexPath.row];
            dispatch_async(dispatch_get_main_queue(), ^(){
                cell.lengthLabel.text = [NSString stringWithFormat:@"%.2fM", (float)video.fileSize / 1024.0 / 1024.0];
            });
        });
        
        return cell;
    }
    return nil;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    VideoSectionHeader *reusableview;
    
    if (kind == UICollectionElementKindSectionHeader && indexPath.section == 0)
    {
        reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        reusableview.headerLabel.text = @"已同步";
    }
    else if (kind == UICollectionElementKindSectionHeader && indexPath.section == 1) {
        reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        reusableview.headerLabel.text = @"未同步";
    }
    return reusableview;
}

//headerview height
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(self.view.frame.size.width, 30);
}
//
//// -------------------------------------------------------------------------------
////	startIconDownload:forIndexPath:
//// -------------------------------------------------------------------------------
//- (void)startIconDownloadforIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
//    UIImageView *cellImage = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
//    cellImage.contentMode = UIViewContentModeScaleAspectFit;
//    cellImage.alpha = 0;
//
//    if ([[UIScreen mainScreen] bounds].size.width == 320) {
//        //小屏幕／5，5s设备滑动卡顿优化
//        [self.imgClient.dataCache dataForKey:self.imgClient.imgPath[indexPath.row] block:^(NSData *data){
//            dispatch_async(dispatch_get_global_queue(0, 0), ^(){
//                NSData *datan = UIImageJPEGRepresentation([UIImage imageWithData:data], 0.1);
//                UIImage *image = [UIImage imageWithData:datan];
//                dispatch_async(dispatch_get_main_queue(), ^(){
//                    [cell.contentView addSubview:cellImage];
//                    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^(){
//                        cellImage.alpha = 1;
//                        [cellImage setImage:image];
//                    } completion:^(BOOL finished){}];
//                });
//            });
//        }];
//
//    }
//    else{
//        //小屏幕／6，6s, 6p, 6sp设备滑动卡顿优化
//        [self.imgClient.dataCache dataForKey:self.imgClient.imgPath[indexPath.row] block:^(NSData *data){
//            dispatch_async(dispatch_get_global_queue(0, 0), ^(){
//                //NSData *datan = UIImageJPEGRepresentation([UIImage imageWithData:data], 0.1);
//                UIImage *image = [UIImage imageWithData:data];
//
//                dispatch_async(dispatch_get_main_queue(), ^(){
//                    [cell.contentView addSubview:cellImage];
//                    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^(){
//                        cellImage.alpha = 1;
//                        [cellImage setImage:image];
//                    } completion:^(BOOL finished){}];
//                });
//            });
//        }];
//    }
//}
//
//// -------------------------------------------------------------------------------
////	loadImagesForOnscreenRows
////  This method is used in case the user scrolled into a set of cells that don't
////  have their app icons yet.
//// -------------------------------------------------------------------------------
//- (void)loadImagesForOnscreenRows
//{
//    if (self.imgClient.imgPath.count > 0)
//    {
//        NSArray *visiblePaths = [self.collectionView indexPathsForVisibleItems];
//        for (NSIndexPath *indexPath in visiblePaths)
//        {
//            [self startIconDownloadforIndexPath:indexPath];
//        }
//    }
//}
//
//
//#pragma mark - UIScrollViewDelegate
//
//// -------------------------------------------------------------------------------
////	scrollViewDidEndDragging:willDecelerate:
////  Load images for all onscreen rows when scrolling is finished.
//// -------------------------------------------------------------------------------
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if (!decelerate)
//    {
//        [self loadImagesForOnscreenRows];
//    }
//}
//
//// -------------------------------------------------------------------------------
////	scrollViewDidEndDecelerating:scrollView
////  When scrolling stops, proceed to load the app icons that are on screen.
//// -------------------------------------------------------------------------------
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    [self loadImagesForOnscreenRows];
//}

#pragma mark - UICollectionView Delegate FlowLayout

//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //6p,6sp界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 414) {
        return CGSizeMake(102, 102);
    }
    //5,5s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 320) {
        return CGSizeMake(105, 102);
    }
    //6,6s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 375) {
        return CGSizeMake(92, 90);
    }
    else return CGSizeMake(101, 58);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //6p,6sp界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 414) {
        return UIEdgeInsetsMake(1.5, 0, 1.5, 0);
    }
    //5,5s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 320) {
        return UIEdgeInsetsMake(1.5, 0, 1.5, 0);
    }
    //6,6s界面优化
    if ([[UIScreen mainScreen] bounds].size.width == 375) {
        return UIEdgeInsetsMake(1.5, 0, 1.5, 0);
    }
    else return UIEdgeInsetsMake(2, 2,2, 2);;
}

#pragma mark - UICollectionView Delegate

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //临时改变个颜色，看好，只是临时改变的。如果要永久改变，可以先改数据源，然后在cellForItemAtIndexPath中控制。（和UITableView差不多吧！O(∩_∩)O~）
    //cell.backgroundColor = [UIColor greenColor];
    NSLog(@"item======%ld",(long)indexPath.item);
    NSLog(@"row=======%ld",(long)indexPath.row);
    NSLog(@"section===%ld",(long)indexPath.section);
    [self presentActionsForItem:indexPath];
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - Video Recorder Delegate

- (void)videoRecorder:(VideoRecorder *)recorder didGetVideoDesList:(VideoConfig *)config
{
    self.undownloadConfig = config;
    dispatch_async(dispatch_get_main_queue(), ^(){
        //[self refreshCollectionView];
        [self reloadUndownloadedSection];
    });    
}

#pragma mark - Socket Manager Delegate

- (void)didFinishBatchFilesDownloadingWithImageDataArray:(NSMutableArray *)imageDataArray
{}
- (void)didSendMessageWithCMD:(CTL_MESSAGE_PACKET)command
{
    [self.socketManager receiveMessageWithTimeOut:-1];
}
- (void)didReceiveACKWithState:(CTL_MESSAGE_PACKET)ACK
{
    if (ACK.cmd == SDB_SET_DEV_WORK_MODE_ACK && ACK.param0 == DWM_NORMAL) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetDeviceInfo];
    }
    
    if (ACK.cmd == SDB_SET_STANDBY_EN_ACK && ACK.param0 == STADNDBY_DISABLE) {        
    }
    if (ACK.cmd == SDB_GET_NORMAL_PHOTO_COUNT_ACK) {
    }
    if (ACK.cmd == SDB_GET_BLOCK_NORMAL_PHOTOS_ACK) {
    }
    if (ACK.cmd == SDB_SET_RECV_OK_ACK) {
        [self.socketManager sendMessageWithCMD:(CTL_MESSAGE_PACKET)CMDGetFileList];
    }
}
- (void)didFinishConnectToHost
{}
- (void)didDisconnectSocket
{}
- (void)didReceiveDevInfo:(DEV_INFO)decInfo
{}
- (void)didFinishSingleFileDownloadingWithImageData:(NSData *)imageData
{}
- (void)didLoseAlive
{}
- (void)didReceiveLensStatus:(LENS_PARAMS)lensStatus
{}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end



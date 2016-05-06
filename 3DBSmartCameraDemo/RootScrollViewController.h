//
//  rootScrollViewController.h
//  3DBSmartCameraDemo
//
//  Created by 李伯通 on 15/4/1.
//  Copyright (c) 2015年 3DB. All rights reserved.
//

#import "ViewController.h"
#import "BLSeeImageView.h"
#import "ImageAlbumManager.h"
#import "JLResourcePath.h"
#import "ImageClient.h"
#import "MRoundedButton.h"
#import "PulseWaveController.h"

//typedef enum _SHOOTMODE {
//    
//    SYNC_MODE = 1,
//    
//    SELFIE_MODE = 2,
//    
//    EMPTY_MODE = 3
//    
//}SHOOTMODE;

@interface RootScrollViewController : ViewController<UIScrollViewDelegate, imageClientDelegate, UIAlertViewDelegate, TCPSocketManagerDelegate>

@property (strong, nonatomic)          NSMutableArray   *scrollArray;
//@property (weak,   nonatomic) IBOutlet UIButton       *saveButton;
@property (weak,   nonatomic) IBOutlet UIButton         *takeButton;
@property (strong, nonatomic)          BLSeeImageView   *imageView;
@property (strong, nonatomic)          ImageClient      *imgClient;
@property (strong, nonatomic)          UIAlertView      *alertView;
//@property (weak,   nonatomic) IBOutlet UIButton       *deleteButton;
@property (weak,   nonatomic) IBOutlet UIButton         *returnButton;
@property (assign, nonatomic) BOOL                       isHiden;
@property (weak,   nonatomic) IBOutlet UILabel          *currentImageIndexLabel;
@property (weak,   nonatomic) IBOutlet UILabel          *totalIndexLabel;
@property (assign, nonatomic)          NSUInteger        imgPathCount;
@property (weak,   nonatomic) IBOutlet UILabel          *sysmbolLabel1;
@property (strong, nonatomic)          UIView           *indexView;
@property (strong, nonatomic)          TCPSocketManager *socketManager;
@property (assign, nonatomic) UIInterfaceOrientation     presentingDirection;
@property (assign, nonatomic)          BOOL             autoRotate;

@property (assign, nonatomic)          SHOOTMODE        shootMode;
@property (assign, nonatomic)          BOOL             isExecuteShootTimer;

//+ (RootScrollViewController *)sharedRootScrollViewController;
- (IBAction)saveButtonTapped:(id)sender;
- (IBAction)removeButtonTapped:(id)sender;
- (IBAction)takeButtonTapped:(id)sender;
- (IBAction)returnButtonTapped:(id)sender;
- (void)scaleImageView:(id)sender;

- (void)dismissController;
- (void)hideAllButtons;

@end

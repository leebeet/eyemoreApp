//
//  BLEdittingView.h
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/19.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BLEdittingView;

@protocol BLEdittingViewDeledate <NSObject>
- (void)BLEdittingView:(BLEdittingView *)edittingView didActionForTextContent:(NSString *)content;
@end

@interface BLEdittingView : UIView <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *textContainView;
@property (nonatomic, strong) UIView *superView;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UILabel *placeHolder;
@property (nonatomic, assign) id <BLEdittingViewDeledate> delegate;

- (instancetype)initWithFrame:(CGRect)frame actionTitle:(NSString *)title inSuperView:(UIView *)superView;
- (void)becomeEditting;
- (void)resetPlaceHolder;

@end

//
//  BLEdittingView.m
//  eyemoreCamera
//
//  Created by 李伯通 on 16/4/19.
//  Copyright © 2016年 3DB. All rights reserved.
//

#import "BLEdittingView.h"

@implementation BLEdittingView 

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame actionTitle:(NSString *)title inSuperView:(UIView *)superView
{
    if ((self = [super initWithFrame:frame])) {
        
        self.superView = superView;
        self.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:34/255.0 alpha:1]; //背景色
        
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(4, 4, self.superView.frame.size.width - 80, 36)];
        self.textView.backgroundColor=[UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1]; //背景色
        self.textView.scrollEnabled = YES;    //当文字超过视图的边框时是否允许滑动，默认为“YES”
        self.textView.editable = YES;        //是否允许编辑内容，默认为“YES”
        self.textView.delegate = self;       //设置代理方法的实现类
        self.textView.font=[UIFont fontWithName:@"Arial" size:14.0]; //设置字体名字和字体大小;
        self.textView.returnKeyType = UIReturnKeyDefault;//return键的类型
        self.textView.keyboardType = UIKeyboardTypeDefault;//键盘类型
        self.textView.keyboardAppearance = UIKeyboardAppearanceDark;
        self.textView.textAlignment = NSTextAlignmentLeft; //文本显示的位置默认为居左
        self.textView.dataDetectorTypes = UIDataDetectorTypeAll; //显示数据类型的连接模式（如电话号码、网址、地址等）
        self.textView.textColor = [UIColor lightGrayColor];
        //self.textView.text = @"点击评论";//设置显示的文本内容
        self.textView.layer.masksToBounds = YES;
        self.textView.layer.cornerRadius = 5;
        
        self.actionButton = [[UIButton alloc] initWithFrame:CGRectMake(4 + self.textView.frame.size.width + 4, 4, 68, 36)];
        self.actionButton.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:30/255.0 alpha:1]; //背景色
        [self.actionButton setTitle:title forState:UIControlStateNormal];
        [self.actionButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.actionButton addTarget:self action:@selector(actionButtonTappe) forControlEvents:UIControlEventTouchUpInside];
        self.actionButton.layer.masksToBounds = YES;
        self.actionButton.layer.cornerRadius = 5;
        self.actionButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:self.actionButton];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
        [self.superView addGestureRecognizer:tap];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        [self addSubview:self.textView];
        [self.superview addSubview:self];
        [self setUpHintLabel];

    }
    return self;
}

- (void)actionButtonTappe
{
    [self.delegate  BLEdittingView:self didActionForTextContent:self.textView.text];
    //[self setUpHintLabel];
    [self.textView resignFirstResponder];
}

- (void)hideKeyBoard
{
    [self.textView resignFirstResponder];
    [self.delegate BLEdittingView:self didHideKeyBoardWithContent:self.textView.text];
}

- (void)becomeEditting
{
    [self.textView becomeFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.superView convertRect:keyboardRect fromView:nil];
    
    // 根据老的 frame 设定新的 frame
    CGRect newTextViewFrame = self.superView.frame; // by michael
    newTextViewFrame.origin.y = keyboardRect.origin.y - self.superView.frame.size.height;
    
    // 键盘的动画时间，设定与其完全保持一致
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // 键盘的动画是变速的，设定与其完全保持一致
    NSValue *animationCurveObject = [userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSUInteger animationCurve;
    [animationCurveObject getValue:&animationCurve];
    
    // 开始及执行动画
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurve];
    self.superView.frame = newTextViewFrame;
    [UIView commitAnimations];
}
//键盘消失时的处理，文本输入框回到页面底部。
- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    // 键盘的动画时间，设定与其完全保持一致
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // 键盘的动画是变速的，设定与其完全保持一致
    NSValue *animationCurveObject =[userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSUInteger animationCurve;
    [animationCurveObject getValue:&animationCurve];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurve];
    CGRect newTextViewFrame = self.superView.frame;
    newTextViewFrame.origin.y = self.superView.frame.size.height - self.superView.frame.size.height;
    self.superView.frame = newTextViewFrame;
    [UIView commitAnimations];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0)
    {
        [self setUpHintLabel];
    }
    else
    {
        [self unSetUpHintLabel];
    }
}

- (void)resetPlaceHolder
{
    [self setUpHintLabel];
    self.textView.text = nil;
}

- (void)setUpHintLabel
{
    if (self.placeHolder == nil) {
        self.placeHolder = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, 200, 36)];
        self.placeHolder.textColor = [UIColor darkGrayColor];
        [self.textView addSubview:self.placeHolder];
        self.placeHolder.font = [UIFont systemFontOfSize:14.0];
    }
    [self.placeHolder setText:NSLocalizedString(@"Input Comment...", nil)];
}

- (void)unSetUpHintLabel
{
    [self.placeHolder setText:@""];
}
@end

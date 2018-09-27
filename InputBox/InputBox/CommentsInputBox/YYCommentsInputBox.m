//
//  YYCommentsInputBox.m
//  InputBox
//
//  Created by yinyao on 2018/9/25.
//  Copyright © 2018年 yinyao. All rights reserved.
//

#import "YYCommentsInputBox.h"
#import "YYCommentsTextView.h"
#import "UIView+MJExtension.h"
#import "Utility.h"
#import "UIColor+Category.h"

#define MAXSTRINGLENGTH     200     //限定输入长度


@interface YYCommentsInputBox() <UITextViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UIView                *lineView;          //分割线
@property (nonatomic, strong) UIView                *contentView;       //展示背景的view
@property (nonatomic, strong) YYCommentsTextView    *textView;          //显示文字框
@property (nonatomic, strong) UILabel               *placeholderLabel;  //占位字符Label

@end

@implementation YYCommentsInputBox
{
    CGFloat  keyboardY;             //键盘的Y值
    NSString *placeholderText;      //设置占位符的文字
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"YJCommentsInputBox - dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        //增加监听，当键盘即将改变Frame时
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
        //增加监听，当键盘已经改变Frame时
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
        //增加监听，当键盘出现时收出消息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
        //增加监听，当键退出时收出消息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)name:UIKeyboardWillHideNotification
                                                   object:nil];
        //设置默认属性
        self.textEdge           = 10.f;
        self.font               = [UIFont systemFontOfSize:14];
        self.maxLine            = 3;
        self.textLineSpacing    = 8.f;
        self.bgViewEdgeInsets   = UIEdgeInsetsMake(6.f, 15.f, 6.f, 15.f);
        self.isHiddenBottom     = YES;
        self.isDisableSlide     = NO;
        
    }
    return self;
}

///设置好属性之后开始布局（在生命周期中最好只调用一次）
- (void)beginUpdateUI {
    
    //初始化高度 textView的lineHeight + 2 * 上下间距
    CGFloat orignTextH  = ceil (self.font.lineHeight) + 2 * self.textEdge + self.bgViewEdgeInsets.top + self.bgViewEdgeInsets.bottom;
    self.frame = CGRectMake(0, SCREEN_HEIGHT - orignTextH, SCREEN_WIDTH, orignTextH);
    self.backgroundColor = [UIColor whiteColor];
    
    if (![self.subviews containsObject:self.lineView]) {
        [self addSubview:self.lineView];
    }
    if (![self.subviews containsObject:self.contentView]) {
        [self addSubview:self.contentView];
    }
    if (![self.subviews containsObject:self.textView]) {
        [self addSubview:self.textView];
    }
    if (![self.subviews containsObject:self.placeholderLabel]) {
        [self addSubview:self.placeholderLabel];
    }
}

#pragma mark - 共用方法

///设置占位符
- (void)setPlaceholderText:(NSString *)text{
    placeholderText = text;
    self.placeholderLabel.text = placeholderText;
}

///开始弹键盘
- (void)startPopBox {
    [self.textView becomeFirstResponder];
}

///退出键盘
- (void)endPopBox {
    [self.textView resignFirstResponder];
}

///发送成功的处理
- (void)sendSuccessHandle {
    NSLog(@"------ 发送成功之后清空 ------");
    
    self.textView.text = nil;
    self.placeholderLabel.hidden = NO;
    
    CGFloat lineH = self.textView.font.lineHeight;
    self.textView.mj_h = lineH;
    self.contentView.mj_h = lineH + _textEdge * 2;
    self.mj_h = self.contentView.mj_h + self.bgViewEdgeInsets.top + self.bgViewEdgeInsets.bottom;
    
    [self.textView resignFirstResponder];
}

#pragma mark - 键盘出现改变时
//当键盘出现时调用
- (void)keyboardWillShow:(NSNotification *)aNotification {
    
    UIViewController *vc = (UIViewController *)[Utility getCurrentVC];
    if (vc != _currentVC) {
        return;
    }
    // 禁用返回手势
    if ([self.currentVC.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] && (self.isDisableSlide)) {
        self.currentVC.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification {
    
    UIViewController *vc = (UIViewController *)[Utility getCurrentVC];
    if (vc != _currentVC) {
        return;
    }
    // 开启返回手势
    if ([self.currentVC.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] && (self.isDisableSlide)) {
        self.currentVC.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    if (self.isHiddenBottom) {
        self.mj_y = SCREEN_HEIGHT;
    }
}

//当键盘即将改变Frame时
-(void)keyboardWillChangeFrame:(NSNotification *)notification {
    
    UIViewController *vc = (UIViewController *)[Utility getCurrentVC];
    if (vc != _currentVC) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    // 动画的持续时间
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 键盘的frame
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardY = keyboardF.origin.y;
    
    if (!_isDisappear) {
        
        [self dealKeyBoardWithKeyboardF:keyboardY duration:duration];
        
    }
}

//当键盘已经改变Frame时
-(void)keyboardDidChangeFrame:(NSNotification *)notification {
    
    UIViewController *vc = (UIViewController *)[Utility getCurrentVC];
    if (vc != _currentVC) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    // 动画的持续时间
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 键盘的frame
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    keyboardY = keyboardF.origin.y;
    // 工具条的Y值 == 键盘的Y值 - 工具条的高度
    if (_isDisappear) {
        [self dealKeyBoardWithKeyboardF:keyboardY duration:duration];
    }
    
}
#pragma mark---处理高度---
- (void)dealKeyBoardWithKeyboardF:(CGFloat)keyboardY duration:(CGFloat)duration {
    
    if (!_isDisappear) {
        [UIView animateWithDuration:duration animations:^{
            // 工具条的Y值 == 键盘的Y值 - 工具条的高度
            
            if (keyboardY > SCREEN_HEIGHT) {
                self.mj_y = SCREEN_HEIGHT- self.mj_h;
            }else
            {
                self.mj_y = keyboardY - self.mj_h;
            }
        }];
    }else{
        if (keyboardY > SCREEN_HEIGHT) {
            self.mj_y = SCREEN_HEIGHT- self.mj_h;
        }else
        {
            self.mj_y = keyboardY - self.mj_h;
        }
    }
}

#pragma mark --- UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView{
    //设置占位符
    if (textView.text.length == 0) {
        _placeholderLabel.hidden = NO;
    }else{
        _placeholderLabel.hidden = YES;
    }
    
    CGFloat contentSizeH = self.textView.contentSize.height;
    CGFloat lineH = self.textView.font.lineHeight;
    
    CGFloat maxHeight = ceil(lineH * self.maxLine + textView.textContainerInset.top + textView.textContainerInset.bottom) + (self.maxLine - 1) * _textLineSpacing;
    if (contentSizeH <= maxHeight) {
        self.textView.mj_h = contentSizeH;
        self.contentView.mj_h = contentSizeH + _textEdge * 2;
    }else{
        self.textView.mj_h = maxHeight;
        self.contentView.mj_h = maxHeight + _textEdge * 2;
    }
    
    [textView scrollRangeToVisible:NSMakeRange(textView.selectedRange.location, 1)];
    
    CGFloat totalH = ceil(self.contentView.mj_h) + self.bgViewEdgeInsets.top + self.bgViewEdgeInsets.bottom;
    self.frame = CGRectMake(0, keyboardY - totalH, self.mj_w, totalH);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {//获取键盘中发送事件（回车事件）
        
        [self sendClick];  //处理键盘的发送事件
        return NO;
    }
    
    if (textView.text.length + (text.length - range.length) <= MAXSTRINGLENGTH) {
        return YES;
    } else {
        NSLog(@"评论最多不超过200字哦");
        return NO;
    }
}

#pragma  mark -- 发送事件
- (void)sendClick {
    
    WEAKSELF;
    if (self.commentsInputBoxSendBlock) {
        self.commentsInputBoxSendBlock(weakSelf, _textView.text);
    }
}

#pragma mark---setter---
-(void)setTextEdge:(CGFloat)textEdge{
    _textEdge  = textEdge;
    
    if (_textEdge <= 0) {
        _textEdge = 10;
    }
}

-(void)setMaxLine:(int)maxLine{
    _maxLine = maxLine;
    
    if (!_maxLine || _maxLine <= 0) {
        _maxLine = 3;
    }
}

-(void)setFont:(UIFont *)font{
    _font = font;
    if (!font) {
        _font = [UIFont systemFontOfSize:14];
    }
}

-(void)setIsDisappear:(BOOL)isDisappear{
    _isDisappear = isDisappear;
}

#pragma mark --- 懒加载控件

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5f)];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"#DDDDDD"];
    }
    return _lineView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(self.bgViewEdgeInsets.left, self.bgViewEdgeInsets.top, SCREEN_WIDTH - self.bgViewEdgeInsets.left - self.bgViewEdgeInsets.right, ceil(self.font.lineHeight) + _textEdge * 2)];
        _contentView.backgroundColor = [UIColor colorWithHexString:@"#F2F2F2"];
        _contentView.layer.cornerRadius = 4;
    }
    return _contentView;
}

- (YYCommentsTextView *)textView {
    if (!_textView) {
        _textView = [[YYCommentsTextView alloc]initWithFrame:CGRectMake(self.bgViewEdgeInsets.left + self.textEdge, self.bgViewEdgeInsets.top + _textEdge, SCREEN_WIDTH - self.bgViewEdgeInsets.left - self.bgViewEdgeInsets.right -_textEdge * 2, ceil(self.font.lineHeight))];
        _textView.backgroundColor = [UIColor colorWithHexString:@"#F2F2F2"];
        _textView.font = self.font;
        _textView.delegate = self;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        _textView.textContainerInset = UIEdgeInsetsZero;
        _textView.textContainer.lineFragmentPadding = 0;
        _textView.layoutManager.allowsNonContiguousLayout = NO;
        
        //初始化UITextView的行间距
        _textView.text = @" ";
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineSpacing = _textLineSpacing;
        NSDictionary *attributes = @{NSFontAttributeName:_font,NSParagraphStyleAttributeName:paragraphStyle};
        _textView.attributedText = [[NSAttributedString alloc]initWithString:_textView.text attributes:attributes];
        _textView.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
        
    }
    return _textView;
}

- (UILabel *)placeholderLabel{
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.bgViewEdgeInsets.left + self.textEdge + 2.f, self.bgViewEdgeInsets.top + _textEdge, SCREEN_WIDTH - self.bgViewEdgeInsets.left - self.bgViewEdgeInsets.right -_textEdge * 2 - 2.f, ceil(self.font.lineHeight))];
        _placeholderLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _placeholderLabel.font = _font;
        _placeholderLabel.textColor = [UIColor colorWithHexString:@"#9A9A9A"];
    }
    return _placeholderLabel;
}

@end

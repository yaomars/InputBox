//
//  YYCommentsInputBox.h
//  InputBox
//
//  Created by yinyao on 2018/9/25.
//  Copyright © 2018年 yinyao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define SCREEN_WIDTH        [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT       [[UIScreen mainScreen] bounds].size.height
#define WEAKSELF            __weak __typeof(self)weakSelf = self;

@interface YYCommentsInputBox : UIView

///发送文本Block
@property (nonatomic,copy) void (^commentsInputBoxSendBlock)(YYCommentsInputBox *commentsInputBox, NSString *sendText);

///来源控制器(开启返回手势 或  禁用返回手势)
@property (nonatomic, weak) UIViewController *currentVC;

/**
 需要配置的属性（也可不传）
 */
@property(nonatomic,assign)BOOL         isDisableSlide;     //是否禁用侧滑功能（默认不禁用：NO）
@property(nonatomic,assign)BOOL         isDisappear;        //是否即将消失（有侧滑功能时，有效）
@property(nonatomic,assign)BOOL         isHiddenBottom;     //是否隐藏到底部(默认为YES)
@property(nonatomic,strong)UIFont       *font;              //设置字体大小(决定输入框的初始高度,默认为14号系统默认字体)
@property(nonatomic,assign)CGFloat      textEdge;           //文字显示上下左右间距（输入的文字显示距离背景颜色距离，默认为10.f）
@property(nonatomic,assign)UIEdgeInsets bgViewEdgeInsets;   //展示背景的view的内边距(默认为6.f, 15.f, 6.f, 15.f)
@property(nonatomic,assign)CGFloat      textLineSpacing;    //显示文字框中的行间距（默认为8.f）
@property(nonatomic,assign)int          maxLine;            //显示文字框中设置最大行数(默认为3)

///设置占位符
- (void)setPlaceholderText:(NSString *)text;

///设置好属性之后开始布局（在生命周期中最好只调用一次）
- (void)beginUpdateUI;

///开始弹键盘
- (void)startPopBox;

///退出键盘
- (void)endPopBox;

///发送成功后的处理
- (void)sendSuccessHandle;

@end

NS_ASSUME_NONNULL_END

//
//  YYCommentsVC.m
//  InputBox
//
//  Created by yinyao on 2018/9/26.
//  Copyright © 2018年 yinyao. All rights reserved.
//

#import "YYCommentsVC.h"
#import "YYCommentsInputBox.h"

@interface YYCommentsVC ()
///评论输入框
@property (nonatomic, strong)YYCommentsInputBox *commentsInputBox;
///展示发送内容的label
@property (weak, nonatomic)IBOutlet UILabel     *textLbl;

@property(nonatomic,assign)BOOL         isDisableSlide;     //是否禁用侧滑功能（默认不禁用：NO）
@property(nonatomic,assign)BOOL         isHiddenBottom;     //是否隐藏到底部(默认为YES)

@end

@implementation YYCommentsVC

- (void)dealloc {
    NSLog(@"YYCommentsVC - dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置默认值
    self.isHiddenBottom = YES;
    self.isDisableSlide = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _commentsInputBox.isDisappear = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _commentsInputBox.isDisappear = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_commentsInputBox endPopBox];
}

#pragma mark - 点击事件
///弹出评论框
- (IBAction)clickPopBoxButton:(UIButton *)sender {
    
    WEAKSELF;
    if (_commentsInputBox == nil) {
        [self.view addSubview:self.commentsInputBox];
        
        [_commentsInputBox setPlaceholderText:@"发送评论"];
        _commentsInputBox.currentVC = weakSelf;
        [_commentsInputBox beginUpdateUI];
    }
    
    _commentsInputBox.isDisableSlide = self.isDisableSlide;
    _commentsInputBox.isHiddenBottom = self.isHiddenBottom;
   
    [_commentsInputBox startPopBox];
}

///输入框是否隐藏到底部
- (IBAction)isHiddenInputBox:(UISwitch *)sender {
    
    self.isHiddenBottom = sender.isOn;
}

///是否禁用侧滑功能
- (IBAction)isDisableSlide:(UISwitch *)sender {
    
    self.isDisableSlide = sender.isOn;
}

#pragma mark - 私有方法
///发送评论
- (void)sendCommentsWithCommentContent:(NSString *)commentContent {
    
    self.textLbl.text = [self dealWithString:commentContent];
    
    [_commentsInputBox sendSuccessHandle];
    
}

///字符串处理
- (NSString *)dealWithString:(NSString *)str {
    if (str == nil) {
        return nil;
    }
    
    //1.首尾去空格和换行；
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //2.中间把换行替换成空格
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    return str;
}

#pragma mark - getter
- (YYCommentsInputBox *)commentsInputBox {
    if (!_commentsInputBox) {
        _commentsInputBox = [[YYCommentsInputBox alloc] init];
        [_commentsInputBox setPlaceholderText:@"发表评论"];
        WEAKSELF;
        _commentsInputBox.commentsInputBoxSendBlock = ^(YYCommentsInputBox *commentsInputBox, NSString *sendText) {
            NSLog(@"准备发送的原始内容：%@", sendText);
            [weakSelf sendCommentsWithCommentContent:sendText];
        };
    }
    return _commentsInputBox;
}

@end

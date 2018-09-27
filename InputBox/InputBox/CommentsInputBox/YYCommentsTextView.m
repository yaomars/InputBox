//
//  YYCommentsTextView.m
//  InputBox
//
//  Created by yinyao on 2018/9/25.
//  Copyright © 2018年 yinyao. All rights reserved.
//

#import "YYCommentsTextView.h"

@implementation YYCommentsTextView

/// 重写返回光标大小的方法（自定义UITextView文字字体时，经常出现光标与字体的高度不匹配）
- (CGRect)caretRectForPosition:(UITextPosition *)position {
    CGRect originalRect = [super caretRectForPosition:position];
    originalRect.size.height = ceil (self.font.lineHeight);
    return originalRect;
}

@end

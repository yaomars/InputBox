//
//  Utility.m
//  InputBox
//
//  Created by yinyao on 2018/9/25.
//  Copyright © 2018年 yinyao. All rights reserved.
//

#import "Utility.h"


@implementation Utility

///获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    UIViewController *vc = [[UIApplication sharedApplication].delegate window].rootViewController;
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)vc;
        if ([tab.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)tab.selectedViewController;
            result = nav.viewControllers.lastObject;
        }
    }
    else if ([vc isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *nav = (UINavigationController *)vc;
        result = nav.viewControllers.lastObject;
    }
    return result;
}


@end

//
//  UIAlertController+JLShow.m
//  JLPay
//
//  Created by jielian on 16/7/8.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "UIAlertController+JLShow.h"
#import "Define_Header.h"

@implementation UIAlertController (JLShow)

+ (void)showActSheetWithTitle:(NSString *)title
                      message:(NSString *)message
                       target:(id)target
                clickedHandle:(clickedIndex)clickedHandle
                      buttons:(NSDictionary *)buttons, ...
{
    if (title == nil) title = @"";
    if (message == nil) message = @"";
    UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    /* 解析所有的动态参数 */
    NSMutableArray* allArgBtns = [NSMutableArray array];
    va_list list;
    NSDictionary* btnNode;
    if (buttons) {
        [allArgBtns addObject:buttons];
        
        va_start(list, buttons);
        while ((btnNode = va_arg(list, NSDictionary*))) {
            [allArgBtns addObject:btnNode];
        }
        va_end(list);
    }
    
    /* 添加所有的点击按钮到controller */
    for (int i = 0 ; i < allArgBtns.count; i++) {
        NSDictionary* btn = allArgBtns[i];
        NSInteger style = [btn.allKeys.firstObject integerValue];
        NSString* btnTitle = btn.allValues.firstObject;
        UIAlertAction* btnAction = [UIAlertAction actionWithTitle:btnTitle style:style handler:^(UIAlertAction * _Nonnull action) {
            clickedHandle(action);
            [actionSheet dismissViewControllerAnimated:YES completion:^{
            }];
        }];
        [actionSheet addAction:btnAction];
    }
    
    /* 显示 */
    [target presentViewController:actionSheet animated:YES completion:^{
        
    }];
}


+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message target:(id)target clickedHandle:(clickedIndex)clickedHandle buttons:(NSDictionary *)buttons, ...
{
    if (title == nil) title = @"";
    if (message == nil) message = @"";
    UIAlertController* alertView = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    /* 解析所有的动态参数 */
    NSMutableArray* allArgBtns = [NSMutableArray array];
    va_list list;
    NSDictionary* btnNode;
    if (buttons) {
        [allArgBtns addObject:buttons];
        
        va_start(list, buttons);
        while ((btnNode = va_arg(list, NSDictionary*))) {
            [allArgBtns addObject:btnNode];
        }
        va_end(list);
    }
    
    /* 添加所有的点击按钮到controller */
    for (int i = 0 ; i < allArgBtns.count; i++) {
        NSDictionary* btn = allArgBtns[i];
        NSInteger style = [btn.allKeys.firstObject integerValue];
        NSString* btnTitle = btn.allValues.firstObject;
        UIAlertAction* btnAction = [UIAlertAction actionWithTitle:btnTitle style:style handler:^(UIAlertAction * _Nonnull action) {
            clickedHandle(action);
            [alertView dismissViewControllerAnimated:YES completion:^{
            }];
        }];
        [alertView addAction:btnAction];
    }
    
    /* 显示 */
    [target presentViewController:alertView animated:YES completion:^{
        
    }];
}

@end

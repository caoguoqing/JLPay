//
//  MViewSwitchManager.h
//  JLPay
//
//  Created by jielian on 16/10/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MViewSwitchManager : NSObject

+ (instancetype) manager;

+ (UIViewController*) mainViewController;

/* 重新刷新主界面+菜单界面的数据 */
- (void) refrashMainViewControllerDatas ;


/* 跳转: 登录 */
- (void) gotoLogin;

/* 跳转: 交易明细 */
- (void) gotoBillList;

/* 跳转: 绑定设备 */
- (void) gotoDeviceBinding;

/* 跳转: 刷卡 */
- (void) gotoTransWithMPos;

/* 跳转: 多商户 */
- (void) gotoBusinessSwitch;

/* 跳转: 我的卡包 */
- (void) gotoMyCreditcardChecking;

/* 跳转: 修改密码 */
- (void) gotoPasswordExchanging;

/* 跳转: 我的商户 */
- (void) gotoMyBusiness;

/* 跳转: 帮助与关于 */
- (void) gotoAssistance;


@end

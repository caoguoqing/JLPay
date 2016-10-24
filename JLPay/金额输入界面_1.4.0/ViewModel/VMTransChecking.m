//
//  VMTransChecking.m
//  JLPay
//
//  Created by jielian on 16/10/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMTransChecking.h"
#import "MCacheSavedLogin.h"
#import "MCacheT0Info.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ModelBusinessInfoSaved.h"
#import "ModelRateInfoSaved.h"
#import "ModelDeviceBindedInformation.h"
#import <RESideMenu.h>
#import "MainTransViewController.h"
#import "Define_Header.h"
#import "MViewSwitchManager.h"
#import "MTransMoneyCache.h"
#import "JCAlertView.h"


#import "BrushViewController.h"
#import "CodeScannerViewController.h"
#import "VMOtherPayType.h"

@implementation VMTransChecking



/* mpos交易的检查和跳转 */
+ (void) mposTransCheckingAndHandling {
    BOOL checked = YES;
    
    /* 1. 审核状态 */
    if (checked) {
        checked = [self businessStateChecked];
    }
    /* 2. 设备绑定 */
    if (checked) {
        checked = [self deviceConnectedChecked];
    }
    /* 3. 蓝牙开启 */
    if (checked) {
        checked = [self blueToothOpenedChecked];
    }
    /* 4. 金额 */
    if (checked) {
        checked = [self moneyAvilableChecked];
    }
    
    
    if (checked) {
        /* 5. t+0信息提示,并跳转 */
        if ([MCacheT0Info cache].T_0Enable) {
            [self T_0InfosAlertChecked];
        }
        /* 6. 多商户提示,并跳转 */
        else if ([ModelBusinessInfoSaved beenSaved]) {
            [self moreBusinessChecked];
        }
        /* 7. 多费率提示,并跳转 */
        else if ([ModelRateInfoSaved beenSaved]) {
            [self moreRateChecked];
        }
        else {
            // 直接跳转
            [self gotoMposTransVC];
        }
    }
}

/* 微信支付交易的检查和跳转 */
+ (void) wechatPayCheckingAndHandling {
    BOOL checked = YES;

    /* 1. 审核状态 */
    checked = [self businessStateChecked];
    
    /* 2. 金额 */
    if (checked) {
        checked = [self moneyWechatPayChecked];
    }
    
    /* 3. 跳转 */
    if (checked) {
        [[VMOtherPayType sharedInstance] setPayAmount:[NSString stringWithFormat:@"%.02lf", [MTransMoneyCache sharedMoney].curMoneyUniteYuan]];
        [[VMOtherPayType sharedInstance] setCurPayType:OtherPayTypeWechat];
        [[self mainVC].navigationController pushViewController:[[CodeScannerViewController alloc] initWithNibName:nil bundle:nil] animated:YES];
        [[MTransMoneyCache sharedMoney] resetMoneyToZero];
    }

}



# pragma mask : private funcs

/* 1. 审核状态 */
+ (BOOL) businessStateChecked {
    BOOL checked = YES;
    MCacheSignUpCheckState state = [[MCacheSavedLogin cache] checkedState];
    if (state == MCacheSignUpCheckStateChecking) {
        [UIAlertController showAlertWithTitle:@"商户正在审核,暂停交易"
                                      message:nil
                                       target:[self mainVC]
                                clickedHandle:^(UIAlertAction *action) {
            
        } buttons:@{@(UIAlertActionStyleDefault):@"知道了"},nil];
        checked = NO;
    }
    else if (state == MCacheSignUpCheckStateCheckRefused) {
        /* 审核不通过跳转'我的商户' */
        [UIAlertController showAlertWithTitle:@"商户审核不通过,请重新上传"
                                      message:nil
                                       target:[self mainVC]
                                clickedHandle:^(UIAlertAction *action) {
                                    if ([action.title isEqualToString:@"去上传"]) {
                                        [[MViewSwitchManager manager] gotoMyBusiness];
                                    }
                                } buttons:@{@(UIAlertActionStyleCancel):@"取消"}, @{@(UIAlertActionStyleDefault):@"去上传"},nil];
        checked = NO;
    }
    return checked;
}

/* 2. 设备绑定 */
+ (BOOL) deviceConnectedChecked {
    if ([ModelDeviceBindedInformation hasBindedDevice]) {
        return YES;
    } else {
        if ([[MCacheSavedLogin cache] terminalCount] > 0) {
            [UIAlertController showAlertWithTitle:@"设备未绑定，请先绑定设备"
                                          message:nil
                                           target:[self mainVC]
                                    clickedHandle:^(UIAlertAction *action) {
                                        if ([action.title isEqualToString:@"去绑定"]) {
                                            [[MViewSwitchManager manager] gotoDeviceBinding];
                                        }
                                    } buttons:@{@(UIAlertActionStyleCancel):@"取消"}, @{@(UIAlertActionStyleDefault):@"去绑定"},nil];
        } else {
            [UIAlertController showAlertWithTitle:@"您的商户暂未配置mpos终端号，请联系代理商或客服" message:nil target:[self mainVC] clickedHandle:^(UIAlertAction *action) {
                
            } buttons:@{@(UIAlertActionStyleDefault):@"知道了"}, nil];
        }
        return NO;
    }
}

/* 3. 蓝牙开启 */
+ (BOOL) blueToothOpenedChecked {
    if ([APPMainDelegate CBManager].state == CBManagerStatePoweredOn) {
        return YES;
    } else {
        [UIAlertController showAlertWithTitle:@"手机蓝牙未开启，请开启"
                                      message:nil
                                       target:[self mainVC]
                                clickedHandle:nil
                                      buttons:@{@(UIAlertActionStyleDefault):@"知道了"},nil];
        return NO;
    }
}


/* 4. 金额 */
+ (BOOL) moneyAvilableChecked {
    BOOL avilable = YES;
    CGFloat curMoneyYuan = [[MTransMoneyCache sharedMoney] curMoneyUniteYuan];
    if (curMoneyYuan < 0.0001) {
        [PublicInformation makeCentreToast:@"请输入金额!"];
        avilable = NO;
    }
    else {
        /* T+0 */
        if ([MCacheT0Info cache].T_0Enable ) {
            /* 输入金额超上限 */
            if (curMoneyYuan > [MCacheT0Info cache].amountAvilable) {
                NSString* message = [NSString stringWithFormat:@"当日可刷剩余额度:￥[%.02lf]", [MCacheT0Info cache].amountAvilable];
                [UIAlertController showAlertWithTitle:@"金额超限" message:message target:[self mainVC] clickedHandle:^(UIAlertAction *action) {
                    
                } buttons:@{@(UIAlertActionStyleDefault):@"知道了"}, nil];
                avilable = NO;
            }
            /* 输入金额超下限 */
            else if (curMoneyYuan < [MCacheT0Info cache].amountMinCust) {
                NSString* message = [NSString stringWithFormat:@"T+0最小消费额度:￥[%.02lf]", [MCacheT0Info cache].amountMinCust];
                [UIAlertController showAlertWithTitle:@"金额不足最小限额" message:message target:[self mainVC] clickedHandle:^(UIAlertAction *action) {
                    
                } buttons:@{@(UIAlertActionStyleDefault):@"知道了"}, nil];
                avilable = NO;
            }

        }
    }
    return avilable;
}

/* 4. 金额: 微信支付 */
+ (BOOL) moneyWechatPayChecked {
    BOOL avilable = YES;
    CGFloat curMoneyYuan = [[MTransMoneyCache sharedMoney] curMoneyUniteYuan];
    if (curMoneyYuan < 0.0001) {
        [PublicInformation makeCentreToast:@"请输入金额!"];
        avilable = NO;
    }
    return avilable;
}

/* 5. t+0信息提示 */
+ (void) T_0InfosAlertChecked {
    MCacheT0Info* t0Cache = [MCacheT0Info cache];
    if (t0Cache.T_0Enable) {
        NSMutableString* message = [NSMutableString string];
        [message appendFormat:@"单日限额:￥%.02lf\n", t0Cache.amountLimit];
        [message appendFormat:@"单笔最小限额:￥%.02lf\n", t0Cache.amountMinCust];
        [message appendFormat:@"单日可刷额度:￥%.02lf\n", t0Cache.amountAvilable];
        [message appendFormat:@"转账手续费:￥%.02lf", t0Cache.T_0ExtraFee];
        NameWeakSelf(wself);
        [JCAlertView showTwoButtonsWithTitle:@"T+0温馨提示" Message:message ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"取消" Click:^{
        } ButtonType:JCAlertViewButtonTypeDefault ButtonTitle:@"继续" Click:^{
            [wself gotoMposTransVC];
            dispatch_async(dispatch_get_main_queue(), ^{
            });
        }];
    }
}

/* 6. 多商户提示 */
+ (void) moreBusinessChecked {
    NameWeakSelf(wself);
    if ([ModelBusinessInfoSaved beenSaved]) {
        [UIAlertController showAlertWithTitle:@"您选择了指定商户,是否继续交易"
                                      message:[NSString stringWithFormat:@"[%@]", [ModelBusinessInfoSaved businessName]]
                                       target:[self mainVC]
                                clickedHandle:^(UIAlertAction *action) {
                                    if ([action.title isEqualToString:@"继续"]) {
                                        //
                                        [wself gotoMposTransVC];
                                    }
                                } buttons:@{@(UIAlertActionStyleCancel):@"取消"}, @{@(UIAlertActionStyleDefault):@"继续"},nil];
    }
}

/* 7. 多费率提示 */
+ (void) moreRateChecked {
    NameWeakSelf(wself);
    if ([ModelRateInfoSaved beenSaved]) {
        [UIAlertController showAlertWithTitle:@"您选择了指定费率,是否继续交易"
                                      message:[NSString stringWithFormat:@"[%@]", [ModelRateInfoSaved rateTypeSelected]]
                                       target:[self mainVC]
                                clickedHandle:^(UIAlertAction *action) {
                                    if ([action.title isEqualToString:@"继续"]) {
                                        //
                                        [wself gotoMposTransVC];
                                    }
                                } buttons:@{@(UIAlertActionStyleCancel):@"取消"}, @{@(UIAlertActionStyleDefault):@"继续"},nil];
    }
}



/* 跳转刷卡界面 */
+ (void) gotoMposTransVC {
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    BrushViewController* brushVC = [mainStoryBoard instantiateViewControllerWithIdentifier:@"brush"];
    [brushVC setStringOfTranType:TranType_Consume];
    [brushVC setSFloatMoney:[NSString stringWithFormat:@"%.02lf",[MTransMoneyCache sharedMoney].curMoneyUniteYuan]];
    [brushVC setSIntMoney:[NSString stringWithFormat:@"%012ld", [MTransMoneyCache sharedMoney].curMoneyUniteMinute]];

    [[self mainVC].navigationController pushViewController:brushVC animated:YES];
}



+ (MainTransViewController*) mainVC {
    RESideMenu* sideMenuVC = (RESideMenu*)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UINavigationController* navigationVC = (UINavigationController*)sideMenuVC.contentViewController;
    return (MainTransViewController*)[[navigationVC viewControllers] firstObject];
}




@end

//
//  VMBusinessFuncItems.h
//  JLPay
//
//  Created by jielian on 16/6/20.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


static NSString* const FuncItemTitleBusinessInfo    = @"商户基本信息";
static NSString* const FuncItemTitleTransList       = @"交易明细";
static NSString* const FuncItemTitleDeviceBinding   = @"设备绑定";
static NSString* const FuncItemTitleOrderDispatch   = @"立即到账";
static NSString* const FuncItemTitleRateSelecting   = @"费率选择";
static NSString* const FuncItemTitleCodeScanning    = @"扫码支付";
static NSString* const FuncItemTitleCardChecking    = @"卡验证";
static NSString* const FuncItemTitlePinModifying    = @"修改密码";
static NSString* const FuncItemTitleHelpAndUs       = @"帮助与关于";




@interface VMBusinessFuncItems : NSObject
< UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray* funcItemTitles;

@property (nonatomic, strong) NSMutableDictionary* iconsForTitles;

@property (nonatomic, strong) NSMutableDictionary* viewControllersForTitles;

@end

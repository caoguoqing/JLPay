//
//  MCacheSavedLogin.h
//  JLPay
//
//  Created by jielian on 16/10/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 * 缓存的保存和读取: 商户的登录信息
 */



/* 商户注册审核状态 */
typedef NS_ENUM(NSInteger, MCacheSignUpCheckState) {
    MCacheSignUpCheckStateChecked,              /* 审核通过 */
    MCacheSignUpCheckStateChecking,             /* 审核中 */
    MCacheSignUpCheckStateCheckRefused          /* 审核拒绝 */
};

static NSString* const kSettlementTypeT_0 = @"T+0";
static NSString* const kSettlementTypeT_1 = @"T+1";


@interface MCacheSavedLogin : NSObject

+ (instancetype) cache;

# pragma mask : 上送端

/* 用户名 */
@property (nonatomic, copy) NSString* userName;

/* 用户密码(密文) */
@property (nonatomic, copy) NSString* userPassword;

/* 版本号 */
@property (nonatomic, copy) NSString* appVersion;

/* 平台类型: 0:ios,1:android */
@property (nonatomic, copy) NSString* systemType;



# pragma mask : 下送端

/* 登陆标志 */
@property (nonatomic, assign) BOOL logined;

/* 商户编号 */
@property (nonatomic, copy) NSString* businessCode;

/* 商户名称 */
@property (nonatomic, copy) NSString* businessName;

/* 终端个数 */
@property (nonatomic, assign) NSInteger terminalCount;

/* 终端编号组 */
@property (nonatomic, copy) NSArray* terminalList;

/* 允许 T+0 标志 */
@property (nonatomic, assign) BOOL T_0_enable;

/* 允许 T+6,15,30 标志 */
@property (nonatomic, assign) BOOL T_N_enable;

/* 允许多费率标志 */
@property (nonatomic, assign) BOOL N_fee_enable;

/* 允许多商户标志 */
@property (nonatomic, assign) BOOL N_business_enable;

/* 审核状态 */
@property (nonatomic, assign) MCacheSignUpCheckState checkedState;

/* 拒绝原因 */
@property (nonatomic, copy) NSString* checkRefuseReason;

/* 邮箱 */
@property (nonatomic, copy) NSString* email;

@end

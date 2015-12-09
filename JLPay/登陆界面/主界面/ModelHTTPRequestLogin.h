//
//  ModelHTTPRequestLogin.h
//  JLPay
//
//  Created by jielian on 15/12/9.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ModelHTTPRequestLogin;


/* ----- 登陆上送字段名 ----- */
static NSString* const kFieldNameLoginUpUserID = @"userName"; // 登陆名
static NSString* const kFieldNameLoginUpUserPWD = @"passWord"; // 密码
static NSString* const kFieldNameLoginUpVersionNum = @"versionNum"; // 版本号
static NSString* const kFieldNameLoginUpSysFlag = @"sysFlag"; // 操作系统标志

/* ----- 登陆响应字段名 ----- */
static NSString* const kFieldNameLoginDownCode = @"code"; // 响应码
static NSString* const kFieldNameLoginDownMessage = @"message"; // 响应信息
static NSString* const kFieldNameLoginDownBusinessNum = @"mchtNo"; // 商户编号
static NSString* const kFieldNameLoginDownBusinessName = @"mchtNm"; // 商户名
static NSString* const kFieldNameLoginDownBusinessEmail = @"commEmail"; // 商户邮箱
static NSString* const kFieldNameLoginDownTerminalCount = @"termCount"; // 终端号个数
static NSString* const kFieldNameLoginDownTerminalList = @"TermNoList"; // 终端号列表:","分割
static NSString* const kFieldNameLoginDownRegisterInfo = @"registerInfoList"; // 注册信息

/* ----- 历史注册信息字段名 ----- */
static NSString* const kFieldNameLastRegistMchntNm = @"mchntNm"; // 商户名
static NSString* const kFieldNameLastRegistUserName = @"userName"; // 登陆名
static NSString* const kFieldNameLastRegistPassWord = @"passWord"; // 登陆密码
static NSString* const kFieldNameLastRegistIdentifyNo = @"identifyNo"; // 证件号
static NSString* const kFieldNameLastRegistTelNo = @"telNo"; // 电话号码
static NSString* const kFieldNameLastRegistSpeSettleDs = @"speSettleDs"; // 结算银行联行号
static NSString* const kFieldNameLastRegistSettleAcct = @"settleAcct"; // 结算账号
static NSString* const kFieldNameLastRegistSettleAcctNm = @"settleAcctNm"; // 结算账户名
static NSString* const kFieldNameLastRegistAreaNo = @"areaNo"; // 地区代码
static NSString* const kFieldNameLastRegistAddr = @"addr"; // 详细地址
static NSString* const kFieldNameLastRegistAgeUserName = @"ageUserName"; // 代理商名
static NSString* const kFieldNameLastRegistMail = @"mail"; // 邮箱
static NSString* const kFieldNameLastRegist03 = @"03"; // 身份证正面
static NSString* const kFieldNameLastRegist06 = @"06"; // 身份证反面
static NSString* const kFieldNameLastRegist08 = @"08"; // 银行卡正面
static NSString* const kFieldNameLastRegist09 = @"09"; // 手持身份证





/* 枚举: 错误表(登陆错误回调中判断) */
typedef enum {
    LoginErrorCodeTypeDefault = 99,             // 默认错误
    LoginErrorCodeTypeLowVersion = 701,         // 版本过低: 需下载新版本
    LoginErrorCodeTypeRegistRefuse = 802        // 注册审核拒绝: 需修改注册信息
} LoginErrorCodeType;



#pragma mask ---- ModelHTTPRequestLoginDelegate
@protocol ModelHTTPRequestLoginDelegate <NSObject>

/* 回调: 成功 */
- (void) didLoginSuccessWithLoginInfo:(NSDictionary*)loginInfo;

/* 回调: 失败(需判断错误表枚举量) */
- (void) didLoginFailWithErrorMessage:(NSString*)errorMessage andErrorType:(LoginErrorCodeType)errorType;

@end

#pragma mask ---- 接口部分
@interface ModelHTTPRequestLogin : NSObject

/* 公共入口 */
+ (instancetype) sharedInstance;

/* 登陆: 指定用户名、密码 */
- (void) loginWithUserID:(NSString*)userID
              andUserPWD:(NSString*)userPWD
                delegate:(id<ModelHTTPRequestLoginDelegate>)delegate;

/* 停止登陆 */
- (void) terminateLogin;

/* 历史注册信息: 错误表 == LoginErrorCodeTypeRegistRefuse 时 */
@property (nonatomic, strong) NSDictionary* lastRegisterInfo;

@end

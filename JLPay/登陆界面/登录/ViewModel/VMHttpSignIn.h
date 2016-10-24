//
//  VMHttpSignIn.h
//  JLPay
//
//  Created by jielian on 16/6/14.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Define_Header.h"
#import <ReactiveCocoa.h>

/* ----- 登陆上送字段名 ----- */
static NSString* const kFieldNameSignInUpUserID = @"userName";                  // 登陆名
static NSString* const kFieldNameSignInUpUserPWD = @"passWord";                 // 密码
static NSString* const kFieldNameSignInUpVersionNum = @"versionNum";            // 版本号
static NSString* const kFieldNameSignInUpSysFlag = @"sysFlag";                  // 操作系统标志

/* ----- 登陆响应字段名 ----- */
static NSString* const kFieldNameSignInDownCode = @"code";                      // 响应码
static NSString* const kFieldNameSignInDownMessage = @"message";                // 响应信息
static NSString* const kFieldNameSignInDownBusinessNum = @"mchtNo";             // 商户编号
static NSString* const kFieldNameSignInDownBusinessName = @"mchtNm";            // 商户名
static NSString* const kFieldNameSignInDownBusinessEmail = @"commEmail";        // 商户邮箱
static NSString* const kFieldNameSignInDownTerminalCount = @"termCount";        // 终端号个数
static NSString* const kFieldNameSignInDownTerminalList = @"TermNoList";        // 终端号列表:","分割
static NSString* const kFieldNameSignInDownAllowTypes = @"allowType";           // 允许标志
static NSString* const kFieldNameSignInDownCheckState = @"checkState";          // 审核标记
static NSString* const kFieldNameSignInDownRegisterInfo = @"registerInfoList";  // 注册信息


typedef  enum {
    VMSigninSpecialErrorTypeLowVersion = 701,
    VMSigninSpecialErrorTypeCheckStill = 801,
    VMSigninSpecialErrorTypeCheckRefuse = 802
} VMSigninSpecialErrorType;



@interface VMHttpSignIn : NSObject

/* 执行登录操作的命令 */
@property (nonatomic, strong) RACCommand* signInCommand;

/* 用户名 */
@property (nonatomic, copy) NSString* userNameStr;

/* 明文密码 */
@property (nonatomic, copy) NSString* userPwdStr;

/* 登录响应信息 */
@property (nonatomic, copy) NSDictionary* responseData;


@end

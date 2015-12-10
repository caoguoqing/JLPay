//
//  Define_Header.h
//  JLPay
//
//  Created by jielian on 15/3/30.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#ifndef JLPay_Define_Header_h
#define JLPay_Define_Header_h

#import "AppDelegate.h"
#import "PublicInformation.h"



// 自定义键盘的高度
#define CustomKeyboardHeight            216.0

// 数据库文件 - 全国地名及代码
#define DBFILENAME_AREACODE             @"test.db"

// 日志打印选项: 打印(1);不打印(0);
#define NeedPrintLog                    1

#define app_delegate  (AppDelegate*)([UIApplication sharedApplication].delegate)

/* 
 * 环境: 
 * 1: 生产环境(1),
 * 3: 内网测试75
 * 7: 内网测试72 (TCP + HTTP)
 * 0: 内网测试62,
 * 5: 内网测试50
 * 8: 内网开发环境-http
 * 9: 外网测试62
 */
#define TestOrProduce                   7


/* 版本分支配置(用于标示发布到appStore还是企业版的app)
 * 0: master: AppStore
 * 1: test:   网页企业版
 * 2: dev:    开发版
 */
#define TAG_OF_BRANCH_EDITION           2



/*************[设备操作相关的参数:]**************/
// 厂商设备类型
#define DeviceType                  @"DeviceType"               
#define DeviceType_JHL_A60          @"A60音频刷卡头A"
#define DeviceType_JHL_M60          @"M60蓝牙刷卡器"
#define DeviceType_RF_BB01          @"蓝牙刷卡头"
#define DeviceType_JLpay_TY01       @"JLpay蓝牙刷卡器"


/* ------------------------------ 信息字典: 选择的机构信息
 *  KeyInfoDictOfJiGouBusinessNum           - 机构商户号
 *  KeyInfoDictOfJiGouTerminalNum           - 机构终端号
 *  KeyInfoDictOfJiGouBusinessName          - 机构商户名
 ------------------------------*/
#define KeyInfoDictOfJiGou                      @"KeyInfoDictOfJiGou"               // 字典
#define KeyInfoDictOfJiGouBusinessNum           @"KeyInfoDictOfJiGouBusinessNum"
#define KeyInfoDictOfJiGouTerminalNum           @"KeyInfoDictOfJiGouTerminalNum"
#define KeyInfoDictOfJiGouBusinessName          @"KeyInfoDictOfJiGouBusinessName"
// 费率 - key; 值为int{0,1,2,3};
#define Key_RateOfPay   @"Key_RateOfPay"


/*************[注册审核未通过:响应配置信息]**************/
//#define  RESIGN_mchntNm                 @"RESIGN_mchntNm"
//#define  RESIGN_userName                @"RESIGN_userName"
//#define  RESIGN_passWord                @"RESIGN_passWord"
//#define  RESIGN_identifyNo              @"RESIGN_identifyNo"
//#define  RESIGN_telNo                   @"RESIGN_telNo"
//#define  RESIGN_speSettleDs             @"RESIGN_speSettleDs"
//#define  RESIGN_settleAcct              @"RESIGN_settleAcct"
//#define  RESIGN_settleAcctNm            @"RESIGN_settleAcctNm"
//#define  RESIGN_areaNo                  @"RESIGN_areaNo"
//#define  RESIGN_addr                    @"RESIGN_addr"
//#define  RESIGN_ageUserName             @"RESIGN_ageUserName"
//#define  RESIGN_mail                    @"RESIGN_mail"
//#define  RESIGN_03                      @"RESIGN_03"
//#define  RESIGN_06                      @"RESIGN_06"
//#define  RESIGN_08                      @"RESIGN_08"
//#define  RESIGN_09                      @"RESIGN_09"

#endif

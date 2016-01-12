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


#define AppLogoImageName                @"AppLogoImageJLPay"

// 自定义键盘的高度
#define CustomKeyboardHeight            216.0

// 日志打印选项: 打印(1);不打印(0);
#define NeedPrintLog                    0


/* ----------------------------
 * 环境: 
 * 1: 生产环境(1),
 * 3: 内网测试75
 * 7: 内网测试72 (TCP + HTTP)
 * 9: http 开发环境:(192.168.1.174:80)
 * ---------------------------- */
#define TestOrProduce                   1

/* ----------------------------
 * 版本分支配置(用于标示发布到appStore还是企业版的app)
 * 0: master: AppStore
 * 1: test:   网页企业版
 * 2: dev:    开发版
 * ---------------------------- */
#define TAG_OF_BRANCH_EDITION           1


/* ----------------------------
 * 枚举量: 交易平台类型
 * TransPlatformType
 * ---------------------------- */
typedef enum {
    TransPlatformType_MPOS = 1, // MPOS 刷卡交易
    TransPlatformType_OtherPay  // 第三方支付交易
} TransPlatformType ;


#endif

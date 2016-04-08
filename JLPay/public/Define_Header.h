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

#define NameWeakSelf(weakSelf)          __weak typeof(self) weakSelf = self;

// 自定义键盘的高度
#define CustomKeyboardHeight            216.0

// 日志打印选项: 打印(1);不打印(0);
#define NeedPrintLog                    1
#define JLPrint(fmt,...)    if (NeedPrintLog == 1) { NSLog(fmt,##__VA_ARGS__); }


/* ----------------------------
 * 环境: 
 * 1: 生产环境()            (TCP:28088,HTTP:80)
 * 2: 生产环境(2809)        (TCP:28090,HTTP:80)
 * 3: 内网测试75(2808)      (TCP:60701,HTTP:60780) -> new: (TCP:37580,HTTP:37588)
 * 5: 内网测试75(2809)      (TCP:60702,HTTP:60780) -> new: (TCP:37590,HTTP:37588)
 * 4: 内网测试76(2809)      (TCP:7690,HTTP:28090)  -> new: (TCP:37690,HTTP:37688)
 * 7: 内网测试72            (TCP + HTTP)
 * 9: http 开发环境:        (192.168.1.174:80)
 * 11: KFT:                (TCP:10090,HTTP:10088)
 * ---------------------------- */
#define TestOrProduce                   2

/* ----------------------------
 * 代码版本分支配置(用于标示发布到appStore还是企业版的app)
 * 0: master: AppStore
 * 1: test:   网页企业版
 * 2: dev:    开发版
 * ---------------------------- */
#define TAG_OF_BRANCH_EDITION           1


/* ----------------------------
 * app分支 : 需要同时修改 LaunchScreen.xib,Xcode->General,
 * 0: JLPay
 * 1: WeiLeShua
 * 2: OuErPay
 * 3: KFT (KuaiFuTong)
 * ---------------------------- */
#define BranchAppName                   0


/* ----------------------------
 * 报文类型: 从动联设备开始，上送的银联标准报文
 * 0: 标准
 * 1: 非标准(自定义)
 * ---------------------------- */
#define UnitStandardPacking             0



/* ----------------------------
 * 枚举量: 交易平台类型
 * TransPlatformType
 * ---------------------------- */
typedef enum {
    TransPlatformType_MPOS = 1, // MPOS 刷卡交易
    TransPlatformType_OtherPay  // 第三方支付交易
} TransPlatformType ;


#endif

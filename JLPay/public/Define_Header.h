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

#import "UIColor+HexColor.h"
#import "NSString+Formater.h"
#import "NSError+Custom.h"

#import <UINavigationBar+Awesome.h>

/* font string */
#import <NSString+FontAwesome.h>
#import <UIFont+FontAwesome.h>
#import "NSString+IconFont.h"
#import "UIFont+IconFont.h"


#define NameWeakSelf(weakSelf)          __weak typeof(self) weakSelf = self;

// 自定义键盘的高度
#define CustomKeyboardHeight            216.0

// 日志打印选项: 打印(1);不打印(0);
#define NeedPrintLog                    0
#define JLPrint(fmt,...)                if (NeedPrintLog == 1) { NSLog(fmt,##__VA_ARGS__); }



/* 环境配置: TestOrProduce
 * ---【代码】---【环境描述】-----------【IP-pos】---------【PORT_TCP-pos】---【PORT_HTTP-pos】
 *     :         :                   :                  :                 :
 *     1         produce(2808)       unitepay.com.cn    28088             80
 *     2         produce(2809)       unitepay.com.cn    28090             80
 *     3         75(2809)            202.104.101.126    60701             60780
 *     4         76(2809)            202.104.101.126    7690              28090
 *     5         75(2809)            202.104.101.126    60702             60780
 *     11        KFT                 unitepay.com.cn    10090             10088
 * --------------------------------------------------------------------------------------- */
#define TestOrProduce                   2


/* ----------------------------
 * 代码版本分支配置(用于标示发布到appStore还是企业版的app)
 * 0: master: AppStore
 * 1: test:   网页企业版
 * 2: dev:    开发版
 * ---------------------------- */
#define TAG_OF_BRANCH_EDITION           0


/* ----------------------------
 * app分支 : 需要同时修改 LaunchScreen.xib,Xcode->General,
 * 0: JLPay
 * 1: WeiLeShua
 * 2: OuErPay
 * 3: KFT (KuaiFuTong)
 * 5: ZhongJinMiaoShua(中金秒刷)
 * ---------------------------- */
#define BranchAppName                   0


/* ----------------------------
 * 报文类型: 从动联设备开始，上送的银联标准报文
 * 0: 标准
 * 1: 非标准(自定义)
 * ---------------------------- */
#define UnitStandardPacking             0




#endif

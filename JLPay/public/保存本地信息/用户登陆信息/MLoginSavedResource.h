//
//  MLoginSavedResource.h
//  JLPay
//
//  Created by jielian on 16/6/14.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "Define_Header.h"


static NSString* const kLoginSavedResourceName = @"kLoginSavedResourceName__";      // 登陆信息的本地持久化键名

typedef enum {
    BusinessCheckedStateChecked,          // 审核通过
    BusinessCheckedStateChecking,         // 审核中
    BusinessCheckedStateCheckRefused      // 审核拒绝
}BusinessCheckedState;




@interface MLoginSavedResource : NSObject

+ (instancetype) sharedLoginResource;

/* 是否已保存: 初始化时判断是否存在本地持久化配置 */
@property (nonatomic, assign) BOOL beenSaved;


/* --- 下列属性为登录界面输入项 --- */

@property (nonatomic, copy) NSString* userName;                                     /* 用户名 */
@property (nonatomic, copy) NSString* userPwdPan;                                   /* 密码 */
@property (nonatomic, assign) BOOL needSaving;                                      /* 是否保存标记 */

/* --- 下列属性为登录后台返回项 --- */

@property (nonatomic, copy) NSString* businessName;                                 /* 商户名 */
@property (nonatomic, copy) NSString* businessNumber;                               /* 商户编号 */
@property (nonatomic, copy) NSString* email;                                        /* 邮箱 */
@property (nonatomic, assign) NSInteger terminalCount;                              /* 终端号个数 */
@property (nonatomic, copy) NSArray* terminalList;                                  /* 终端号列表 */
@property (nonatomic, assign) BOOL T_0_enable;                                      /* 允许 T+0 标志 */
@property (nonatomic, assign) BOOL T_N_enable;                                      /* 允许 T+6,15,30 标志 */
@property (nonatomic, assign) BOOL N_fee_enable;                                    /* 允许多费率标志 */
@property (nonatomic, assign) BOOL N_business_enable;                               /* 允许多商户标志 */
@property (nonatomic, assign) BusinessCheckedState checkedState;                    /* 审核状态 */

@property (nonatomic, copy) NSString* checkedRefuseReason;                          /* 审核拒绝原因 (因目前商户查询接口未返回本字段，所以在登录时保存) */


/* 执行保存或覆盖 */
- (void) doSavingOnFinished:(void (^) (void))finishedBlock
                    onError:(void (^) (NSError* error))errorBlock;

@end

//
//  ModelUserLoginInformation.h
//  JLPay
//
//  Created by jielian on 15/11/25.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>



/***** 本类保存的信息只有一份 *****/



/* ---------- 键名定义区 ---------- */
static NSString* KeyLoginUpInfo = @"KeyLoginUpInfo__";
static NSString* KeyLoginUpInfoUserID = @"KeyLoginUpInfoUserID__";
static NSString* KeyLoginUpInfoUserPWD = @"KeyLoginUpInfoUserPWD__";
static NSString* KeyLoginUpInfoNeedSaveUserPWD = @"KeyLoginUpInfoNeedSaveUserPWD__";
static NSString* KeyLoginUpInfoNeedDisplayUserPWD = @"KeyLoginUpInfoNeedDisplayUserPWD__";

static NSString* KeyLoginDownInfo = @"KeyLoginDownInfo__";
static NSString* KeyLoginDownInfoBusinessName = @"KeyLoginDownInfoBusinessName__";
static NSString* KeyLoginDownInfoBusinessNumber = @"KeyLoginDownInfoBusinessNumber__";
static NSString* KeyLoginDownInfoBusinessEmail = @"KeyLoginDownInfoBusinessEmail__";
static NSString* KeyLoginDownInfoTerminalCount = @"KeyLoginDownInfoTerminalCount__";
static NSString* KeyLoginDownInfoTerminalNumbers = @"KeyLoginDownInfoTerminalNumbers__";
/* ------------------------------ */


@interface ModelUserLoginInformation : NSObject

#pragma mask ---- 增
/* 保存登陆上送信息 */
+ (BOOL) newLoginUpInfoWithUserID:(NSString*)userID // 登陆名
                          userPWD:(NSString*)userPWD // 登陆密码
                  needSaveUserPWD:(BOOL)needSaveUserPWD // 保存密码标记
               needDisplayUserPWD:(BOOL)needDisplayUserPWD; // 显示密码明文标记
/* 保存登陆响应信息 */
+ (BOOL) newLoginDownInfoWithBusinessName:(NSString*)businessName // 商户名
                           businessNumber:(NSString*)businessNumber // 商户编号
                            businessEmail:(NSString*)businessEmail // 商户邮箱
                            terminalCount:(NSString*)terminalCount // 终端号个数
                          terminalNumbers:(NSArray*)terminalNumbers; //终端号列表

#pragma mask ---- 删
/* 删除登陆上送信息 */
+ (void) deleteLoginUpInformation;
/* 删除登陆响应信息 */
+ (void) deleteLoginDownInformation;

#pragma mask ---- 改
/* 修改: 登陆密码 */
+ (void) updateUserPWD:(NSString*)userPWD;
/* 修改: 密码保存标记 */
+ (void) updateNeedSaveUserPWD:(BOOL)needSaveUserPWD;
/* 修改: 密码明文显示标记 */
+ (void) updateNeedDisplayUserPWD:(BOOL)needDisplayUserPWD;

#pragma mask ---- 查
/* 登陆上送信息查询 */
+ (NSDictionary*) informationOfLoginUp;
/* 登陆响应信息查询 */
+ (NSDictionary*) informationOfLoginDown;
/* 登陆用户名 */
+ (NSString*) userID;
/* 登陆密码:明文or密文 */
+ (NSString*) userPWD;
/* 密码保存标记 */
+ (BOOL) needSaveUserPWD;
/* 密码明文显示标记 */
+ (BOOL) needDisplayUserPWD;
/* 商户名 */
+ (NSString*) businessName;
/* 商户号 */
+ (NSString*) businessNumber;
/* 邮箱 */
+ (NSString*) businessEmail;
/* 终端号个数 */
+ (NSInteger) terminalCount;
/* 终端号列表 */
+ (NSArray*) terminalNumbers;


@end

//
//  ModelUserLoginInformation.m
//  JLPay
//
//  Created by jielian on 15/11/25.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ModelUserLoginInformation.h"


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


@implementation ModelUserLoginInformation


#pragma mask ---- 增
/* 保存登陆上送信息 */
+ (BOOL) newLoginUpInfoWithUserID:(NSString*)userID // 登陆名
                          userPWD:(NSString*)userPWD // 登陆密码
                  needSaveUserPWD:(BOOL)needSaveUserPWD // 保存密码标记
               needDisplayUserPWD:(BOOL)needDisplayUserPWD // 显示密码明文标记
{
    if (!userID || userID.length == 0) {
        return NO;
    }
    NSMutableDictionary* newInfo = [[NSMutableDictionary alloc] init];
    [newInfo setObject:userID forKey:KeyLoginUpInfoUserID];
    if (userPWD && userPWD.length > 0) {
        [newInfo setObject:userPWD forKey:KeyLoginUpInfoUserPWD];
    }
    [newInfo setObject:[NSNumber numberWithBool:needSaveUserPWD] forKey:KeyLoginUpInfoNeedSaveUserPWD];
    [newInfo setObject:[NSNumber numberWithBool:needDisplayUserPWD] forKey:KeyLoginUpInfoNeedDisplayUserPWD];
    [self writeLoginUpInfo:newInfo];
    return YES;
}
/* 保存登陆响应信息 */
+ (BOOL) newLoginDownInfoWithBusinessName:(NSString*)businessName // 商户名 nullNoabel
                           businessNumber:(NSString*)businessNumber // 商户编号 nullNoAble
                            businessEmail:(NSString*)businessEmail // 商户邮箱 nullable
                            terminalCount:(NSString*)terminalCount // 终端号个数 nullNoable
                          terminalNumbers:(NSArray*)terminalNumbers //终端号列表 nullable
{
    if (!businessName || !businessNumber || !terminalCount || businessName.length == 0 || businessNumber.length == 0 || terminalCount.length == 0) {
        return NO;
    }
    NSMutableDictionary* newInfo = [[NSMutableDictionary alloc] init];
    [newInfo setObject:businessName forKey:KeyLoginDownInfoBusinessName];
    [newInfo setObject:businessNumber forKey:KeyLoginDownInfoBusinessNumber];
    [newInfo setObject:businessEmail forKey:KeyLoginDownInfoBusinessEmail];
    [newInfo setObject:terminalCount forKey:KeyLoginDownInfoTerminalCount];
    if (terminalCount.intValue != 0 && terminalCount.intValue == terminalNumbers.count) {
        [newInfo setObject:terminalNumbers forKey:KeyLoginDownInfoTerminalNumbers];
    }
    [self writeLoginDownInfo:newInfo];
    return YES;
}

#pragma mask ---- 删
/* 删除登陆上送信息 */
+ (void) deleteLoginUpInformation {
    [self cleanLoginUpInfo];
}
/* 删除登陆响应信息 */
+ (void) deleteLoginDownInformation {
    [self cleanLoginDownInfo];
}

#pragma mask ---- 改
/* 修改: 登陆密码 */
+ (void) updateUserPWD:(NSString*)userPWD {
    if (!userPWD || userPWD.length == 0) {
        return;
    }
    NSDictionary* loginUpInfo = [self informationOfLoginUp];
    if (loginUpInfo) {
        NSMutableDictionary* newInfo = [NSMutableDictionary dictionaryWithDictionary:loginUpInfo];
        [newInfo setObject:userPWD forKey:KeyLoginUpInfoUserPWD];
        [self writeLoginUpInfo:newInfo];
    }
}
/* 修改: 密码保存标记 */
+ (void) updateNeedSaveUserPWD:(BOOL)needSaveUserPWD {
    NSDictionary* loginUpInfo = [self informationOfLoginUp];
    if (loginUpInfo) {
        NSMutableDictionary* newInfo = [NSMutableDictionary dictionaryWithDictionary:loginUpInfo];
        [newInfo setObject:[NSNumber numberWithBool:needSaveUserPWD] forKey:KeyLoginUpInfoNeedSaveUserPWD];
        [self writeLoginUpInfo:newInfo];
    }
}
/* 修改: 密码明文显示标记 */
+ (void) updateNeedDisplayUserPWD:(BOOL)needDisplayUserPWD {
    NSDictionary* loginUpInfo = [self informationOfLoginUp];
    if (loginUpInfo) {
        NSMutableDictionary* newInfo = [NSMutableDictionary dictionaryWithDictionary:loginUpInfo];
        [newInfo setObject:[NSNumber numberWithBool:needDisplayUserPWD] forKey:KeyLoginUpInfoNeedDisplayUserPWD];
        [self writeLoginUpInfo:newInfo];
    }
}

#pragma mask ---- 查
/* 登陆上送信息查询 */
+ (NSDictionary*) informationOfLoginUp {
    NSDictionary* information = nil;
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    information = [userDefault objectForKey:KeyLoginUpInfo];
    return information;
}
/* 登陆响应信息查询 */
+ (NSDictionary*) informationOfLoginDown {
    NSDictionary* information = nil;
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    information = [userDefault objectForKey:KeyLoginDownInfo];
    return information;
}
/* 登陆用户名 */
+ (NSString*) userID {
    NSString* userid = nil;
    NSDictionary* loginUpInfo = [self informationOfLoginUp];
    if (loginUpInfo) {
        userid = [loginUpInfo objectForKey:KeyLoginUpInfoUserID];
    }
    return userid;
}
/* 登陆密码:密文 */
+ (NSString*) userPWD {
    NSString* userpwd = nil;
    NSDictionary* loginUpInfo = [self informationOfLoginUp];
    if (loginUpInfo) {
        userpwd = [loginUpInfo objectForKey:KeyLoginUpInfoUserPWD];
    }
    return userpwd;
}
/* 密码保存标记 */
+ (BOOL) needSaveUserPWD {
    BOOL needsave = NO;
    NSDictionary* loginUpInfo = [self informationOfLoginUp];
    if (loginUpInfo) {
        needsave = [[loginUpInfo objectForKey:KeyLoginUpInfoNeedSaveUserPWD] boolValue];
    }
    return needsave;
}
/* 密码明文显示标记 */
+ (BOOL) needDisplayUserPWD {
    BOOL needdisplay = NO;
    NSDictionary* loginUpInfo = [self informationOfLoginUp];
    if (loginUpInfo) {
        needdisplay = [[loginUpInfo objectForKey:KeyLoginUpInfoNeedDisplayUserPWD] boolValue];
    }
    return needdisplay;
}
/* 商户名 */
+ (NSString*) businessName {
    NSString* businessname = nil;
    NSDictionary* loginDownInfo = [self informationOfLoginDown];
    if (loginDownInfo) {
        businessname = [loginDownInfo objectForKey:KeyLoginDownInfoBusinessName];
    }
    return businessname;
}
/* 商户号 */
+ (NSString*) businessNumber {
    NSString* businessno = nil;
    NSDictionary* loginDownInfo = [self informationOfLoginDown];
    if (loginDownInfo) {
        businessno = [loginDownInfo objectForKey:KeyLoginDownInfoBusinessNumber];
    }
    return businessno;
}
/* 邮箱 */
+ (NSString*) businessEmail {
    NSString* businessemail = nil;
    NSDictionary* loginDownInfo = [self informationOfLoginDown];
    if (loginDownInfo) {
        businessemail = [loginDownInfo objectForKey:KeyLoginDownInfoBusinessEmail];
    }
    return businessemail;
}
/* 终端号个数 */
+ (NSInteger) terminalCount {
    NSInteger count = 0;
    NSDictionary* loginDownInfo = [self informationOfLoginDown];
    if (loginDownInfo) {
        count = [[loginDownInfo objectForKey:KeyLoginDownInfoTerminalCount] integerValue];
    }
    return count;
}
/* 终端号列表 */
+ (NSArray*) terminalNumbers {
    NSArray* terminals = nil;
    NSDictionary* loginDownInfo = [self informationOfLoginDown];
    if (loginDownInfo && [self terminalCount] > 0) {
        terminals = [loginDownInfo objectForKey:KeyLoginDownInfoTerminalNumbers];
    }
    return terminals;
}

#pragma mask ---- PRIVATE INTERFACE
/* 清除登陆上送信息 */
+ (void) cleanLoginUpInfo {
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary* loginUpInfo = [self informationOfLoginUp];
    if (loginUpInfo) {
        [userDefault removeObjectForKey:KeyLoginUpInfo];
        [userDefault synchronize];
    }
}
/* 写入登陆上送信息 */
+ (void) writeLoginUpInfo:(NSDictionary*)loginUpInfo {
    if (!loginUpInfo) {
        return;
    }
    [self cleanLoginUpInfo];
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:loginUpInfo forKey:KeyLoginUpInfo];
    [userDefault synchronize];
}
/* 清除登陆响应信息 */
+ (void) cleanLoginDownInfo {
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary* loginUpInfo = [self informationOfLoginDown];
    if (loginUpInfo) {
        [userDefault removeObjectForKey:KeyLoginDownInfo];
        [userDefault synchronize];
    }
}
/* 写入登陆响应信息 */
+ (void) writeLoginDownInfo:(NSDictionary*)loginDownInfo {
    if (!loginDownInfo) {
        return;
    }
    [self cleanLoginDownInfo];
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:loginDownInfo forKey:KeyLoginDownInfo];
    [userDefault synchronize];
}

@end

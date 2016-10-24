//
//  MLocalConfigLogin.h
//  JLPay
//
//  Created by jielian on 16/10/11.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 * 本地持久化的保存和读取: 登陆界面信息
 */


@interface MLocalConfigLogin : NSObject


# pragma mask : properties

/* 用户名 */
@property (nonatomic, copy) NSString* userName;

/* 用户密码(密文) */
@property (nonatomic, copy) NSString* userPassword;

/* 是否保存密码 */
@property (nonatomic, assign) BOOL pwdNeedSaved;

/* 密码是否可见 */
@property (nonatomic, assign) BOOL pwdNeedSeen;


# pragma mask : funcs

/* 单例 */
+ (instancetype) sharedConfig;

/* 是否保存配置 */
- (BOOL) hasBeenSaved;

/* 重新读取配置 */
- (void) reReadConfig;

/* 重写配置 */
- (void) reWriteConfig;

/* 清空配置 */
- (void) clearConfig;


@end

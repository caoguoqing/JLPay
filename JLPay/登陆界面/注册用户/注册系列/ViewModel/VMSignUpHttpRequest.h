//
//  VMSignUpHttpRequest.h
//  JLPay
//
//  Created by jielian on 16/7/21.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>


@class RACSignal;
@class RACCommand;

@interface VMSignUpHttpRequest : NSObject


@property (nonatomic, copy) NSString* mchntNm;                      /* 商户名 */
@property (nonatomic, copy) NSString* userName;                     /* 登录名=手机号 */
@property (nonatomic, copy) NSString* passWord;                     /* 密码 */
@property (nonatomic, copy) NSString* identifyNo;                   /* 身份证号 */
@property (nonatomic, copy) NSString* telNo;                        /* 电话号码 */
@property (nonatomic, copy) NSString* speSettleDs;                  /* 结算账户行 */
@property (nonatomic, copy) NSString* settleAcct;                   /* 结算卡号 */
@property (nonatomic, copy) NSString* settleAcctNm;                 /* 结算账户名 */
@property (nonatomic, copy) NSString* openStlno;                    /* 结算银行号 */
@property (nonatomic, copy) NSString* areaNo;                       /* 地区代码 */
@property (nonatomic, copy) NSString* addr;                         /* 详细地址 */
@property (nonatomic, copy) NSString* ageUserName;                  /* 绑定SN号 */


@property (nonatomic, copy) UIImage* img_03;                        /* 身份证正面照 */
@property (nonatomic, copy) UIImage* img_06;                        /* 身份证反面照 */
@property (nonatomic, copy) UIImage* img_08;                        /* 结算卡正面照 */
@property (nonatomic, copy) UIImage* img_09;                        /* 身份证手持照 */


@property (nonatomic, strong) RACCommand* cmdHttpRequesting;
@property (nonatomic, strong) RACSignal* sigHttpRequesting;

@end

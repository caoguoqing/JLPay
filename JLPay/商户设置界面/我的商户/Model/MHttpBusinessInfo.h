//
//  MHttpBusinessInfo.h
//  JLPay
//
//  Created by jielian on 16/5/5.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPInstance.h"
#import "Define_Header.h"
#import "MD5Util.h"


static NSString* const MHttpBusinessKeyUserName         = @"userName";              // 登录名

static NSString* const MHttpBusinessKeyMchtStatus       = @"mchtStatus";            // 商户状态

static NSString* const MHttpBusinessKeyMchntNm          = @"mchtNm";                // 商户名
static NSString* const MHttpBusinessKeyMchtNo           = @"mchtNo";                // 商户编号
static NSString* const MHttpBusinessKeyIdentifyNo       = @"identifyNo";            // 身份证号码
static NSString* const MHttpBusinessKeyTelNo            = @"telNo";                 // 手机号码
static NSString* const MHttpBusinessKeyMail             = @"commEmail";             // 邮箱

static NSString* const MHttpBusinessKeySpeSettleDs      = @"speSettleDs";           // 结算账户银行
static NSString* const MHttpBusinessKeyOpenStlno        = @"openStlno";             // 开户行联行号
static NSString* const MHttpBusinessKeySettleAcct       = @"settleAcct";            // 结算账号

static NSString* const MHttpBusinessKeyAreaNo           = @"areaNo";                // 地区代码
static NSString* const MHttpBusinessKeyAddr             = @"addr";                  // 商户所在地址


@interface MHttpBusinessInfo : NSObject

+ (instancetype) sharedVM;

@property (nonatomic, strong) NSMutableDictionary* businessInfo;

- (void) requestBusinessInfoOnFinished:(void (^) (void))finished
                          onErrorBlock:(void (^) (NSError* error))errorBlock;

- (void) stopRequest;


@property (nonatomic, strong) HTTPInstance* http;
@end

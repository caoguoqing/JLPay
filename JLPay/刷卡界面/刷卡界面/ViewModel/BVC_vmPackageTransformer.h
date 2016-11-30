//
//  BVC_vmPackageTransformer.h
//  JLPay
//
//  Created by jielian on 2016/11/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface BVC_vmPackageTransformer : NSObject

/* 卡数据          : in */
@property (nonatomic, copy) NSDictionary* cardInfo;

/* 交易金额         : in */
@property (nonatomic, copy) NSString* sIntMoney;

/* 是否ic卡        : out */
@property (nonatomic, assign) BOOL cardIsIC;

/* 密文密码         : in */
@property (nonatomic, copy) NSString* pinEncrypted;

/* mac加密串       : in */
@property (nonatomic, copy) NSString* macCalculated;

/* 消费响应数据       : in */
@property (nonatomic, copy) NSDictionary* consumeResponseInfo;

/* 签名特征码        : out */
@property (nonatomic, copy) NSString* characteristicCode;

/* mac原始串       : out */
- (NSString*) macSourceMaking;

/* 消费报文串        : out */
- (NSString*) consumeMessageMaking;

/* 签名报文串        : out */
- (NSString*) elecSignMessageMaking;


@end

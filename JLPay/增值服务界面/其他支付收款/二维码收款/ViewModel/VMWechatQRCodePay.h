//
//  VMWechatQRCodePay.h
//  JLPay
//
//  Created by jielian on 16/5/12.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPInstance.h"
#import "Define_Header.h"
#import "ViewModelQRImageMaker.h"
#import <ReactiveCocoa.h>
#import "MD5Util.h"


typedef enum {
    VMWechatQRCodeRequestPre,           // 预备
    VMWechatQRCodeRequesting,           // 申请二维码
    VMWechatQRCodeRequestedSuc,         // 申请成功
    VMWechatQRCodeRequestedFail,        // 申请失败
    VMWechatPayStateEnquiring,          // 轮询交易结果
    VMWechatPayStateSuc,                // 交易成功
    VMWechatPayStateFail                // 交易失败
}VMWechatQRPayState;


@interface VMWechatQRCodePay : NSObject


# pragma mask 0 PUBLIC
@property (nonatomic, assign) VMWechatQRPayState state;             // 状态: KVO 控制流程

@property (nonatomic, copy) NSString* payMoney;                     // 交易金额
@property (nonatomic, copy) NSString* payGoodsName;                 // 商品名称
@property (nonatomic, strong) NSString* stateMessage;               // 仅交易成功、失败时设置: 

@property (nonatomic, strong) UIImage* QRCodeImage;                 // 二维码图片

@property (nonatomic, copy) NSError* error;

# pragma mask 1 PRIVATE

@property (nonatomic, strong) HTTPInstance* httpQRCode;
@property (nonatomic, strong) HTTPInstance* httpEnquiring;

@property (nonatomic, strong) NSArray* keyQRCodeRequestList;        // 二维码申请http的上送字段名组
@property (nonatomic, strong) NSArray* keyPayEnquireList;           // 二维码交易结果http的上送字段名组

@property (nonatomic, strong) NSMutableDictionary* httpQRCodeResult;       // 二维码申请结果信息

@end

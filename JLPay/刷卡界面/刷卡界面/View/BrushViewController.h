//
//  BrushViewController.h
//  JLPay
//
//  Created by jielian on 15/4/14.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define_Header.h"
#import "PosInformationViewController.h"
#import "DeviceManager.h"
#import "Packing8583.h"
#import "ViewModelTCPPosTrans.h"
#import "BalanceEnquiryViewController.h"
#import "ModelDeviceBindedInformation.h"
#import "ModelSettlementInformation.h"
#import "ModelTCPTransPacking.h"
#import "Masonry.h"
#import "VMDeviceHandle.h"
#import <ReactiveCocoa.h>

@interface BrushViewController : UIViewController
<
//CustomIOSAlertViewDelegate,
ViewModelTCPPosTransDelegate,
UIAlertViewDelegate
>
{
    NSString* curTransType;
}



@property (nonatomic, strong) NSString* stringOfTranType;               // 交易类型:消费、撤销、退货
@property (nonatomic, strong) NSString* sIntMoney;                      // 无小数点格式金额
@property (nonatomic, strong) NSString* sFloatMoney;                    // 有小数点格式金额



@property (nonatomic, strong) ViewModelTCPPosTrans* tcpViewModel;           // TCP交易中转
@property (nonatomic, strong) VMDeviceHandle* deviceManager;

@property (nonatomic, strong) UIActivityIndicatorView* activity;            // 刷卡状态的指示器


@property (nonatomic, strong) UILabel* waitingLabel;                        // 动态文本框
@property (nonatomic, strong) UILabel* moneyLabel;                          // 金额显示框
@property (nonatomic, assign) CGFloat leftInset;                            // 动态文本区域的左边静态文本区域的右边界长度


@property (nonatomic, strong) NSTimer* waitingTimer;                        // 控制定时器

@property (nonatomic, retain) NSMutableDictionary* cardInfoOfReading;       // 读到得卡数据
@property (nonatomic, copy) NSDictionary* transResponseInfo;                // 交易响应信息
@property (nonatomic, assign) int timeOut;                                  // 交易超时时间
@end

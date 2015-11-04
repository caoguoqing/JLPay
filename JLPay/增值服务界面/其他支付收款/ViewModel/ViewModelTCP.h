//
//  ViewModelTCP.h
//  JLPay
//
//  Created by jielian on 15/11/2.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//  二维码/条码支付的TCP操作类:
//      -- 二维码请求(支付宝/微信)
//      -- 二维码订单结果查询(支付宝/微信)
//      -- 条形码收款(支付宝/微信)



#import <Foundation/Foundation.h>


#define TranType_QRCode_Request_Alipay     @"TranType_QRCode_Request_Alipay__"          // 二维码获取: 支付宝
#define TranType_QRCode_Request_WeChat     @"TranType_QRCode_Request_WeChat__"          // 二维码获取: 微信
#define TranType_QRCode_Review_Alipay      @"TranType_QRCode_Review_Alipay__"           // 二维码订单结果查询: 支付宝
#define TranType_QRCode_Review_WeChat      @"TranType_QRCode_Review_WeChat__"           // 二维码订单结果查询: 微信

#define TranType_BarCode_Trans_Alipay     @"TranType_BarCode_Trans_Alipay__"            // 条形码获取: 支付宝
#define TranType_BarCode_Trans_WeChat     @"TranType_BarCode_Trans_WeChat__"            // 条形码获取: 微信


#define KeyResponseDataMessage             @"KeyResponseDataMessage__"                  // KEY: 错误信息
#define KeyResponseDataRetData             @"KeyResponseDataRetData__"                  // KEY: 成功返回的数据(二维码、条形码)
#define KeyResponseDataTranType             @"KeyResponseDataTranType__"                // KEY: 交易类型



@class ViewModelTCP;
@protocol ViewModelTCPDelegate <NSObject>

@required
/* TCP响应结果: 
 * responseData:{
 *    KeyResponseDataMessage (if state == NO),
 *    KeyResponseDataRetData
 *    KeyResponseDataTranType
 * }
 */
//- (void) TCPResponseWithState:(BOOL)state andData:(NSDictionary*)responseData;
- (void) TCPResponse:(ViewModelTCP*)tcp withState:(BOOL)state andData:(NSDictionary*)responseData;

@end



@interface ViewModelTCP : NSObject

/*
 * TCP请求: 包括打包
 */
- (void) TCPRequestWithTransType:(NSString*)transType
                        andMoney:(NSString*)money
                    andOrderCode:(NSString*)orderCode
                     andDelegate:(id<ViewModelTCPDelegate>)delegate;

/* 连接状态 */
- (BOOL) isConnected;

/* 清空TCP */
- (void) TCPClear ;


@end

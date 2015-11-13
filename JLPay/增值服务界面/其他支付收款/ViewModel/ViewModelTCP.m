//
//  ViewModelTCP.m
//  JLPay
//
//  Created by jielian on 15/11/2.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ViewModelTCP.h"
#import "Packing8583.h"
#import "Unpacking8583.h"
#import "EncodeString.h"
#import "Define_Header.h"
#import "TcpClientService.h"

@interface ViewModelTCP()<wallDelegate, Unpacking8583Delegate>
@property (nonatomic, strong) TcpClientService* tcpHolder;
@property (nonatomic, weak) id<ViewModelTCPDelegate>delegate;
@property (nonatomic, strong) NSString* transType;
@end

@implementation ViewModelTCP

#pragma mask ---- 初始化
- (instancetype)init {
    self = [super init];
    if (self) {
        self.tag = 0;
        // 注意: 这里的TCP不要用单例模式创建
        self.tcpHolder = [[TcpClientService alloc] init];
    }
    return self;
}
- (void)dealloc {
    if ([self.tcpHolder isConnect]) {
        [self.tcpHolder clearDelegateAndClose];
        self.tcpHolder = nil;
    }
}

#pragma mask ---- TCP请求
- (void) TCPRequestWithTransType:(NSString*)transType
                        andMoney:(NSString*)money
                    andOrderCode:(NSString*)orderCode
                     andDelegate:(id<ViewModelTCPDelegate>)delegate
{
    self.delegate = delegate;
    self.transType = transType;
    // 打包并发送请求
    [self.tcpHolder sendOrderMethod:[self stringPackingWithTransType:transType andMoney:money andOrderCode:orderCode]
                                 IP:Current_IP
                               PORT:Current_Port
                           Delegate:self
                             method:transType];
}


#pragma mask ---- 连接状态
- (BOOL) isConnected {
    BOOL connected = NO;
    if (self.tcpHolder) {
        connected = [self.tcpHolder isConnect];
    }
    return connected;
}



#pragma mask ---- 清空TCP
- (void) TCPClear {
    self.delegate = nil;
    [self.tcpHolder clearDelegateAndClose];
    self.tcpHolder = nil;
}


#pragma mask ---- wallDelegate
/* TCP请求成功 */
- (void)receiveGetData:(NSString *)data method:(NSString *)str {
    if ([data length] > 0) {
        // 拆包
        [[Unpacking8583 getInstance] unpacking8583:data withDelegate:self];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(TCPResponse:withState:andData:)]) {
            [self.delegate TCPResponse:self withState:NO andData:[self dictRetErrorMessage:@"网络异常，请检查网络"]];
        }
    }
    if (!self) {
        NSLog(@"当前TCP节点对象已经被释放了");
    }
}

/* TCP请求失败 */
- (void)falseReceiveGetDataMethod:(NSString *)str {
    if (self.delegate && [self.delegate respondsToSelector:@selector(TCPResponse:withState:andData:)]) {
        // 如果断开了连接，这里的self打印出来就跟原始的不一样了
        [self.delegate TCPResponse:self withState:NO andData:[self dictRetErrorMessage:@"网络异常，请检查网络"]];
    }
}



#pragma mask ---- Unpacking8583Delegate
// 解包结果:成功或失败;如果失败,带回错误信息
- (void) didUnpackDatas:(NSDictionary*)dataDict onState:(BOOL)state withErrorMsg:(NSString*)message {
    NSDictionary* retDataInfo = nil;
    NSString* f63 = [dataDict objectForKey:@"63"];
    if (f63) {
        retDataInfo = [self dictRetData:[f63 substringFromIndex:4] andErrorMessage:message];
    } else {
        retDataInfo = [self dictRetData:@"" andErrorMessage:message];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(TCPResponse:withState:andData:)]) {
        [self.delegate TCPResponse:self withState:state andData:retDataInfo];
    }
}

/* 封装响应信息: 失败的 */
- (NSDictionary*) dictRetErrorMessage:(NSString*)errorMessage {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:errorMessage forKey:KeyResponseDataMessage];
    [dict setObject:@"" forKey:KeyResponseDataRetData];
    [dict setObject:self.transType forKey:KeyResponseDataTranType];
    return dict;
}
/* 封装响应信息: 成功的 */
- (NSDictionary*) dictRetData:(NSString*)retData {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:@"" forKey:KeyResponseDataMessage];
    [dict setObject:retData forKey:KeyResponseDataRetData];
    [dict setObject:self.transType forKey:KeyResponseDataTranType];
    return dict;
}
/* 封装响应信息: 成功的+失败的 */
- (NSDictionary*) dictRetData:(NSString*)retData andErrorMessage:(NSString*)errorMessage {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:errorMessage forKey:KeyResponseDataMessage];
    [dict setObject:retData forKey:KeyResponseDataRetData];
    [dict setObject:self.transType forKey:KeyResponseDataTranType];
    return dict;
}


#pragma mask ---- 打包
/* PACKING */
- (NSString*) stringPackingWithTransType:(NSString*)transType
                                andMoney:(NSString*)money
                            andOrderCode:(NSString*)orderCode
{
    NSString* strPacking = nil;
    NSString* stringDateAndTime = [PublicInformation currentDateAndTime];
    Packing8583* packingHolder = [Packing8583 sharedInstance];
    [packingHolder setHeader:@"603100114301"];
    [packingHolder setFieldAtIndex:3 withValue:[self processingCodeWithTransType:transType]];
    [packingHolder setFieldAtIndex:4 withValue:[self sIntMoneyOfFloatMoney:money]];
    [packingHolder setFieldAtIndex:11 withValue:[PublicInformation exchangeNumber]];
    [packingHolder setFieldAtIndex:12 withValue:[stringDateAndTime substringWithRange:NSMakeRange(8, 6)]];
    [packingHolder setFieldAtIndex:13 withValue:[stringDateAndTime substringWithRange:NSMakeRange(4, 4)]];
    [packingHolder setFieldAtIndex:41 withValue:[EncodeString encodeASC:[PublicInformation returnTerminal]]];
    [packingHolder setFieldAtIndex:42 withValue:[EncodeString encodeASC:[PublicInformation returnBusiness]]];
    [packingHolder setFieldAtIndex:49 withValue:[EncodeString encodeASC:@"156"]];
    [packingHolder setFieldAtIndex:63 withValue:[self f63WithTransType:transType andOrderCode:orderCode]];
    [packingHolder setFieldAtIndex:64 withValue:@"0000000000000000"];
    
    strPacking = [packingHolder stringPackingWithType:@"0300"];
    return strPacking;
}
/* F03: 根据交易类型返回不同 */
- (NSString*) processingCodeWithTransType:(NSString*)transType {
    NSString* processingCode = nil;
    if ([transType isEqualToString:TranType_QRCode_Request_Alipay] ||
        [transType isEqualToString:TranType_QRCode_Request_WeChat] ||
        [transType isEqualToString:TranType_BarCode_Trans_Alipay] ||
        [transType isEqualToString:TranType_BarCode_Trans_WeChat]
        )
    {
        processingCode = @"000000";
    }
    else if ([transType isEqualToString:TranType_QRCode_Review_Alipay] ||
             [transType isEqualToString:TranType_QRCode_Review_WeChat] ||
             [transType isEqualToString:TranType_BarCode_Review_Alipay] ||
             [transType isEqualToString:TranType_BarCode_Review_WeChat]
             )
    {
        processingCode = @"310000";
    }
    return processingCode;
}
/* 小数点型金额转换为整型金额 */
- (NSString*) sIntMoneyOfFloatMoney:(NSString*)floatMoney {
    NSString* sIntMoney = nil;
    NSString* sInt = [floatMoney substringToIndex:[floatMoney rangeOfString:@"."].location];
    NSString* sFloat = [floatMoney substringFromIndex:[floatMoney rangeOfString:@"."].location + 1];
    sIntMoney = [NSString stringWithFormat:@"%012d",sInt.intValue * 100 + sFloat.intValue];
    return sIntMoney;
}
/* F63: 根据交易类型+订单号组合 */
- (NSString*) f63WithTransType:(NSString*)transType andOrderCode:(NSString*)orderCode {
    NSMutableString* f63 = [[NSMutableString alloc] init];
    [f63 appendString:[self codeTypeWithTransType:transType]];
    if ([transType isEqualToString:TranType_QRCode_Review_Alipay] ||
        [transType isEqualToString:TranType_QRCode_Review_WeChat] ||
        [transType isEqualToString:TranType_BarCode_Trans_Alipay] ||
        [transType isEqualToString:TranType_BarCode_Trans_WeChat] ||
        [transType isEqualToString:TranType_BarCode_Review_Alipay] ||
        [transType isEqualToString:TranType_BarCode_Review_WeChat]
        )
    {
        [f63 appendString:[EncodeString encodeASC:orderCode]];
    }
    return f63;
}
/* codeType */
- (NSString*) codeTypeWithTransType:(NSString*)transType {
    NSString* codeType = nil;
    if ([transType isEqualToString:TranType_QRCode_Request_WeChat] ||
        [transType isEqualToString:TranType_QRCode_Review_WeChat]
        )
    {
        codeType = @"03";
    }
    else if ([transType isEqualToString:TranType_QRCode_Request_Alipay] ||
             [transType isEqualToString:TranType_QRCode_Review_Alipay]
             )
    {
        codeType = @"04";
    }
    else if ([transType isEqualToString:TranType_BarCode_Trans_WeChat] ||
             [transType isEqualToString:TranType_BarCode_Review_WeChat]
             )
    {
        codeType = @"13";
    }
    else if ([transType isEqualToString:TranType_BarCode_Trans_Alipay] ||
             [transType isEqualToString:TranType_BarCode_Review_Alipay]
             )
    {
        codeType = @"14";
    }
    codeType = [EncodeString encodeASC:codeType];
    return codeType;
}


#pragma mask ---- getter
#pragma mask ---- setter

@end

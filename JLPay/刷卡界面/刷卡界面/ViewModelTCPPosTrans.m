//
//  ViewModelTCPPosTrans.m
//  JLPay
//
//  Created by jielian on 15/11/18.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ViewModelTCPPosTrans.h"
#import "TcpClientService.h"
#import "Packing8583.h"
#import "Unpacking8583.h"
#import "PublicInformation.h"
#import "EncodeString.h"
#import "Define_Header.h"


@interface ViewModelTCPPosTrans() <wallDelegate,Unpacking8583Delegate>
{
    NSString* curTransType; // 当前交易类型
    NSString* errorMessage; // 错误信息:用来错误时回调
    BOOL isICCardTrans; // IC卡交易
    
    NSDictionary* sourceCardInfo;
    NSDictionary* responseCardInfo;
}
@property (nonatomic, assign) id<ViewModelTCPPosTransDelegate>delegate;
@property (nonatomic, strong) TcpClientService* tcpHolder;

@end


@implementation ViewModelTCPPosTrans

#pragma mask ---- 发起交易: 指定交易类型+卡数据信息(2,4,14,22,23,35,36,52,53,55)
- (void)startTransWithTransType:(NSString *)transType
                    andCardInfo:(NSDictionary *)cardInfo
                    andDelegate:(id<ViewModelTCPPosTransDelegate>)delegate
{
    curTransType = transType;
    sourceCardInfo = [cardInfo copy];
    self.delegate = delegate;
    [self setCardTypeByF22:[cardInfo valueForKey:@"22"]];
    
    // 1.打包
    NSString* stringPacking = [self stringPackingByInfo:cardInfo];
    if (!stringPacking) {
        [self delegateRebackResult:NO message:errorMessage responseInfo:nil];
        // 打包失败就退出
        return;
    }
    // 2.发送交易
    [self.tcpHolder sendOrderMethod:stringPacking
                                 IP:[PublicInformation getServerDomain]
                               PORT:[PublicInformation getTcpPort].intValue
                           Delegate:self
                             method:transType];
}

#pragma mask ---- 终止交易
- (void)terminateTransWithTransType:(NSString *)transType
{
    [self.tcpHolder clearDelegateAndClose];
    self.delegate = nil;
}

#pragma mask ---- wallDelegate
/* 成功接收TCP响应信息 */
- (void)receiveGetData:(NSString *)data method:(NSString *)str {
    [self.tcpHolder clearDelegateAndClose];
    // 1.拆包
    if (data.length > 0) {
        [[Unpacking8583 getInstance] unpacking8583:data withDelegate:self];
    } else {
        [self delegateRebackResult:NO message:@"网络异常，请检查网络" responseInfo:nil];
        return;
    }
}

/* 失败接收TCP响应信息 */
- (void)falseReceiveGetDataMethod:(NSString *)str {
    [self.tcpHolder clearDelegateAndClose];
    // 直接回调结果
    [self delegateRebackResult:NO message:@"网络异常，请检查网络" responseInfo:nil];
}

#pragma mask ---- Unpacking8583Delegate
- (void)didUnpackDatas:(NSDictionary *)dataDict onState:(BOOL)state withErrorMsg:(NSString *)message
{
    // 批上送就可以回调并退出
    if ([curTransType isEqualToString:TranType_BatchUpload]) {
        [self delegateRebackResult:YES message:nil responseInfo:responseCardInfo];
        return;
    }
    if (state) { // 成功
        if (isICCardTrans &&  // IC卡且是消费、撤销时，才继续发起批上送
            ([curTransType isEqualToString:TranType_Consume] ||
            [curTransType isEqualToString:TranType_ConsumeRepeal]))
        {
            responseCardInfo = [dataDict copy];
            curTransType = TranType_BatchUpload;
            // 3.如果IC卡交易:继续上送批上送，批上送不关心响应结果
            NSString* packing = [self stringPackingByInfo:dataDict];
            [self.tcpHolder sendOrderMethod:packing
                                         IP:[PublicInformation getServerDomain]
                                       PORT:[PublicInformation getTcpPort].intValue
                                   Delegate:self
                                     method:curTransType];
        }
        else
        {
            [self delegateRebackResult:YES message:nil responseInfo:dataDict];
        }
    } else { // 失败
        [self delegateRebackResult:NO message:message responseInfo:nil];
    }
    
}


#pragma mask ---- PRIVATE INTERFACE
/* 回调 */
- (void) delegateRebackResult:(BOOL)result message:(NSString*)message responseInfo:(NSDictionary*)info {
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewModel:transResult:withMessage:andResponseInfo:)]) {
        [self.delegate viewModel:self transResult:result withMessage:message andResponseInfo:info];
    }
}
/* 设置卡类型 */
- (void) setCardTypeByF22:(NSString*)f22 {
    if (f22 && f22.length > 2) {
        if ([f22 hasPrefix:@"05"]) {
            isICCardTrans = YES;
        }
    }
}
/* 打包综合:消费、批上送、余额查询 */
- (NSString*) stringPackingByInfo:(NSDictionary*)info {
    NSString* stringPacking = nil;
    if ([curTransType isEqualToString:TranType_Consume]) {
        stringPacking = [self packingConsumeByInfo:info];
    }
    else if ([curTransType isEqualToString:TranType_BatchUpload]) {
        stringPacking = [self packingBatchUpByInfo:info];
    }
    else if ([curTransType isEqualToString:TranType_YuE]) {
        stringPacking = [self packingYuEByInfo:info];
    }
    return stringPacking;
}

/* 打包: 消费 */
- (NSString*) packingConsumeByInfo:(NSDictionary*)info {
    NSString* packing = nil;
    Packing8583* packingHolder = [Packing8583 sharedInstance];
    [packingHolder setFieldAtIndex:2 withValue:[info valueForKey:@"2"]];
    [packingHolder setFieldAtIndex:3 withValue:TranType_Consume];
    [packingHolder setFieldAtIndex:4 withValue:[info valueForKey:@"4"]];
    [packingHolder setFieldAtIndex:11 withValue:[PublicInformation exchangeNumber]];
    [packingHolder setFieldAtIndex:14 withValue:[info valueForKey:@"14"]];
    [packingHolder setFieldAtIndex:22 withValue:[info valueForKey:@"22"]];
    [packingHolder setFieldAtIndex:23 withValue:[info valueForKey:@"23"]];
    [packingHolder setFieldAtIndex:25 withValue:@"82"];
    [packingHolder setFieldAtIndex:26 withValue:@"12"];
    [packingHolder setFieldAtIndex:35 withValue:[info valueForKey:@"35"]];
    [packingHolder setFieldAtIndex:36 withValue:[info valueForKey:@"36"]];
    [packingHolder setFieldAtIndex:41 withValue:[EncodeString encodeASC:[PublicInformation returnTerminal]]];
    [packingHolder setFieldAtIndex:42 withValue:[EncodeString encodeASC:[PublicInformation returnBusiness]]];
    [packingHolder setFieldAtIndex:49 withValue:[EncodeString encodeASC:@"156"]];
    if ([[info valueForKey:@"22"] hasSuffix:@"10"]) {
        [packingHolder setFieldAtIndex:52 withValue:[info valueForKey:@"52"]];
    }
    [packingHolder setFieldAtIndex:53 withValue:[info valueForKey:@"53"]];
    [packingHolder setFieldAtIndex:55 withValue:[info valueForKey:@"55"]];
    [packingHolder setFieldAtIndex:60 withValue:[Packing8583 makeF60OnTrantype:TranType_Consume]];
    [packingHolder setFieldAtIndex:64 withValue:@"0000000000000000"];
    
    packing = [packingHolder stringPackingWithType:@"0200"];
    return packing;
}
/* 打包: 批上送 */
- (NSString*) packingBatchUpByInfo:(NSDictionary*)lastInfo {
    NSString* packing = nil;
    Packing8583* packingHolder = [Packing8583 sharedInstance];
    [packingHolder setFieldAtIndex:2 withValue:[responseCardInfo valueForKey:@"2"]];
    [packingHolder setFieldAtIndex:3 withValue:[responseCardInfo valueForKey:@"3"]];
    [packingHolder setFieldAtIndex:4 withValue:[responseCardInfo valueForKey:@"4"]];
    [packingHolder setFieldAtIndex:11 withValue:[responseCardInfo valueForKey:@"11"]];
    [packingHolder setFieldAtIndex:22 withValue:[sourceCardInfo valueForKey:@"22"]];
    [packingHolder setFieldAtIndex:23 withValue:[sourceCardInfo valueForKey:@"23"]];
    [packingHolder setFieldAtIndex:25 withValue:@"82"];
    [packingHolder setFieldAtIndex:26 withValue:@"12"];
    [packingHolder setFieldAtIndex:41 withValue:[responseCardInfo valueForKey:@"41"]];
    [packingHolder setFieldAtIndex:42 withValue:[responseCardInfo valueForKey:@"42"]];
    [packingHolder setFieldAtIndex:49 withValue:[responseCardInfo valueForKey:@"49"]];
    [packingHolder setFieldAtIndex:55 withValue:[sourceCardInfo valueForKey:@"55"]];
    [packingHolder setFieldAtIndex:60 withValue:[Packing8583 makeF60ByLast60:[responseCardInfo valueForKey:@"60"]]];
    [packingHolder setFieldAtIndex:64 withValue:@"0000000000000000"];
    
    packing = [packingHolder stringPackingWithType:@"0320"];
    return packing;
}
/* 打包: 余额查询 */
- (NSString*) packingYuEByInfo:(NSDictionary*)info {
    NSString* packing = nil;
    Packing8583* packingHolder = [Packing8583 sharedInstance];
    [packingHolder setFieldAtIndex:2 withValue:[info valueForKey:@"2"]];
    [packingHolder setFieldAtIndex:3 withValue:TranType_YuE];
    [packingHolder setFieldAtIndex:11 withValue:[PublicInformation exchangeNumber]];
    [packingHolder setFieldAtIndex:14 withValue:[info valueForKey:@"14"]];
    [packingHolder setFieldAtIndex:22 withValue:[info valueForKey:@"22"]];
    [packingHolder setFieldAtIndex:23 withValue:[info valueForKey:@"23"]];
    [packingHolder setFieldAtIndex:25 withValue:@"82"];
    [packingHolder setFieldAtIndex:26 withValue:@"12"];
    [packingHolder setFieldAtIndex:35 withValue:[info valueForKey:@"35"]];
    [packingHolder setFieldAtIndex:36 withValue:[info valueForKey:@"36"]];
    [packingHolder setFieldAtIndex:41 withValue:[EncodeString encodeASC:[PublicInformation returnTerminal]]];
    [packingHolder setFieldAtIndex:42 withValue:[EncodeString encodeASC:[PublicInformation returnBusiness]]];
    [packingHolder setFieldAtIndex:49 withValue:[EncodeString encodeASC:@"156"]];
    [packingHolder setFieldAtIndex:52 withValue:[info valueForKey:@"52"]];
    [packingHolder setFieldAtIndex:53 withValue:[info valueForKey:@"53"]];
    [packingHolder setFieldAtIndex:55 withValue:[info valueForKey:@"55"]];
    [packingHolder setFieldAtIndex:60 withValue:[Packing8583 makeF60OnTrantype:TranType_YuE]];
    [packingHolder setFieldAtIndex:64 withValue:@"0000000000000000"];
    
    packing = [packingHolder stringPackingWithType:@"0200"];
    return packing;
}



#pragma mask ---- 初始化
- (instancetype)init {
    self = [super init];
    if (self) {
        isICCardTrans = NO;
        self.tcpHolder = [TcpClientService getInstance];
    }
    return self;
}

@end

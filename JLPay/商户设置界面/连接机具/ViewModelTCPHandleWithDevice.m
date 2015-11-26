//
//  ViewModelTCPHandleWithDevice.m
//  JLPay
//
//  Created by jielian on 15/11/24.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ViewModelTCPHandleWithDevice.h"
#import "TcpClientService.h"
#import "PublicInformation.h"
#import "Packing8583.h"
#import "Unpacking8583.h"
#import "EncodeString.h"

@interface ViewModelTCPHandleWithDevice()
<wallDelegate, Unpacking8583Delegate>
{
    NSString* sTerminalNumber; // 终端号
    NSString* sBusinessNumber; // 商户号
    NSString* sTranType; // 交易类型
}

@end


static ViewModelTCPHandleWithDevice* tcpHandleWithDevice;
@implementation ViewModelTCPHandleWithDevice

/* 获取公共入口 */
+ (ViewModelTCPHandleWithDevice*) getInstance {
    @synchronized([ViewModelTCPHandleWithDevice class]) {
        if (tcpHandleWithDevice == nil) {
            tcpHandleWithDevice = [[self alloc] init];
        }
    }
    return tcpHandleWithDevice;
}

/* 下载主密钥 */
- (void) downloadMainKeyWithBusinessNum:(NSString*)businessNum andTerminalNum:(NSString*)terminalNum {
    sTerminalNumber = terminalNum;
    sBusinessNumber = businessNum;
    [self sendTransPackage:[self stringPackingMainKeyDownload] withTransType:TranType_DownMainKey];
}
/* 下载工作密钥 */
- (void) downloadWorkKeyWithBusinessNum:(NSString*)businessNum andTerminalNum:(NSString*)terminalNum {
    sTerminalNumber = terminalNum;
    sBusinessNumber = businessNum;
    [self sendTransPackage:[self stringPackingWorkKeyDownload] withTransType:TranType_DownWorkKey];
}
/* 终止下载 */
- (void) stopDownloading {
    self.delegate = nil;
    [[TcpClientService getInstance] clearDelegateAndClose];
}



#pragma mask ---- TCP操作
/* 发送报文包 */
- (void) sendTransPackage:(NSString*)package withTransType:(NSString*)transType {
    sTranType = transType;
    [[TcpClientService getInstance] sendOrderMethod:package
                                                 IP:[PublicInformation getServerDomain]
                                               PORT:[PublicInformation getTcpPort].intValue
                                           Delegate:self
                                             method:transType];
}

/* 打包: 主密钥下载 */
- (NSString*) stringPackingMainKeyDownload {
    Packing8583* packingHolder = [Packing8583 sharedInstance];
    [packingHolder setFieldAtIndex:11 withValue:[PublicInformation exchangeNumber]];
    [packingHolder setFieldAtIndex:41 withValue:[EncodeString encodeASC:sTerminalNumber]];
    [packingHolder setFieldAtIndex:42 withValue:[EncodeString encodeASC:sBusinessNumber]];
    [packingHolder setFieldAtIndex:60 withValue:[Packing8583 makeF60OnTrantype:TranType_DownMainKey]];
    [packingHolder setFieldAtIndex:62 withValue:[packingHolder MAINKEY]];
    [packingHolder setFieldAtIndex:63 withValue:[EncodeString encodeASC:@"001"]];
    return [packingHolder stringPackingWithType:@"0800"];
}
/* 打包: 工作密钥下载 */
- (NSString*) stringPackingWorkKeyDownload {
    Packing8583* packingHolder = [Packing8583 sharedInstance];
    [packingHolder setFieldAtIndex:11 withValue:[PublicInformation exchangeNumber]];
    [packingHolder setFieldAtIndex:41 withValue:[EncodeString encodeASC:sTerminalNumber]];
    [packingHolder setFieldAtIndex:42 withValue:[EncodeString encodeASC:sBusinessNumber]];
    [packingHolder setFieldAtIndex:60 withValue:[Packing8583 makeF60OnTrantype:TranType_DownWorkKey]];
    [packingHolder setFieldAtIndex:63 withValue:[EncodeString encodeASC:@"001"]];
    
    return [packingHolder stringPackingWithType:@"0800"];
}

/* 错误回调 */
- (void) rebackWithErrorMessage:(NSString*)errorMessage {
    if ([sTranType isEqualToString:TranType_DownMainKey]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDownloadedMainKeyResult:withMainKey:orErrorMessage:)]) {
            [self.delegate didDownloadedMainKeyResult:NO withMainKey:nil orErrorMessage:errorMessage];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDownloadedWorkKeyResult:withWorkKey:orErrorMessage:)]) {
            [self.delegate didDownloadedWorkKeyResult:NO withWorkKey:nil orErrorMessage:errorMessage];
        }
    }
}
/* 成功回调 */
- (void) rebackWithAnalysedKey:(NSString*)key {
    if ([sTranType isEqualToString:TranType_DownMainKey]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDownloadedMainKeyResult:withMainKey:orErrorMessage:)]) {
            [self.delegate didDownloadedMainKeyResult:YES withMainKey:key orErrorMessage:nil];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDownloadedWorkKeyResult:withWorkKey:orErrorMessage:)]) {
            [self.delegate didDownloadedWorkKeyResult:YES withWorkKey:key orErrorMessage:nil];
        }
    }
}

#pragma mask ---- wallDelegate
/* TCP响应结果 */
- (void)receiveGetData:(NSString *)data method:(NSString *)str {
    [[TcpClientService getInstance] clearDelegateAndClose];
    if (data && data.length > 0) {
        [[Unpacking8583 getInstance] unpacking8583:data withDelegate:self];
    } else {
        [self rebackWithErrorMessage:@"网络异常，请检查网络"];
    }
}
/* TCP响应失败 */
- (void)falseReceiveGetDataMethod:(NSString *)str {
    [[TcpClientService getInstance] clearDelegateAndClose];
    [self rebackWithErrorMessage:@"网络异常，请检查网络"];
}


#pragma mask ---- Unpacking8583Delegate
/* 拆包结果;并回调 */
- (void)didUnpackDatas:(NSDictionary *)dataDict onState:(BOOL)state withErrorMsg:(NSString *)message
{
    if (state) {
        // 区分主密钥跟工作密钥
        if ([sTranType isEqualToString:TranType_DownMainKey]) {
            NSString* mainKey = [self mainKeyAnalysedByF62:[dataDict valueForKey:@"62"]];
            if (mainKey && mainKey.length > 0) {
                [self rebackWithAnalysedKey:mainKey];
            } else {
                [self rebackWithErrorMessage:@"主密钥解析失败"];
            }
        }
        else if ([sTranType isEqualToString:TranType_DownWorkKey]) {
            NSString* workKey = [self workKeyAnalysedByF62:[dataDict valueForKey:@"62"]];
            if (workKey && workKey.length > 0) {
                [self rebackWithAnalysedKey:workKey];
            } else {
                [self rebackWithErrorMessage:@"工作密钥解析失败"];
            }
        }
    } else {
        [self rebackWithErrorMessage:message];
    }
}

// 解析62域: 主密钥
- (NSString*) mainKeyAnalysedByF62:(NSString*)f62 {
    NSString* mainKey = nil;
    // 截取主密钥密文
    if ([f62 containsString:@"DF02"]) {
        NSRange sKeyRange = [f62 rangeOfString:@"DF02"];
        NSInteger location = sKeyRange.location + sKeyRange.length;
        if (location + 2 < f62.length) {
            NSString* sHexLength = [f62 substringWithRange:NSMakeRange(location, 2)];
            location += 2;
            int length = [PublicInformation sistenToTen:sHexLength] * 2;
            if (location + length <= f62.length) {
                NSString* mainKeyPin = [f62 substringWithRange:NSMakeRange(location, length)];
                // 解密出明文
                mainKey = [[Unpacking8583 getInstance] threeDESdecrypt:mainKeyPin keyValue:@"EF2AE9F834BFCDD5260B974A70AD1A4A"];
            }
        }
    }
    return mainKey;
}
// 解析62域: 工作密钥
- (NSString*) workKeyAnalysedByF62:(NSString*)f62 {
    NSString* workKey = nil;
    if (f62 && f62.length > 2) {
        workKey = [f62 substringFromIndex:2];
    }
    return workKey;
}


#pragma mask ---- 初始化
/* 初始化 */
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
/* 销毁 */
- (void)dealloc {
    self.delegate = nil;
    [[TcpClientService getInstance] clearDelegateAndClose];
}


@end

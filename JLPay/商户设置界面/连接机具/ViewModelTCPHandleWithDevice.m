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
<wallDelegate>
{
    NSString* sTerminalNumber;
    NSString* sBusinessNumber;
}
@property (nonatomic, retain) TcpClientService* tcpHandle;


@end

@implementation ViewModelTCPHandleWithDevice


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


#pragma mask ---- TCP操作
/* 发送报文包 */
- (void) sendTransPackage:(NSString*)package withTransType:(NSString*)transType {
    [self.tcpHandle sendOrderMethod:package
                                 IP:[PublicInformation getServerDomain]
                               PORT:[PublicInformation getTcpPort].intValue
                           Delegate:self method:transType];
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

/* 错误退出 */
- (void) rebackWithErrorMessage:(NSString*)errorMessage {
    
}

#pragma mask ---- wallDelegate
/* TCP响应结果 */
- (void)receiveGetData:(NSString *)data method:(NSString *)str {
    
}
/* TCP响应失败 */
- (void)falseReceiveGetDataMethod:(NSString *)str {
    
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
    [self.tcpHandle clearDelegateAndClose];
}

#pragma mask ---- GETTER
- (TcpClientService *)tcpHandle {
    if (_tcpHandle == nil) {
        _tcpHandle = [TcpClientService getInstance];
    }
    return _tcpHandle;
}


@end

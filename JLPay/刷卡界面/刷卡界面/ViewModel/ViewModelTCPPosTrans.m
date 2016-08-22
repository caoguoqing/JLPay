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


@interface ViewModelTCPPosTrans() <wallDelegate>
{
    NSString* curTransType; // 当前交易类型
}
@property (nonatomic, assign) id<ViewModelTCPPosTransDelegate>delegate;
@property (nonatomic, strong) TcpClientService* tcpHolder;

@end


@implementation ViewModelTCPPosTrans



- (void) startTransWithTransType:(NSString*)transType
                andPackingString:(NSString*)packingString
                      onDelegate:(id<ViewModelTCPPosTransDelegate>)delegate
{
    self.delegate = delegate;
    curTransType = transType;
    [self.tcpHolder sendOrderMethod:packingString
                                 IP:[PublicInformation getServerDomain]
                               PORT:[[PublicInformation getTcpPort] intValue]
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
        NameWeakSelf(wself);
        [Unpacking8583 unpacking8583Response:data onUnpacked:^(NSDictionary *unpackedInfo) {
            NSString* code = [unpackedInfo objectForKey:@"39"];
            if ([code isEqualToString:@"00"]) {
                [wself delegateRebackResult:YES message:nil responseInfo:unpackedInfo];
            } else {
                [wself delegateRebackResult:NO message:[NSString stringWithFormat:@"[%@]%@", code, [ErrorType errInfo:code]] responseInfo:nil];
            }
        } onError:^(NSError *error) {
            [wself delegateRebackResult:NO message:[error localizedDescription] responseInfo:nil];
        }];
        
    } else {
        [self delegateRebackResult:NO message:@"网络异常，请检查网络" responseInfo:nil];
    }
}

/* 失败接收TCP响应信息 */
- (void)falseReceiveGetDataMethod:(NSString *)str {
    [self.tcpHolder clearDelegateAndClose];
    // 直接回调结果
    [self delegateRebackResult:NO message:@"网络异常，请检查网络" responseInfo:nil];
}



#pragma mask ---- PRIVATE INTERFACE
/* 回调 */
- (void) delegateRebackResult:(BOOL)result message:(NSString*)message responseInfo:(NSDictionary*)info {
    if (result) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTransSuccessWithResponseInfo:onTransType:)]) {
            [self.delegate didTransSuccessWithResponseInfo:info onTransType:curTransType];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTransFailWithErrMsg:onTransType:)]) {
            [self.delegate didTransFailWithErrMsg:message onTransType:curTransType];
        }
    }
}



#pragma mask ---- 初始化
- (instancetype)init {
    self = [super init];
    if (self) {
        self.tcpHolder = [TcpClientService getInstance];
    }
    return self;
}

@end

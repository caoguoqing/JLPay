//
//  ViewModelTCPHandleWithDevice.m
//  JLPay
//
//  Created by jielian on 15/11/24.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ViewModelTCPHandleWithDevice.h"
#import "ModelTCPTransPacking.h"
#import "TcpClientService.h"
#import "PublicInformation.h"
#import "Packing8583.h"
#import "Unpacking8583.h"
#import "EncodeString.h"
#import "Define_Header.h"
#import "RSAEncoder.h"
#import "ThreeDesUtil.h"

@interface ViewModelTCPHandleWithDevice()  <wallDelegate>
{
    NSString* sTranType; // 交易类型
}


/* 下载公钥的回调: 成功 or 失败 */
@property (nonatomic, copy) void (^ downloadPubkeySucBlock) (NSString* pubkey);
@property (nonatomic, copy) void (^ downloadPubkeyErrBlock) (NSError* error);


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
- (void)downloadMainKeyWithBusinessNum:(NSString *)businessNum andTerminalNum:(NSString *)terminalNum andPubkey:(NSString *)pubkey
{
    NSDictionary* fieldInfos = [NSDictionary dictionaryWithObjects:@[terminalNum,businessNum,pubkey] forKeys:@[@"41",@"42",@"62"]];
    [[ModelTCPTransPacking sharedModel] packingFieldsInfo:fieldInfos forTransType:TranType_DownMainKey];
    [self sendTransPackage:[[ModelTCPTransPacking sharedModel] packageFinalyPacking] withTransType:TranType_DownMainKey];
}

/* 下载工作密钥 */
- (void) downloadWorkKeyWithBusinessNum:(NSString*)businessNum andTerminalNum:(NSString*)terminalNum {
    NSDictionary* fieldInfos = [NSDictionary dictionaryWithObjects:@[terminalNum,businessNum] forKeys:@[@"41",@"42"]];
    [[ModelTCPTransPacking sharedModel] packingFieldsInfo:fieldInfos forTransType:TranType_DownWorkKey];
    [self sendTransPackage:[[ModelTCPTransPacking sharedModel] packageFinalyPacking] withTransType:TranType_DownWorkKey];
}

/* 终止下载 */
- (void) stopDownloading {
    self.delegate = nil;
    [[TcpClientService getInstance] clearDelegateAndClose];
}


/***********************************
 * 下载公钥
 *    update by fjl.2016-08-10
 *    改用block返回获取的结果
 ***********************************/
- (void) downloadPubkeyWithBusinessNum:(NSString*)businessNum andTerminalNum:(NSString*)terminalNum
                        onSuccessBlock:(void (^) (NSString* pubkey))successBlock
                          orErrorBlock:(void (^) (NSError* error))errorBlock
{
    self.downloadPubkeySucBlock = successBlock;
    self.downloadPubkeyErrBlock = errorBlock;
    JLPrint(@"---正在下载公钥，终端号为[%@]", terminalNum);
    NSMutableDictionary* fieldInfos = [NSMutableDictionary dictionary];
    [fieldInfos setObject:businessNum forKey:@"42"];
    [fieldInfos setObject:terminalNum forKey:@"41"];
    /* 62域取固定值 */
    [fieldInfos setObject:@"9F0605DF000000019F220101" forKey:@"62"];
    [[ModelTCPTransPacking sharedModel] packingFieldsInfo:fieldInfos forTransType:TranType_DownPubKey];
    [self sendTransPackage:[[ModelTCPTransPacking sharedModel] packageFinalyPacking] withTransType:TranType_DownPubKey];
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


/* 错误回调 */
- (void) rebackWithErrorMessage:(NSString*)errorMessage {
    if ([sTranType isEqualToString:TranType_DownMainKey]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDownloadedMainKeyResult:withMainKey:orErrorMessage:)]) {
            [self.delegate didDownloadedMainKeyResult:NO withMainKey:nil orErrorMessage:errorMessage];
        }
    }
    else if ([sTranType isEqualToString:TranType_DownWorkKey]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDownloadedWorkKeyResult:withWorkKey:orErrorMessage:)]) {
            [self.delegate didDownloadedWorkKeyResult:NO withWorkKey:nil orErrorMessage:errorMessage];
        }
    }
    else if ([sTranType isEqualToString:TranType_DownPubKey]) {
        if (self.downloadPubkeyErrBlock) {
            self.downloadPubkeyErrBlock ([NSError errorWithDomain:@"" code:99 localizedDescription:errorMessage]);
        }
    }
}
/* 成功回调 */
- (void) rebackWithAnalysedKey:(NSString*)key {
    if ([sTranType isEqualToString:TranType_DownMainKey]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDownloadedMainKeyResult:withMainKey:orErrorMessage:)]) {
            [self.delegate didDownloadedMainKeyResult:YES withMainKey:key orErrorMessage:nil];
        }
    }
    else if ([sTranType isEqualToString:TranType_DownWorkKey]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didDownloadedWorkKeyResult:withWorkKey:orErrorMessage:)]) {
            [self.delegate didDownloadedWorkKeyResult:YES withWorkKey:key orErrorMessage:nil];
        }
    }
    else if ([sTranType isEqualToString:TranType_DownPubKey]) {
        if (self.downloadPubkeySucBlock) {
            self.downloadPubkeySucBlock(key);
        }
    }
}

#pragma mask ---- wallDelegate
/* TCP响应结果 */
- (void)receiveGetData:(NSString *)data method:(NSString *)str {
    [[TcpClientService getInstance] clearDelegateAndClose];
    NameWeakSelf(wself);
    if (data && data.length > 0) {
        [Unpacking8583 unpacking8583Response:data onUnpacked:^(NSDictionary *unpackedInfo) {
            NSString* code = [unpackedInfo objectForKey:@"39"];
            if ([code isEqualToString:@"00"]) {
                // 区分主密钥跟工作密钥
                if ([sTranType isEqualToString:TranType_DownMainKey]) {
                    NSString* mainKey = [wself mainKeyAnalysedByF62:[unpackedInfo valueForKey:@"62"]];
                    if (mainKey && mainKey.length > 0) {
                        [wself rebackWithAnalysedKey:mainKey];
                    } else {
                        [wself rebackWithErrorMessage:@"主密钥解析失败"];
                    }
                }
                else if ([sTranType isEqualToString:TranType_DownWorkKey]) {
                    NSString* workKey = [wself workKeyAnalysedByF62:[unpackedInfo valueForKey:@"62"]];
                    if (workKey && workKey.length > 0) {
                        [wself rebackWithAnalysedKey:workKey];
                    } else {
                        [wself rebackWithErrorMessage:@"工作密钥解析失败"];
                    }
                }
                else if ([sTranType isEqualToString:TranType_DownPubKey]) {
                    NSString* pubkey = [unpackedInfo objectForKey:@"62"];
                    if (pubkey && pubkey.length > 0) {
                        [wself rebackWithAnalysedKey:pubkey];
                    } else {
                        [wself rebackWithErrorMessage:@"公钥解析失败"];
                    }
                }
            } else {
                [wself rebackWithErrorMessage:[NSString stringWithFormat:@"[%@]%@",code, [ErrorType errInfo:code] ]];
            }
        } onError:^(NSError *error) {
            [wself rebackWithErrorMessage:[error localizedDescription]];
        }];
    } else {
        [self rebackWithErrorMessage:@"网络异常，请检查网络"];
    }
}
/* TCP响应失败 */
- (void)falseReceiveGetDataMethod:(NSString *)str {
    [[TcpClientService getInstance] clearDelegateAndClose];
    [self rebackWithErrorMessage:@"网络异常，请检查网络"];
}



// 解析62域: 主密钥
- (NSString*) mainKeyAnalysedByF62:(NSString*)f62 {
    NSString* mainKey = nil;
    // 截取主密钥密文
    NSRange sKeyRange = [f62 rangeOfString:@"DF02"];
    if (sKeyRange.length > 0) {
        NSInteger location = sKeyRange.location + sKeyRange.length;
        if (location + 2 < f62.length) {
            NSString* sHexLength = [f62 substringWithRange:NSMakeRange(location, 2)];
            location += 2;
            int length = [PublicInformation sistenToTen:sHexLength] * 2;
            if (location + length <= f62.length) {
                NSString* mainKeyPin = [f62 substringWithRange:NSMakeRange(location, length)];
                // 解密出明文
                mainKey = [Unpacking8583 threeDESdecrypt:mainKeyPin keyValue:[RSAEncoder pinSourceOfPubdata]];
            }
        }
    }
    return mainKey;
}
// 解析62域: 工作密钥
- (NSString*) workKeyAnalysedByF62:(NSString*)f62 {
    NSString* workKey = [NSString stringWithString:f62];
    if (workKey){
        NSUInteger extLen = workKey.length % 40;
        if (extLen > 0) {
            workKey = [workKey substringFromIndex:extLen];
        }
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

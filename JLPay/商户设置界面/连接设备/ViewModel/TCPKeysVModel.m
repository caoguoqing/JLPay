//
//  TCPKeysVModel.m
//  JLPay
//
//  Created by jielian on 16/4/18.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "TCPKeysVModel.h"
#import "RSAEncoder.h"
#import "MPubkeyFormator.h"

@interface TCPKeysVModel()

@property (nonatomic, strong) MPubkeyFormator* pubkeyFormator;


@end

@implementation TCPKeysVModel

- (void)dealloc {
    self.tcpHandle.delegate = nil;
    [self.tcpHandle stopDownloading];
}

- (void) gettingKeysOnFinished:(void (^) (void))finished onError:(void (^) (NSError* error))errorBlock {
    // 下载主密钥
    NameWeakSelf(wself);
    
    self.stateMessage = @"正在下载公钥...";
    [self getPubKeyOnFinished:^(NSString *pubkey) {
        wself.pubkeyFormator = [[MPubkeyFormator alloc] initWithPublicKey:pubkey];
        wself.stateMessage = @"下载主密钥...";
        [wself getMainKeyWithPubkey:wself.pubkeyFormator.repackedPubkey onFinished:^{
            wself.stateMessage = @"下载工作密钥...";
            [wself getWorkKeyOnFinished:^{
                wself.stateMessage = @"下载密钥成功!";
                finished();
            } onError:^(NSError *error) {
                wself.stateMessage = @"下载工作密钥失败!";
                errorBlock(error);
            }];
        } onError:^(NSError *error) {
            wself.stateMessage = @"下载主密钥失败!";
            errorBlock(error);
        }];
    } onError:^(NSError *error) {
        wself.stateMessage = @"下载公钥失败!";
        errorBlock(error);
    }];
    
}


#pragma mask 2 private interface

- (void) getMainKeyWithPubkey:(NSString*)pubkey onFinished:(void (^) (void))finished onError:(void (^) (NSError* error))errorBlock {
    self.finishedBlock = finished;
    self.errorBlock = errorBlock;
    [self.tcpHandle downloadMainKeyWithBusinessNum:[PublicInformation returnBusiness] andTerminalNum:self.terminalNumber andPubkey:pubkey];
}

- (void) getWorkKeyOnFinished:(void (^) (void))finished onError:(void (^) (NSError* error))errorBlock {
    self.finishedBlock = finished;
    self.errorBlock = errorBlock;
    [self.tcpHandle downloadWorkKeyWithBusinessNum:[MLoginSavedResource sharedLoginResource].businessNumber andTerminalNum:self.terminalNumber];
}

- (void) getPubKeyOnFinished:(void (^) (NSString* pubkey))finished onError:(void (^) (NSError* error))errorBlock {
    [self.tcpHandle downloadPubkeyWithBusinessNum:[PublicInformation returnBusiness]
                                   andTerminalNum:self.terminalNumber
                                   onSuccessBlock:^(NSString *pubkey) {
                                       finished(pubkey);
    } orErrorBlock:^(NSError *error) {
        errorBlock(error);
    }];
}


#pragma mask 3 ViewModelTCPHandleWithDeviceDelegate
/* 回调: 主密钥 */
- (void) didDownloadedMainKeyResult:(BOOL)result withMainKey:(NSString*)mainKey orErrorMessage:(NSString*)errorMessge {
    if (result) {
        self.mainKey = [mainKey copy];
        self.finishedBlock();
    } else {
        self.errorBlock([NSError errorWithDomain:@"" code:9 localizedDescription:[@"下载主密钥失败:" stringByAppendingString:errorMessge]]);
    }
}

/* 回调: 工作密钥 */
- (void) didDownloadedWorkKeyResult:(BOOL)result withWorkKey:(NSString*)workKey orErrorMessage:(NSString*)errorMessge {
    if (result) {
        self.workKey = [workKey copy];
        self.finishedBlock();
    } else {
        self.errorBlock([NSError errorWithDomain:@"" code:9 localizedDescription:[@"下载工作密钥失败:" stringByAppendingString:errorMessge]]);
    }
}


#pragma mask 4 getter
- (ViewModelTCPHandleWithDevice *)tcpHandle {
    if (!_tcpHandle) {
        _tcpHandle = [ViewModelTCPHandleWithDevice getInstance];
        _tcpHandle.delegate = self;
    }
    return _tcpHandle;
}

@end

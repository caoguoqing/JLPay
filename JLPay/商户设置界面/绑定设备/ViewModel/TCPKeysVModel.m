//
//  TCPKeysVModel.m
//  JLPay
//
//  Created by jielian on 16/4/18.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "TCPKeysVModel.h"

@implementation TCPKeysVModel

- (void)dealloc {
    self.tcpHandle.delegate = nil;
    [self.tcpHandle stopDownloading];
}

- (void) gettingKeysOnFinished:(void (^) (void))finished onError:(void (^) (NSError* error))errorBlock {
    // 下载主密钥
    NameWeakSelf(wself);
    self.stateMessage = @"正在下载主密钥...";
    [self getMainKeyOnFinished:^{
        wself.stateMessage = @"正在下载工作密钥...";
        [wself getWorkKeyOnFinished:^{
            wself.stateMessage = @"所有密钥下载完成!";
            finished();
        } onError:^(NSError *error) {
            wself.stateMessage = @"下载工作密钥失败!";
            errorBlock(error);
        }];
    } onError:^(NSError *error) {
        wself.stateMessage = @"下载主密钥失败!";
        errorBlock(error);
    }];
    
}


#pragma mask 2 private interface

- (void) getMainKeyOnFinished:(void (^) (void))finished onError:(void (^) (NSError* error))errorBlock {
    self.finishedBlock = finished;
    self.errorBlock = errorBlock;
    [self.tcpHandle downloadMainKeyWithBusinessNum:[MLoginSavedResource sharedLoginResource].businessNumber andTerminalNum:self.terminalNumber];
}

- (void) getWorkKeyOnFinished:(void (^) (void))finished onError:(void (^) (NSError* error))errorBlock {
    self.finishedBlock = finished;
    self.errorBlock = errorBlock;
    [self.tcpHandle downloadWorkKeyWithBusinessNum:[MLoginSavedResource sharedLoginResource].businessNumber andTerminalNum:self.terminalNumber];
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

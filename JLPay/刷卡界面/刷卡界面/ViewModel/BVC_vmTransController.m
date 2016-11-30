//
//  BVC_vmTransController.m
//  JLPay
//
//  Created by jielian on 2016/11/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "BVC_vmTransController.h"
#import <ReactiveCocoa.h>
#import "Define_Header.h"
#import "TcpClientService.h"
#import "Unpacking8583.h"
#import "ErrorType.h"

@interface BVC_vmTransController() <wallDelegate>

@property (nonatomic, strong) TcpClientService* tcpHandle;

@property (nonatomic, retain) id subscriber;

@end



@implementation BVC_vmTransController

- (void)dealloc {
    [self.tcpHandle clearDelegateAndClose];
}

# pragma mask 1 wallDelegate

-(void)receiveGetData:(NSString *)data method:(NSString *)str {
    @weakify(self);
    [self.tcpHandle clearDelegateAndClose];
    if (data && data.length > 0) {
        [Unpacking8583 unpacking8583Response:data onUnpacked:^(NSDictionary *unpackedInfo) {
            @strongify(self);
            NSString* code = [unpackedInfo objectForKey:@"39"];
            if ([code isEqualToString:@"00"]) {
                self.stateMessage = @"交易成功!";
                self.responseInfo = unpackedInfo;
                [self.subscriber sendCompleted];
            } else {
                self.stateMessage = @"交易失败!";
                self.responseInfo = unpackedInfo;
                NSString* message = [ErrorType errInfo:code];
                message = [NSString stringWithFormat:@"[%@]%@",code, message];
                [self.subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:message]];
            }
        } onError:^(NSError *error) {
            @strongify(self);
            self.stateMessage = @"交易失败!";
            [self.subscriber sendError:error];
        }];
    } else {
        self.stateMessage = @"交易失败!";
        [self.subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:@"网络异常，请检查网络"]];
    }
}

-(void)falseReceiveGetDataMethod:(NSString *)str {
    [self.tcpHandle clearDelegateAndClose];
    [self.subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:@"网络异常，请检查网络"]];
}



# pragma mask 2 getter

- (RACCommand *)cmd_transSending {
    if (!_cmd_transSending) {
        @weakify(self);
        _cmd_transSending = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                self.stateMessage = @"正在上送交易...";
                [subscriber sendNext:nil];
                self.subscriber = subscriber;
                [self.tcpHandle sendOrderMethod:self.transMessage
                                             IP:[PublicInformation getServerDomain]
                                           PORT:[PublicInformation getTcpPort].intValue
                                       Delegate:self
                                         method:self.transType];
                return nil;
            }] replayLast] materialize];
        }];
    }
    return _cmd_transSending;
}


/* 暂时不会解决一个 RACCommand 的多次触发,所以新建一个命令 */
- (RACCommand *)cmd_elecSignSending {
    if (!_cmd_elecSignSending) {
        @weakify(self);
        _cmd_elecSignSending = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                self.stateMessage = @"正在上送签名...";
                [subscriber sendNext:nil];
                self.subscriber = subscriber;
                [self.tcpHandle sendOrderMethod:self.transMessage
                                             IP:[PublicInformation getServerDomain]
                                           PORT:[PublicInformation getTcpPort].intValue
                                       Delegate:self
                                         method:self.transType];
                return nil;
            }] replayLast] materialize];
        }];
    }
    return _cmd_elecSignSending;
}

/* cmd: 停止交易上传 */
- (RACCommand *)cmd_stopSending {
    if (!_cmd_stopSending) {
        @weakify(self);
        _cmd_stopSending = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [self.tcpHandle clearDelegateAndClose];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return _cmd_stopSending;
}


- (TcpClientService *)tcpHandle {
    if (!_tcpHandle) {
        _tcpHandle = [TcpClientService getInstance];
    }
    return _tcpHandle;
}

@end

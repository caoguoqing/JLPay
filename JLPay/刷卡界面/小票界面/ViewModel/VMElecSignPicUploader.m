//
//  VMElecSignPicUploader.m
//  JLPay
//
//  Created by jielian on 16/7/28.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMElecSignPicUploader.h"
#import "TcpClientService.h"
#import "Packing8583.h"
#import "ModelTCPTransPacking.h"
#import "Unpacking8583.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>

@interface VMElecSignPicUploader() <wallDelegate>

@property (nonatomic, strong) id subscriber;

@end

@implementation VMElecSignPicUploader

# pragma mask 2 wallDelegate

-(void)receiveGetData:(NSString *)data method:(NSString *)str {
    [self.tcpHandle clearDelegateAndClose];
    NameWeakSelf(wself);
    if (data && data.length > 0) {
        [Unpacking8583 unpacking8583Response:data onUnpacked:^(NSDictionary *unpackedInfo) {
            NSString* code = [unpackedInfo objectForKey:@"39"];
            if ([code isEqualToString:@"00"]) {
                [wself.subscriber sendCompleted];
            } else {
                NSString* message = [NSString stringWithFormat:@"[%@]%@", code, [ErrorType errInfo:code]];
                [wself.subscriber sendError:[NSError errorWithDomain:@"" code:[code integerValue] localizedDescription:message]];
            }
        } onError:^(NSError *error) {
            [wself.subscriber sendError:error];
        }];
    } else {
        [self.subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:@"网络异常，请检查网络"]];
    }
}

-(void)falseReceiveGetDataMethod:(NSString *)str {
    [self.tcpHandle clearDelegateAndClose];
    [self.subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:@"网络异常，请检查网络"]];
}


# pragma mask 4 getter

- (TcpClientService *)tcpHandle {
    if (!_tcpHandle) {
        _tcpHandle = [[TcpClientService alloc] init];
        _tcpHandle.delegate = self;
    }
    return _tcpHandle;
}

- (RACCommand *)cmdUploader {
    @weakify(self);
    if (!_cmdUploader) {
        _cmdUploader = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                
                @strongify(self);
                
                ModelTCPTransPacking* mTCPPacking = [[ModelTCPTransPacking alloc] init];//sharedModel];
                [mTCPPacking packingFieldsInfo:self.pakingInfo forTransType:TranType_ElecSignPicUpload];
                NSString* tcpSendMsg = [mTCPPacking packageFinalyPacking];
                
                [subscriber sendNext:nil];
                self.subscriber = subscriber;
                [self.tcpHandle sendOrderMethod:tcpSendMsg
                                             IP:[PublicInformation getServerDomain]
                                           PORT:[PublicInformation getTcpPort].intValue
                                       Delegate:self
                                         method:TranType_ElecSignPicUpload];
                
                return nil;
            }] materialize];
        }];
    }
    return _cmdUploader;
}


@end

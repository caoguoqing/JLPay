//
//  VMSettlementInfoRequestor.m
//  JLPay
//
//  Created by jielian on 16/7/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMSettlementInfoRequestor.h"
#import <ReactiveCocoa.h>
#import "ModelSettlementInformation.h"
#import "VMT_0InfoRequester.h"
#import "MLoginSavedResource.h"


@implementation VMSettlementInfoRequestor

- (RACCommand *)cmdRequestStlInfo {
    if (!_cmdRequestStlInfo) {
        _cmdRequestStlInfo = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                
                [[VMT_0InfoRequester sharedInstance] requestT_0InformationWithBusinessNumbser:[MLoginSavedResource sharedLoginResource].businessNumber onSucBlocK:^{
                    VMT_0InfoRequester* vmT0Requester = [VMT_0InfoRequester sharedInstance];
                    // 查询的结果暂时不做任何处理，在点击刷卡时，再判断进行处理
                    if ([vmT0Requester enableT_0]) {
                        [ModelSettlementInformation sharedInstance].curSettlementType = SETTLEMENTTYPE_T_0;
                    } else {
                        [ModelSettlementInformation sharedInstance].curSettlementType = SETTLEMENTTYPE_T_1;
                    }
                } onErrorBlock:^(NSError *error) {
                    [ModelSettlementInformation sharedInstance].curSettlementType = SETTLEMENTTYPE_T_1;
                }];

                return nil;
            }];
        }];
    }
    return _cmdRequestStlInfo;
}


@end

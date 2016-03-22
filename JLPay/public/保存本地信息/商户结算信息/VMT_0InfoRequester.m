//
//  VMT_0InfoRequester.m
//  JLPay
//
//  Created by jielian on 16/3/21.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMT_0InfoRequester.h"
#import "HTTPInstance.h"
#import "PublicInformation.h"


 NSString* const kFieldNameRequestBusinessNum = @"mchtNo";

 NSString* const kFieldNameResponseCode = @"code";
 NSString* const kFieldNameResponseMessage = @"message";

 NSString* const kFieldNameResponseAllowFlag = @"allowFlag"; // 是否允许T+0
 NSString* const kFieldNameResponseDayTotal = @"dayTotal"; // 日总限额
 NSString* const kFieldNameResponseT0Fee = @"t0Fee"; // t+0费率
 NSString* const kFieldNameResponseCumMoney = @"cumMoney"; // 已刷T+0金额
 NSString* const kFieldNameResponseCompareMoney = @"compareMoney";// 比较金额(刷卡金额小于此需要+额外的手续费)
 NSString* const kFieldNameResponseExtraFee = @"extraFee";  // 额外的手续费
 NSString* const kFieldNameResponseMinTradeMoney = @"minTradeMoney"; // 最小刷卡额


@interface VMT_0InfoRequester()

@property (nonatomic, strong) HTTPInstance* http;
@property (nonatomic, copy) NSDictionary* T_0InfoRequested;

@end
@implementation VMT_0InfoRequester

+ (instancetype)sharedInstance {
    static VMT_0InfoRequester* shared;
    static dispatch_once_t dispOncet;
    dispatch_once(&dispOncet, ^{
        shared = [[VMT_0InfoRequester alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)requestT_0InformationWithBusinessNumbser:(NSString *)businessNumber
                                      onSucBlocK:(void (^)(void))sucBlock
                                    onErrorBlock:(void (^)(NSError *))errBlock
{
    NameWeakSelf(wself);
    [self.http requestingOnPackingHandle:^(ASIFormDataRequest *http) {
        [http addPostValue:businessNumber forKey:kFieldNameRequestBusinessNum];
    } onSucBlock:^(NSDictionary *info) {
        wself.T_0InfoRequested = info;
        sucBlock();
    } onErrBlock:^(NSError *error) {
        errBlock(error);
    }];
}

/* 终止 */
- (void) requestTerminate {
    [self.http terminateRequesting];
}


// -- 是否允许T+0
- (BOOL) enableT_0 {
    NSString* allowFlag = [self.T_0InfoRequested objectForKey:kFieldNameResponseAllowFlag];
    if ([allowFlag integerValue] == 0) {
        return NO;
    } else {
        return YES;
    }
}
// -- 当日限额
- (NSString*) amountLimit {
    NSString* limit = [self.T_0InfoRequested objectForKey:kFieldNameResponseDayTotal];
    return [NSString stringWithFormat:@"%.02f",[limit floatValue]];
}
// -- 剩余可刷
- (NSString*) amountAvilable {
    NSString* custMoney = [self.T_0InfoRequested objectForKey:kFieldNameResponseCumMoney];
    NSString* limit = [self.T_0InfoRequested objectForKey:kFieldNameResponseDayTotal];
    return [NSString stringWithFormat:@"%.02f",[limit floatValue] - [custMoney floatValue]];
}
// -- 单笔最小可刷
- (NSString*) amountMinCust {
    NSString* min = [self.T_0InfoRequested objectForKey:kFieldNameResponseMinTradeMoney];
    return [NSString stringWithFormat:@"%.02f",[min floatValue]];
}
// -- 增加的费率
- (NSString*) T_0MoreRate {
    NSString* moreRate = [self.T_0InfoRequested objectForKey:kFieldNameResponseT0Fee];
    return [NSString stringWithFormat:@"%.02f",[moreRate floatValue]];
}
// -- 额外手续费
- (NSString*) T_0ExtraFee {
    NSString* extraFee = [self.T_0InfoRequested objectForKey:kFieldNameResponseExtraFee];
    return [NSString stringWithFormat:@"%.02f",[extraFee floatValue]];
}
// -- 比较金额
- (NSString*) compareMoney {
    NSString* compared = [self.T_0InfoRequested objectForKey:kFieldNameResponseCompareMoney];
    return [NSString stringWithFormat:@"%.02f",[compared floatValue]];
}




#pragma mask 4 getter 
- (HTTPInstance *)http {
    if (!_http) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/getT0Info", [PublicInformation getServerDomain],[PublicInformation getHTTPPort]];
        _http = [[HTTPInstance alloc] initWithURLString:urlString];
    }
    return _http;
}

@end

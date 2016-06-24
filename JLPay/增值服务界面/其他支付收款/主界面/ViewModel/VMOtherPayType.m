//
//  VMOtherPayType.m
//  JLPay
//
//  Created by jielian on 16/4/15.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMOtherPayType.h"

@implementation VMOtherPayType

+ (instancetype)sharedInstance {
    static VMOtherPayType* payType;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        payType = [[VMOtherPayType alloc] init];
    });
    return payType;
}


# pragma mask 4 getter
- (NSString *)orderDes {
    return @"订单描述";
}
- (NSString *)goodsName {
    switch (BranchAppName) {
        case 0:
            return [@"捷联通-" stringByAppendingString:[PublicInformation returnBusinessName]];
            break;
        case 1:
            return [@"微乐刷-" stringByAppendingString:[PublicInformation returnBusinessName]];
            break;
        case 2:
            return [@"欧尔支付-" stringByAppendingString:[PublicInformation returnBusinessName]];
            break;
        case 3:
            return [@"快付通-" stringByAppendingString:[PublicInformation returnBusinessName]];
            break;
        default:
            return [@"捷联通-" stringByAppendingString:[PublicInformation returnBusinessName]];
            break;
    }
}


@end

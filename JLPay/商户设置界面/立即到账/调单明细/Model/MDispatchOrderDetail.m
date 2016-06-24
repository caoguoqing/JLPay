//
//  MDispatchOrderDetail.m
//  JLPay
//
//  Created by jielian on 16/5/23.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MDispatchOrderDetail.h"
#import "Define_Header.h"

@implementation MDispatchOrderDetail

+ (instancetype)orderDetailWithNode:(NSDictionary *)node {
    MDispatchOrderDetail* detail = [[MDispatchOrderDetail alloc] init];
    detail.detailNode = [node copy];
    return detail;
}

# pragma mask 4 getter

- (NSString *)businessName {
    return [self.detailNode objectForKey:@"mchtNm"];
}
- (NSString *)businessNo {
    return [self.detailNode objectForKey:@"mchtNo"];
}
- (NSString *)cardNo {
    NSString* pan = [self.detailNode objectForKey:@"pan"];
    if (pan && pan.length > 6 + 4) {
        return [PublicInformation cuttingOffCardNo:pan];
    } else {
        return pan;
    }
}
- (NSString *)terminalNo {
    return [self.detailNode objectForKey:@"termNo"];
}
- (NSString *)transType {
    return [self.detailNode objectForKey:@"mchtNo"];
}
- (NSString *)transMoney {
    return [PublicInformation dotMoneyFromNoDotMoney:[self.detailNode objectForKey:@"amtTrans"]];
}
- (NSString *)transDate {
    NSString* date = [self.detailNode objectForKey:@"updtDate"];
    return [NSString formatedDateStringFromSourceTime:date];
}
- (NSString *)transTime {
    NSString* date = [self.detailNode objectForKey:@"updtDate"];
    return [NSString formatedTimeStringFromSourceTime:date];
}
- (NSString *)originDateAndTime {
    return [self.detailNode objectForKey:@"updtDate"];
}
- (NSString *)circBankNo {
    return [self.detailNode objectForKey:@"mchtNo"];
}
- (NSString *)seqNo {
    return [self.detailNode objectForKey:@"sysSeqNum"];
}
- (NSString *)batchNo {
    return [self.detailNode objectForKey:@"mchtNo"];
}
- (NSString *)authNo {
    return [self.detailNode objectForKey:@"mchtNo"];
}
- (NSString *)referenceNo {
    return [self.detailNode objectForKey:@"retrivlRef"];
}
- (NSString *)effecDate {
    return [self.detailNode objectForKey:@"mchtNo"];
}

- (BOOL)uploadted {
    if ([[self.detailNode objectForKey:@"uploadFlag"] integerValue] == 0) {
        return YES;
    } else {
        return NO;
    }
}

- (NSInteger)checkedFlag {
    return [[self.detailNode objectForKey:@"checkFlag"] integerValue];
}

- (NSString *)dispatchReason {
    return [self.detailNode objectForKey:@"dispatchReason"];
}
- (NSString *)dispatchExplain {
    return [self.detailNode objectForKey:@"needUploadData"];
}
- (NSString *)refuseReason {
    return [self.detailNode objectForKey:@"refuseReason"];
}


@end

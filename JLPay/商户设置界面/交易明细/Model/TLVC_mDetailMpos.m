//
//  TLVC_mDetailMpos.m
//  JLPay
//
//  Created by jielian on 2017/1/13.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "TLVC_mDetailMpos.h"

@implementation TLVC_mDetailMpos

+ (instancetype)detailWidthNode:(NSDictionary *)node  {
    TLVC_mDetailMpos* detail = [TLVC_mDetailMpos new];
    detail.respCode = [[node objectForKey:@"respCode"] integerValue] == 0 ? YES : NO;
    detail.instDate = [node[@"instDate"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    detail.instTime = [node[@"instTime"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    detail.pan = [node[@"pan"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    detail.amtTrans = [node[@"amtTrans"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    detail.cardAccpId = [node[@"cardAccpId"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    detail.cardAccpTermId = [node[@"cardAccpTermId"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    detail.cardAccpName = [node[@"cardAccpName"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    detail.sysSeqNum = [node[@"sysSeqNum"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    detail.retrivlRef = [node[@"retrivlRef"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    detail.txnNum = [node[@"txnNum"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    detail.fldReserved = [node[@"fldReserved"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    detail.revsal_flag = [[node objectForKey:@"revsal_flag"] integerValue];
    detail.acqInstIdCode = [node[@"acqInstIdCode"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    detail.cancelFlag = [[node objectForKey:@"cancelFlag"] integerValue];
    detail.clearType = [[node objectForKey:@"clearType"] integerValue];
    detail.refuseReason = [node[@"refuseReason"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    detail.settleMoney = [node[@"settleMoney"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    detail.settleFlag = [[node objectForKey:@"settleFlag"] integerValue];
    return detail;
}


- (id)copyWithZone:(NSZone *)zone {
    TLVC_mDetailMpos* detail = [TLVC_mDetailMpos allocWithZone:zone];
    detail.respCode = self.respCode;
    detail.instDate = self.instDate;
    detail.instTime = self.instTime;
    detail.pan = self.pan;
    detail.amtTrans = self.amtTrans;
    detail.cardAccpId = self.cardAccpId;
    detail.cardAccpTermId = self.cardAccpTermId;
    detail.cardAccpName = self.cardAccpName;
    detail.sysSeqNum = self.sysSeqNum;
    detail.retrivlRef = self.retrivlRef;
    detail.txnNum = self.txnNum;
    detail.fldReserved = self.fldReserved;
    detail.revsal_flag = self.revsal_flag;
    detail.acqInstIdCode = self.acqInstIdCode;
    detail.cancelFlag = self.cancelFlag;
    detail.clearType = self.clearType;
    detail.refuseReason = self.refuseReason;
    detail.settleMoney = self.settleMoney;
    detail.settleFlag = self.settleFlag;
    return detail;
}


@end

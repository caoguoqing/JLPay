//
//  MBR_HTTP_getBusiness.h
//  JLPay
//
//  Created by jielian on 16/8/30.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MBR_HTTP_getBusiness : NSObject



+ (void) getBusinessListWithRateType:(NSString*)rateType
                         andCityCode:(NSString*)cityCode
                          onFinished:(void (^) (NSArray* businessList))finishedBlock /* mchtNo:mchtNm:termNo */
                             onError:(void (^) (NSError* error))errorBlock;


@end

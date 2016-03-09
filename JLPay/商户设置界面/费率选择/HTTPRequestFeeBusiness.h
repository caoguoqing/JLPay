//
//  HTTPRequestFeeBusiness.h
//  JLPay
//
//  Created by jielian on 15/12/23.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


/* 响应数据域名 - responseInfo */
static NSString* const kFeeBusinessListName = @"merchInfoList"; // 商户信息列表名
static NSString* const kFeeBusinessBusinessName = @"mchtNm"; // 商户名
static NSString* const kFeeBusinessBusinessNum = @"mchtNo"; // 商户号
static NSString* const kFeeBusinessTerminalNum = @"termNo"; // 终端号



@class HTTPRequestFeeBusiness;
@protocol HTTPRequestFeeBusinessDelegate <NSObject>

- (void) didRequestSuccessWithInfo:(NSDictionary*)responseInfo;
- (void) didRequestFailWithMessage:(NSString*)errorMessage;

@end


@interface HTTPRequestFeeBusiness : NSObject

- (void) requestFeeBusinessOnFeeType:(NSString*)feeType
                            areaCode:(NSString*)areaCode
                            delegate:(id<HTTPRequestFeeBusinessDelegate>)delegate;

- (void) requestFeeBusinessOnFeeType:(NSString*)feeType
                            areaCode:(NSString*)areaCode
                          onSucBlock:(void (^) (NSArray* businessInfos))sucBlock
                          onErrBlock:(void (^) (NSError* error))errBlock;

- (void) terminateRequest;

@end

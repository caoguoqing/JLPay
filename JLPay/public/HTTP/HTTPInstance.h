//
//  HTTPInstance.h
//  JLPay
//
//  Created by jielian on 15/12/15.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "Define_Header.h"

@class HTTPInstance;


/* -- 错误信息域名 -- */
static NSString* const kHTTPInstanceErrorCode = @"kHTTPInstanceErrorCode__"; // 错误码
static NSString* const kHTTPInstanceErrorMessage = @"kHTTPInstanceErrorMessage__"; // 错误信息

/* -- 错误码枚举 -- */
typedef enum {
    HTTPErrorCodeDefault = 99,              // 普通错误
    HTTPErrorCodeConnectFail = 01,          // 连接失败
    HTTPErrorCodeUnpackingFail = 02,        // 解析拆包失败
    HTTPErrorCodeResponseNormal = 10,        // HTTP响应错误码(普通)
    
    HTTPErrorCodeResponseNoneData = 401     // 查无数据
    // 701,802还未定义
} HTTPErrorCode;


@protocol HTTPInstanceDelegate <NSObject>


/* 请求成功: 返回参数在字典中 */
- (void) httpInstance:(HTTPInstance*)httpInstance didRequestingFinishedWithInfo:(NSDictionary*)info;

/* 请求失败: 错误参数在字典中 */
- (void) httpInstance:(HTTPInstance*)httpInstance didRequestingFailedWithError:(NSDictionary*)errorInfo;

@end


@interface HTTPInstance : NSObject

@property (nonatomic, retain) ASIFormDataRequest* httpRequester;

- (instancetype) initWithURLString:(NSString*)URLString ;

/* 请求: delegate */
- (void) startRequestingWithDelegate:(id<HTTPInstanceDelegate>)delegate
                       packingHandle:(void (^)(ASIFormDataRequest* http))packingBlock;

/* 请求: block 区分错误码 */
- (void) requestingOnPackingHandle:(void (^) (ASIFormDataRequest* http))packingBlock
                        onSucBlock:(void (^) (NSDictionary* info))sucBlock
                        onErrBlock:(void (^) (NSError* error))errBlock;

/* 请求: block 不区分错误码 */
- (void) requestingOnPackingBlock:(void (^) (ASIFormDataRequest* http))packingBlock
                  onFinishedBlock:(void (^) (NSDictionary* info))finishedBlock
                     onErrorBlock:(void (^) (NSError* error))errorBlock;


/* 终止请求 */
- (void) terminateRequesting;


@end

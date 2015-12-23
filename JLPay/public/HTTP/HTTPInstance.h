//
//  HTTPInstance.h
//  JLPay
//
//  Created by jielian on 15/12/15.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

@class HTTPInstance;


/* -- 错误信息域名 -- */
static NSString* const kHTTPInstanceErrorCode = @"kHTTPInstanceErrorCode__"; // 错误码
static NSString* const kHTTPInstanceErrorMessage = @"kHTTPInstanceErrorMessage__"; // 错误信息

/* -- 错误码枚举 -- */
typedef enum {
    HTTPErrorCodeDefault = 99,              // 普通错误
    HTTPErrorCodeConnectFail = 01,          // 连接失败
    HTTPErrorCodeUnpackingFail = 02,        // 解析拆包失败
    HTTPErrorCodeResponseNormal = 10        // HTTP响应错误码(普通)
    // 701,802还未定义
} HTTPErrorCode;


@protocol HTTPInstanceDelegate <NSObject>

/* 回调: 在回调中进行自定义参数打包 */
//- (void) willPackParamsOnRequester:(ASIHTTPRequest*)http;

/* 请求成功: 返回参数在字典中 */
- (void) httpInstance:(HTTPInstance*)httpInstance didRequestingFinishedWithInfo:(NSDictionary*)info;

/* 请求失败: 错误参数在字典中 */
- (void) httpInstance:(HTTPInstance*)httpInstance didRequestingFailedWithError:(NSDictionary*)errorInfo;

@end


@interface HTTPInstance : NSObject

//+ (instancetype) requestWithURLString:(NSString*)URLString;
//@property (nonatomic, readonly) void (^packingForHttp)(HTTPInstance* http);

- (instancetype) initWithURLString:(NSString*)URLString ;

/* 开始请求 */
- (void) startRequestingWithDelegate:(id<HTTPInstanceDelegate>)delegate
                       packingHandle:(void (^)(ASIFormDataRequest* http))packingBlock;
/* 终止请求 */
- (void) terminateRequesting;


@end

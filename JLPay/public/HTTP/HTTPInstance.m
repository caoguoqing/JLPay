//
//  HTTPInstance.m
//  JLPay
//
//  Created by jielian on 15/12/15.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "HTTPInstance.h"

NSString* const HTTPInstanceDomain = @"HTTPInstanceDomain";

@interface HTTPInstance()
<ASIHTTPRequestDelegate>
{
    NSString* urlString;
}
@property (nonatomic, assign) id<HTTPInstanceDelegate>delegate;
@property (nonatomic, retain) ASIFormDataRequest* httpRequester;

@property (nonatomic, copy) void (^ httpSucBlock) (NSDictionary* info);
@property (nonatomic, copy) void (^ httpErrBlock) (NSError* error);

@end


static HTTPInstance* pubHttpInstance = nil;

@implementation HTTPInstance


- (instancetype) initWithURLString:(NSString*)URLString {
    self = [super init];
    if (self) {
        if (URLString) {
            urlString = URLString;
        }
    }
    return self;
}

/* 开始请求 */
- (void) startRequestingWithDelegate:(id<HTTPInstanceDelegate>)delegate
                       packingHandle:(void (^)(ASIFormDataRequest* http))packingBlock
{
    self.delegate = delegate;
    if (self.httpRequester) {
        // 在代理中打包请求的参数
        packingBlock(self.httpRequester);
        [self.httpRequester setDelegate:self];
        [self.httpRequester startAsynchronous];
    } else {
        [self rebackFailCode:HTTPErrorCodeDefault andMessage:@"HTTP请求失败"];
    }
}

- (void)requestingOnPackingHandle:(void (^)(ASIFormDataRequest *))packingBlock
                       onSucBlock:(void (^)(NSDictionary *))sucBlock
                       onErrBlock:(void (^)(NSError *))errBlock
{
    self.httpSucBlock = sucBlock;
    self.httpErrBlock = errBlock;
    if (self.httpRequester) {
        packingBlock(self.httpRequester);
        [self.httpRequester setDelegate:self];
        [self.httpRequester startAsynchronous];
    } else {
        [self rebackFailCode:HTTPErrorCodeDefault andMessage:@"HTTP请求失败"];
    }
}

/* 终止请求 */
- (void) terminateRequesting {
    self.delegate = nil;
    [self.httpRequester clearDelegatesAndCancel];
    self.httpRequester = nil;
}

#pragma mask ---- ASIHTTPRequestDelegate
- (void) requestFinished:(ASIHTTPRequest *)request {
    NSData* data = [request responseData];
    NSDictionary* resHeader = [request responseHeaders];

    [self.httpRequester clearDelegatesAndCancel];
    NSError* error;
    NSDictionary* resData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        [self rebackFailCode:HTTPErrorCodeUnpackingFail andMessage:@"响应数据拆包失败"];
    }
    else {
        NSString* errorCode = nil;
        NSString* errorMessage = nil;
        errorCode = [resData objectForKey:@"code"];
        errorMessage = [resData objectForKey:@"message"];
        if (!errorCode) {
            errorCode = [resHeader objectForKey:@"HttpResult"];
            errorMessage = [resHeader objectForKey:@"HttpMessage"];
        }
        if (errorCode) {
            if (errorCode.integerValue == 0) {
                // 成功
                [self rebackSuccessWithInfo:resData];
            }
            else if (errorCode.integerValue == 401) {
                // 查无数据
                [self rebackFailCode:HTTPErrorCodeResponseNoneData andMessage:errorMessage];
            }
            else {
                // 失败: 后期可能需要枚举部分返回码
                [self rebackFailCode:HTTPErrorCodeDefault andMessage:errorMessage];
            }
        }
        else {
            [self rebackFailCode:HTTPErrorCodeDefault andMessage:@"响应数据无响应码"];
        }
    }
    self.httpRequester = nil;
}

- (void) requestFailed:(ASIHTTPRequest *)request {
    [self.httpRequester clearDelegatesAndCancel];
    [self rebackFailCode:HTTPErrorCodeConnectFail andMessage:@"网络异常"];
    self.httpRequester = nil;
}


#pragma mask ---- PRIVATE INTERFACE 
/* 打包错误信息 */
- (NSDictionary*) errorInfoMadeByCode:(NSString*)code andMessage:(NSString*)message {
    NSMutableDictionary* errorInfo = [[NSMutableDictionary alloc] init];
    [errorInfo setObject:code forKey:kHTTPInstanceErrorCode];
    [errorInfo setObject:message forKey:kHTTPInstanceErrorMessage];
    return errorInfo;
}

- (NSError*) errorOnCode:(NSInteger)code message:(NSString*)msg {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:HTTPInstanceDomain code:code userInfo:userInfo];
}

/* 成功回调 */
- (void) rebackSuccessWithInfo:(NSDictionary*)info {
    if (self.delegate && [self.delegate respondsToSelector:@selector(httpInstance:didRequestingFinishedWithInfo:)]) {
        [self.delegate httpInstance:self didRequestingFinishedWithInfo:info];
    }
    if (self.httpSucBlock) {
        self.httpSucBlock(info);
    }
}

/* 失败回调 */
- (void) rebackFailCode:(HTTPErrorCode)errorCode andMessage:(NSString*)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(httpInstance:didRequestingFailedWithError:)]) {
        [self.delegate httpInstance:self didRequestingFailedWithError:[self errorInfoMadeByCode:[NSString stringWithFormat:@"%d", errorCode] andMessage:message]];
    }
    if (self.httpErrBlock) {
        self.httpErrBlock([self errorOnCode:errorCode message:message]);
    }
}

#pragma mask ---- getter
- (ASIFormDataRequest *)httpRequester {
    if (_httpRequester == nil) {
        _httpRequester = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    }
    return _httpRequester;
}

@end

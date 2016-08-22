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

@property (nonatomic, copy) void (^ httpSucBlock) (NSDictionary* info);
@property (nonatomic, copy) void (^ httpFinishedBlock) (NSDictionary* responseInfo);
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

- (void)requestingOnPackingBlock:(void (^)(ASIFormDataRequest *))packingBlock
                 onFinishedBlock:(void (^)(NSDictionary *))finishedBlock
                    onErrorBlock:(void (^)(NSError *))errorBlock
{
    self.httpFinishedBlock = finishedBlock;
    self.httpErrBlock = errorBlock;
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
    JLPrint(@"---响应信息:[%@]",[request responseString]);
    [self.httpRequester clearDelegatesAndCancel];
    NSError* error;
    NSDictionary* resData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    self.httpRequester = nil;

    if (error) {
        [self rebackFailCode:HTTPErrorCodeUnpackingFail andMessage:@"响应数据拆包失败"];
    }
    else {
        /* 在外层区分响应码 */
        if (self.httpFinishedBlock) {
            self.httpFinishedBlock(resData);
        }
        /* 在本层区分响应码 */
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
                    [self rebackFailCode:errorCode.integerValue andMessage:errorMessage];
//                    [self rebackFailCode:HTTPErrorCodeDefault andMessage:errorMessage];
                }
            }
            else {
                [self rebackFailCode:HTTPErrorCodeDefault andMessage:@"响应数据无响应码"];
            }
        }
    }
//    self.httpRequester = nil;
}

- (void) requestFailed:(ASIHTTPRequest *)request {
    [self.httpRequester clearDelegatesAndCancel];
    [self rebackFailCode:95 andMessage:@"网络异常"]; // HTTPErrorCodeConnectFail 95
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
- (void) rebackFailCode:(NSInteger)errorCode andMessage:(NSString*)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(httpInstance:didRequestingFailedWithError:)]) {
        [self.delegate httpInstance:self didRequestingFailedWithError:[self errorInfoMadeByCode:[NSString stringWithFormat:@"%ld", errorCode] andMessage:message]];
    }
    if (self.httpErrBlock) {
        self.httpErrBlock([self errorOnCode:errorCode message:message]);
    }
}

#pragma mask ---- getter
- (ASIFormDataRequest *)httpRequester {
    if (_httpRequester == nil) {
        _httpRequester = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
        _httpRequester.timeOutSeconds = 20;
    }
    return _httpRequester;
}

@end

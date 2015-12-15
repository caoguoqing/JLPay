//
//  HTTPInstance.m
//  JLPay
//
//  Created by jielian on 15/12/15.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "HTTPInstance.h"

@interface HTTPInstance()
<ASIHTTPRequestDelegate>
@property (nonatomic, assign) id<HTTPInstanceDelegate>delegate;
@property (nonatomic, retain) ASIFormDataRequest* httpRequester;

@end


static HTTPInstance* pubHttpInstance = nil;

@implementation HTTPInstance


+ (instancetype) requestWithURLString:(NSString*)URLString {
    @synchronized(self) {
        if (pubHttpInstance == nil) {
            pubHttpInstance = [[HTTPInstance alloc] initWithURLString:URLString];
        }
        return pubHttpInstance;
    }
}

- (instancetype) initWithURLString:(NSString*)URLString {
    self = [super init];
    if (self) {
        if (URLString) {
            self.httpRequester = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:URLString]];
            [self.httpRequester setDelegate:self];
        }
    }
    return self;
}


/* 开始请求 */
- (void) startRequestingWithDelegate:(id<HTTPInstanceDelegate>)delegate {
    self.delegate = delegate;
    if (self.httpRequester) {
        // 在代理中打包请求的参数
        [delegate willPackParamsOnRequester:self.httpRequester];
        [self.httpRequester startAsynchronous];
    } else {
        [self rebackFailCode:HTTPErrorCodeDefault andMessage:@"HTTP请求失败"];
    }
}
/* 终止请求 */
- (void) terminateRequesting {
    self.delegate = nil;
    [self.httpRequester clearDelegatesAndCancel];
}

#pragma mask ---- ASIHTTPRequestDelegate
- (void) requestFinished:(ASIHTTPRequest *)request {
    NSData* data = [request responseData];
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
            errorCode = [resData objectForKey:@"HttpResult"];
            errorMessage = [resData objectForKey:@"HttpMessage"];
        }
        if (errorCode) {
            if (errorCode.integerValue == 0) {
                // 成功
                [self rebackSuccessWithInfo:resData];
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
}

- (void) requestFailed:(ASIHTTPRequest *)request {
    [self.httpRequester clearDelegatesAndCancel];
    NSLog(@"网络异常:[%@]",request.error);
    [self rebackFailCode:HTTPErrorCodeConnectFail andMessage:@"网络异常"];
}


#pragma mask ---- PRIVATE INTERFACE 
/* 打包错误信息 */
- (NSDictionary*) errorInfoMadeByCode:(NSString*)code andMessage:(NSString*)message {
    NSMutableDictionary* errorInfo = [[NSMutableDictionary alloc] init];
    [errorInfo setObject:code forKey:kHTTPInstanceErrorCode];
    [errorInfo setObject:message forKey:kHTTPInstanceErrorMessage];
    return errorInfo;
}


/* 成功回调 */
- (void) rebackSuccessWithInfo:(NSDictionary*)info {
    if (self.delegate && [self.delegate respondsToSelector:@selector(httpInstance:didRequestingFinishedWithInfo:)]) {
        [self.delegate httpInstance:self didRequestingFinishedWithInfo:info];
    }
}

/* 失败回调 */
- (void) rebackFailCode:(HTTPErrorCode)errorCode andMessage:(NSString*)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(httpInstance:didRequestingFailedWithError:)]) {
        [self.delegate httpInstance:self didRequestingFailedWithError:[self errorInfoMadeByCode:[NSString stringWithFormat:@"%d", errorCode] andMessage:message]];
    }
}

@end

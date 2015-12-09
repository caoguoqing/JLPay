//
//  ModelHTTPRequestLogin.m
//  JLPay
//
//  Created by jielian on 15/12/9.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ModelHTTPRequestLogin.h"
#import "ASIFormDataRequest.h"
#import "PublicInformation.h"




@interface ModelHTTPRequestLogin()
<ASIHTTPRequestDelegate>

@property (nonatomic, retain) ASIFormDataRequest* httpRequest;
@property (nonatomic, assign) id<ModelHTTPRequestLoginDelegate>delegate;

@end

static ModelHTTPRequestLogin* modelHTTPLogin = nil;

@implementation ModelHTTPRequestLogin

/* 公共入口 */
+ (instancetype) sharedInstance {
    @synchronized(self) {
        if (modelHTTPLogin == nil) {
            modelHTTPLogin = [[ModelHTTPRequestLogin alloc] init];
        }
        return modelHTTPLogin;
    }
}


#pragma mask ---- PUBLIC INTERFACE 
/* 登陆: 指定用户名、密码 */
- (void) loginWithUserID:(NSString*)userID
              andUserPWD:(NSString*)userPWD
                delegate:(id<ModelHTTPRequestLoginDelegate>)delegate
{
    self.delegate = delegate;
    // 执行请求
    [self requestWithUserID:userID andUserPWD:userPWD];
}

/* 停止登陆 */
- (void) terminateLogin {
    self.delegate = nil;
    [self.httpRequest clearDelegatesAndCancel];
    self.httpRequest = nil;
}

#pragma mask ---- HTTP & ASIHTTPRequestDelegate
/* 发起请求 */
- (void) requestWithUserID:(NSString*)userID andUserPWD:(NSString*)userPWD {
    // 用户名
    [self.httpRequest addPostValue:userID forKey:kFieldNameLoginUpUserID];
    // 密码
    [self.httpRequest addPostValue:userPWD forKey:kFieldNameLoginUpUserPWD];
    // 操作系统版本 0:IOS, 1:Android
    [self.httpRequest addPostValue:@"0" forKey:kFieldNameLoginUpSysFlag];
    // 版本号
    [self.httpRequest addPostValue:[self intStringOfAppVersion] forKey:kFieldNameLoginUpVersionNum];

    [self.httpRequest startAsynchronous];
}

/* 回调: HTTP响应成功 */
- (void)requestFinished:(ASIHTTPRequest *)request {
    [request clearDelegatesAndCancel];
    NSData* data = [request responseData];
    NSError* error = nil;
    NSDictionary* loginInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (!error) {
        NSString* code = [loginInfo objectForKey:kFieldNameLoginDownCode];
        NSString* message = [loginInfo objectForKey:kFieldNameLoginDownMessage];
        NSLog(@"登陆响应代码:[%@]",code);
        /* 响应码: 登陆成功 */
        if ([code intValue] == 0) {
            // 校验终端个数跟列表中是否一致
            NSArray* terminals = [[NSArray alloc] init];
            if ([[loginInfo objectForKey:kFieldNameLoginDownTerminalList] componentsSeparatedByString:@","]) {
                terminals = [NSArray arrayWithArray:[[loginInfo objectForKey:kFieldNameLoginDownTerminalList] componentsSeparatedByString:@","]];
            }
            if ([[loginInfo objectForKey:kFieldNameLoginDownTerminalCount] intValue] == terminals.count)
            {
                [self rebackSuccessWithLoginInfo:loginInfo];
            } else {
                [self rebackFailWithMessage:@"终端个数返回异常" andErrorType:LoginErrorCodeTypeDefault];
            }
        }
        /* 响应码: 版本过低 */
        else if ([code intValue] == LoginErrorCodeTypeLowVersion) {
            [self rebackFailWithMessage:message andErrorType:LoginErrorCodeTypeLowVersion];
        }
        /* 响应码: 注册审核拒绝 */
        else if ([code intValue] == LoginErrorCodeTypeRegistRefuse) {
            self.lastRegisterInfo = [NSDictionary dictionaryWithDictionary:[loginInfo objectForKey:kFieldNameLoginDownRegisterInfo]];
            [self rebackFailWithMessage:message andErrorType:LoginErrorCodeTypeRegistRefuse];
        }
        /* 响应码: 其他错误 */
        else {
            [self rebackFailWithMessage:message andErrorType:LoginErrorCodeTypeDefault];
        }
    }
    else {
        [self rebackFailWithMessage:@"解析登陆响应数据失败" andErrorType:LoginErrorCodeTypeDefault];
    }
    
    self.httpRequest = nil;
}

/* 回调: HTTP响应失败 */
- (void)requestFailed:(ASIHTTPRequest *)request {
    [request clearDelegatesAndCancel];
    self.httpRequest = nil;
    [self rebackFailWithMessage:@"网络异常,请检查网络" andErrorType:LoginErrorCodeTypeDefault];
}


#pragma mask ---- PRIVATE INTERFACE
/* 获取App版本号: 无小数点格式 */
- (NSString*) intStringOfAppVersion {
    NSString* version = [PublicInformation AppVersionNumber];
    version = [version stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSLog(@"去掉小数点的版本号:[%@]",version);
    return version;
}

/* 失败回调 */
- (void) rebackFailWithMessage:(NSString*)message andErrorType:(LoginErrorCodeType)errorType {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didLoginFailWithErrorMessage:andErrorType:)]) {
        [self.delegate didLoginFailWithErrorMessage:message andErrorType:errorType];
    }
}
/* 成功回调 */
- (void) rebackSuccessWithLoginInfo:(NSDictionary*)loginInfo {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didLoginSuccessWithLoginInfo:)]) {
        [self.delegate didLoginSuccessWithLoginInfo:loginInfo];
    }
}

#pragma mask ---- 初始化 & 销毁
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}
- (void)dealloc {
    [self terminateLogin];
}

#pragma mask ---- getter
- (ASIFormDataRequest *)httpRequest {
    if (_httpRequest == nil) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/LoginService",
                               [PublicInformation getServerDomain],
                               [PublicInformation getHTTPPort]];
        _httpRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        _httpRequest.delegate = self;
    }
    return _httpRequest;
}


@end

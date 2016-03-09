//
//  HTTPRequestFeeBusiness.m
//  JLPay
//
//  Created by jielian on 15/12/23.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "HTTPRequestFeeBusiness.h"
#import "HTTPInstance.h"
#import "PublicInformation.h"


static NSString* const kHttpBusinessErrorDomainName = @"kHttpBusinessErrorDomainName";


@interface HTTPRequestFeeBusiness()
<HTTPInstanceDelegate>
@property (nonatomic, strong) HTTPInstance* http;
@property (nonatomic, assign) id<HTTPRequestFeeBusinessDelegate>delegate;

@property (nonatomic, copy) void (^ requestSucBlock) (NSArray* businessArray);
@property (nonatomic, copy) void (^ requestErrBlock) (NSError* error);


@end

@implementation HTTPRequestFeeBusiness

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

/* 请求数据 */
- (void)requestFeeBusinessOnFeeType:(NSString *)feeType
                           areaCode:(NSString *)areaCode
                           delegate:(id<HTTPRequestFeeBusinessDelegate>)delegate
{
    self.delegate = delegate;
    [self.http startRequestingWithDelegate:self packingHandle:^(ASIFormDataRequest *http) {
        [http addPostValue:feeType forKey:@"feeType"];
        [http addPostValue:areaCode forKey:@"areaCode"];
        [http addPostValue:[PublicInformation returnBusiness] forKey:@"mchtNo"];
    }];
}
// block 的申请接口
- (void) requestFeeBusinessOnFeeType:(NSString*)feeType
                            areaCode:(NSString*)areaCode
                          onSucBlock:(void (^) (NSArray* businessInfos))sucBlock
                          onErrBlock:(void (^) (NSError* error))errBlock
{
    self.requestSucBlock = sucBlock;
    self.requestErrBlock = errBlock;
    
    [self.http startRequestingWithDelegate:self packingHandle:^(ASIFormDataRequest *http) {
        [http addPostValue:feeType forKey:@"feeType"];
        [http addPostValue:areaCode forKey:@"areaCode"];
        [http addPostValue:[PublicInformation returnBusiness] forKey:@"mchtNo"];
    }];
}

/* 终止请求 */
- (void)terminateRequest {
    self.delegate = nil;
    [self.http terminateRequesting];
}

#pragma mask ---- HTTPInstanceDelegate
- (void)httpInstance:(HTTPInstance *)httpInstance didRequestingFailedWithError:(NSDictionary *)errorInfo
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRequestFailWithMessage:)]) {
        [self.delegate didRequestFailWithMessage:[errorInfo objectForKey:kHTTPInstanceErrorMessage]];
    }
    if (self.requestErrBlock) {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[errorInfo objectForKey:kHTTPInstanceErrorMessage] forKey:NSLocalizedDescriptionKey];
        NSError* error = [NSError errorWithDomain:kHttpBusinessErrorDomainName code:[[errorInfo objectForKey:kHTTPInstanceErrorCode] integerValue] userInfo:userInfo];
        self.requestErrBlock(error);
    }
}
- (void)httpInstance:(HTTPInstance *)httpInstance didRequestingFinishedWithInfo:(NSDictionary *)info
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRequestSuccessWithInfo:)]) {
        [self.delegate didRequestSuccessWithInfo:info];
    }
    if (self.requestSucBlock) {
        self.requestSucBlock([info objectForKey:kFeeBusinessListName]);
    }
}


#pragma mask ---- getter
- (HTTPInstance *)http {
    if (_http == nil) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/getInstMchtInfo",
                               [PublicInformation getServerDomain],
                               [PublicInformation getHTTPPort]];
        _http = [[HTTPInstance alloc] initWithURLString:urlString];
    }
    return _http;
}

@end

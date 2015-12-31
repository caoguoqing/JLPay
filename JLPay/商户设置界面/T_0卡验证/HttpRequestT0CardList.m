//
//  HttpRequestT0CardList.m
//  JLPay
//
//  Created by jielian on 15/12/29.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "HttpRequestT0CardList.h"
#import "HTTPInstance.h"
#import "PublicInformation.h"

@interface HttpRequestT0CardList()
<HTTPInstanceDelegate>
@property (nonatomic, retain) HTTPInstance* http;
@property (nonatomic, assign) id<HttpRequestT0CardListDelegate> delegate;

@end


@implementation HttpRequestT0CardList

+ (instancetype) sharedInstance {
    static HttpRequestT0CardList* httpModel = nil;
    static dispatch_once_t dispatchOnceKey;
    
    dispatch_once(&dispatchOnceKey, ^{
        httpModel = [[HttpRequestT0CardList alloc] init];
    });
    return httpModel;
}
- (instancetype)init {
    self = [super init];
    return self;
}

- (void) requestT_0CardListOnDelegate:(id<HttpRequestT0CardListDelegate>)delegate {
    self.delegate = delegate;
    [self.http startRequestingWithDelegate:self packingHandle:^(ASIFormDataRequest *http) {
        // 填充参数
    }];
}
- (void)terminateRequesting {
    self.delegate = nil;
    [self.http terminateRequesting];
}


- (NSInteger) countOfCardsRequested {
    return 1;
}

- (NSString*) cardRequestedAtIndex:(NSInteger)index {
    return @"1234567890";
}
- (NSString*) nameRequestedAtIndex:(NSInteger)index {
    return @"jlpayTest";
}
- (NSString*) stateRequestedAtIndex:(NSInteger)index {
    return @"0";
}

#pragma mask ---- HTTPInstanceDelegate
- (void)httpInstance:(HTTPInstance *)httpInstance didRequestingFinishedWithInfo:(NSDictionary *)info {
    // 解析响应数据
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRequestSuccess)]) {
        [self.delegate didRequestSuccess];
    }
}
- (void)httpInstance:(HTTPInstance *)httpInstance didRequestingFailedWithError:(NSDictionary *)errorInfo {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRequestFail:)]) {
        [self.delegate didRequestFail:errorInfo[kHTTPInstanceErrorMessage]];
    }
}

#pragma mask ---- getter 
- (HTTPInstance *)http {
    if (_http == nil) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/",
                               [PublicInformation getServerDomain],
                               [PublicInformation getHTTPPort]];
        _http = [[HTTPInstance alloc] initWithURLString:urlString];
    }
    return _http;
}

@end

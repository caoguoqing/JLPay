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

// http请求字段
static NSString* const kT0CardListRequestFieldMchtNo = @"mchtNo";

// http响应字段
static NSString* const kT0CardListResponseFieldCardList = @"cardList";
static NSString* const kT0CardListResponseFieldCardNo = @"cardId";
static NSString* const kT0CardListResponseFieldCardUserName = @"cardUserName";
static NSString* const kT0CardListResponseFieldCheckFlag = @"checkFlag";
static NSString* const kT0CardListResponseFieldRefuseReason = @"refuseReason";



@interface HttpRequestT0CardList()
<HTTPInstanceDelegate>
@property (nonatomic, retain) HTTPInstance* http;
@property (nonatomic, assign) id<HttpRequestT0CardListDelegate> delegate;
@property (nonatomic, copy) NSArray* cardInfoList;
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
    self.cardInfoList = nil;
    [self.http startRequestingWithDelegate:self packingHandle:^(ASIFormDataRequest *http) {
        [http addPostValue:[PublicInformation returnBusiness] forKey:kT0CardListRequestFieldMchtNo];
    }];
}
- (void)terminateRequesting {
    self.delegate = nil;
    [self.http terminateRequesting];
}


- (NSInteger) countOfCardsRequested {
    if (self.cardInfoList) {
        return self.cardInfoList.count;
    } else {
        return 0;
    }
}

- (NSString*) cardRequestedAtIndex:(NSInteger)index {
    NSString* card = nil;
    if (index >=0 && index < [self countOfCardsRequested]) {
        NSDictionary* cardInfo = [self.cardInfoList objectAtIndex:index];
        card = [cardInfo objectForKey:kT0CardListResponseFieldCardNo];
    }
    return card;
}
- (NSString*) nameRequestedAtIndex:(NSInteger)index {
    NSString* name = nil;
    if (index >=0 && index < [self countOfCardsRequested]) {
        NSDictionary* cardInfo = [self.cardInfoList objectAtIndex:index];
        name = [cardInfo objectForKey:kT0CardListResponseFieldCardUserName];
    }
    return name;
}
- (NSString*) stateRequestedAtIndex:(NSInteger)index {
    NSString* state = nil;
    if (index >=0 && index < [self countOfCardsRequested]) {
        NSDictionary* cardInfo = [self.cardInfoList objectAtIndex:index];
        state = [cardInfo objectForKey:kT0CardListResponseFieldCheckFlag];
    }
    return state;
}
- (NSString*) descriptionStateAtIndex:(NSInteger)index {
    NSString* description = nil;
    NSString* state = [self stateRequestedAtIndex:index];
    if ([state isEqualToString:kT0CardCheckFlagChecked]) {
        description = @"已校验";
    }
    else if ([state isEqualToString:kT0CardCheckFlagChecking]) {
        description = @"正在校验";
    }
    else if ([state isEqualToString:kT0CardCheckFlagError]) {
        description = [NSString stringWithFormat:@"校验失败:%@",[self refusedDescriptionAtIndex:index]];
    }
    return description;
}


#pragma mask 1 PRIVATE INTERFACE
- (NSDictionary*) nodeAtIndex:(NSInteger)index {
    NSDictionary* node = nil;
    if (index >=0 && index < [self countOfCardsRequested]) {
        node = self.cardInfoList[index];
    }
    return node;
}
- (NSString*) refusedDescriptionAtIndex:(NSInteger)index {
    NSString* refused = nil;
    NSDictionary* node = [self nodeAtIndex:index];
    if (node) {
        refused = node[kT0CardListResponseFieldRefuseReason];
    }
    return refused;
}

#pragma mask ---- HTTPInstanceDelegate
- (void)httpInstance:(HTTPInstance *)httpInstance didRequestingFinishedWithInfo:(NSDictionary *)info {
    // 解析响应数据
    self.cardInfoList = [NSArray arrayWithArray:info[kT0CardListResponseFieldCardList]];
    
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
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/getT0CardInfo",
                               [PublicInformation getServerDomain],
                               [PublicInformation getHTTPPort]];
        _http = [[HTTPInstance alloc] initWithURLString:urlString];
    }
    return _http;
}

@end

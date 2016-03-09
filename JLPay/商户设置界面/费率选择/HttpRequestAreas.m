//
//  HttpRequestAreas.m
//  JLPay
//
//  Created by jielian on 16/3/3.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "HttpRequestAreas.h"
#import "HTTPInstance.h"
#import "PublicInformation.h"

static NSString* const kHttpAreasErrorDomainName = @"kHttpAreasErrorDomainName";

@interface HttpRequestAreas()
<HTTPInstanceDelegate>

@property (nonatomic, strong) HTTPInstance* http;
@property (nonatomic, copy) void (^requestSuccessWithAreas) (NSArray* areas);
@property (nonatomic, copy) void (^requestFailWithError) (NSError* error);

@end

@implementation HttpRequestAreas

- (void) requestAreasOnCode:(NSString*)areaCode
                 onSucBlock:(void (^) (NSArray* areas))sucBlock
                 onErrBlock:(void (^) (NSError* error))errBlock
{
    self.requestSuccessWithAreas = sucBlock;
    self.requestFailWithError = errBlock;
    [self.http startRequestingWithDelegate:self packingHandle:^(ASIFormDataRequest *http) {
        [http addPostValue:areaCode forKey:@"descr"];
    }];
}

- (void) terminateRequesting {
    [self.http terminateRequesting];
}


#pragma mask 2 HTTPInstanceDelegate
- (void) httpInstance:(HTTPInstance*)httpInstance didRequestingFinishedWithInfo:(NSDictionary*)info {
    NSArray* datas = [info objectForKey:@"areaList"];
    NSMutableArray* retDatas = [NSMutableArray array];
    if (datas) {
        [retDatas addObjectsFromArray:datas];
    }
    self.requestSuccessWithAreas(retDatas);
}

- (void) httpInstance:(HTTPInstance*)httpInstance didRequestingFailedWithError:(NSDictionary*)errorInfo {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[errorInfo objectForKey:kHTTPInstanceErrorMessage] forKey:NSLocalizedDescriptionKey];
    NSError* error = [NSError errorWithDomain:kHttpAreasErrorDomainName code:[[errorInfo objectForKey:kHTTPInstanceErrorCode] integerValue] userInfo:userInfo];
    self.requestFailWithError(error);
}


#pragma mask 4 getter 
- (HTTPInstance *)http {
    if (_http == nil) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/getAreaList",
                               [PublicInformation getServerDomain],
                               [PublicInformation getHTTPPort]];
        _http = [[HTTPInstance alloc] initWithURLString:urlString];
    }
    return _http;
}


@end

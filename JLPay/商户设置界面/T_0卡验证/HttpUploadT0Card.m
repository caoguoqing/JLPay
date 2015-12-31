//
//  HttpUploadT0Card.m
//  JLPay
//
//  Created by jielian on 15/12/30.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "HttpUploadT0Card.h"
#import "HTTPInstance.h"
#import "PublicInformation.h"

static NSString* const kFieldNameT0CardRequestMchtNo = @"mchtNo";
static NSString* const kFieldNameT0CardRequestCardId = @"cardId";
static NSString* const kFieldNameT0CardRequestCardUserName = @"cardUserName";
static NSString* const kFieldNameT0CardRequestCardPhoto = @"cardPhoto";



@interface HttpUploadT0Card()
<HTTPInstanceDelegate>
@property (nonatomic, retain) HTTPInstance* http;
@property (nonatomic, assign) id<HttpUploadT0CardDelegate> delegate;

@end


@implementation HttpUploadT0Card


#pragma mask 0 初始化
+ (instancetype)sharedInstance {
    static HttpUploadT0Card* httpUploadT0Card = nil;
    static dispatch_once_t dispatchOnceHttpT0CardUpload;
    dispatch_once(&dispatchOnceHttpT0CardUpload, ^{
        httpUploadT0Card = [[HttpUploadT0Card alloc] init];
    });
    return httpUploadT0Card;
}
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)uploadCardNo:(NSString *)cardNo
      cardHolderName:(NSString *)cardHolderName
           cardPhoto:(UIImage *)cardImage
          onDelegate:(id<HttpUploadT0CardDelegate>)delegate
{
    self.delegate = delegate;
    [self.http startRequestingWithDelegate:self packingHandle:^(ASIFormDataRequest *http) {
        [http addPostValue:cardNo forKey:kFieldNameT0CardRequestCardId];
        [http addPostValue:cardHolderName forKey:kFieldNameT0CardRequestCardUserName];
        [http addPostValue:[PublicInformation returnBusiness] forKey:kFieldNameT0CardRequestMchtNo];
        [http setData:UIImageJPEGRepresentation(cardImage, 0.1f)
         withFileName:[cardNo stringByAppendingString:@".png"]
       andContentType:@"image/png"
               forKey:kFieldNameT0CardRequestCardPhoto];
    }];
}

- (void)terminateUpload {
    self.delegate = nil;
    [self.http terminateRequesting];
}

#pragma mask 2 HTTPInstanceDelegate
- (void)httpInstance:(HTTPInstance *)httpInstance didRequestingFinishedWithInfo:(NSDictionary *)info {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUploadedSuccess)]) {
        [self.delegate didUploadedSuccess];
    }
}
- (void)httpInstance:(HTTPInstance *)httpInstance didRequestingFailedWithError:(NSDictionary *)errorInfo {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didUploadedFail:)]) {
        [self.delegate didUploadedFail:errorInfo[kHTTPInstanceErrorMessage]];
    }
}

#pragma mask 9 getter
- (HTTPInstance *)http {
    if (_http == nil) {
        NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/jlagent/cardUpload",
                               [PublicInformation getServerDomain],
                               [PublicInformation getHTTPPort]];
        _http = [[HTTPInstance alloc] initWithURLString:urlString];
    }
    return _http;
}

@end

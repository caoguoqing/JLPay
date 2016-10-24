//
//  ModelAppInformation.m
//  JLPay
//
//  Created by jielian on 16/1/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "ModelAppInformation.h"
#import <AFNetworking.h>
#import "UIAlertController+JLShow.h"


#import "ASIFormDataRequest.h"


@interface ModelAppInformation()
<ASIHTTPRequestDelegate>
@property (nonatomic, retain) ASIFormDataRequest* httpRequest;
@property (nonatomic, strong) NSDictionary* appStoreInformation;
@property (nonatomic, assign) BOOL isRequested;
@end

@implementation ModelAppInformation
@synthesize httpRequest = _httpRequest;


// -- AppStore URL
+ (NSString*) URLStringInAppStore {
    return @"https://itunes.apple.com/cn/app/jie-lian-tong/id1019367170?mt=8";
}


+ (void)checkAppUpdated {
    AFHTTPSessionManager* httpManager = [AFHTTPSessionManager manager];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [httpManager POST:@"http://itunes.apple.com/cn/lookup?id=1019367170"
           parameters:nil
             progress:^(NSProgress * _Nonnull uploadProgress) { }
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  NSDictionary* responseInfo = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                  NSArray* results = [responseInfo objectForKey:@"results"];
                  NSDictionary* curAppInfo = [NSDictionary dictionaryWithDictionary:[results lastObject]];
                  
                  // 检查更新
                  NSString* appStoreVersion = [curAppInfo objectForKey:@"version"];
                  NSString* updatedInfo = [curAppInfo objectForKey:@"releaseNotes"];
                  NSString* curAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
                  
                  appStoreVersion = [appStoreVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
                  curAppVersion = [curAppVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
                  
                  if ([appStoreVersion integerValue] > [curAppVersion integerValue]) {
                      [UIAlertController showAlertWithTitle:@"版本更新提示" message:updatedInfo target:nil
                                              clickedHandle:^(UIAlertAction *action) {
                                                  if ([action.title isEqualToString:@"去下载"]) {
                                                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self URLStringInAppStore]]];
                                                  }
                                              } buttons:@{@(UIAlertActionStyleDefault):@"取消"},@{@(UIAlertActionStyleCancel):@"去下载"}, nil];
                  }
                  
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              }];
}

+ (void)getAPPInfoOnFinished:(void (^)(NSDictionary *))finishedBlock {
    
    // 初始化http
    AFHTTPSessionManager* httpManager = [AFHTTPSessionManager manager];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [httpManager POST:@"http://itunes.apple.com/cn/lookup?id=1019367170"
           parameters:nil
             progress:^(NSProgress * _Nonnull uploadProgress) { }
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  NSDictionary* responseInfo = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                  NSLog(@"获取到的原始app信息[%@]", responseInfo);
                  NSArray* results = [responseInfo objectForKey:@"results"];
                  NSDictionary* curAppInfo = [NSDictionary dictionaryWithDictionary:[results lastObject]];
                  if (curAppInfo && finishedBlock) {
                      finishedBlock(curAppInfo);
                  }
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              }];
    
}


# pragma mask ----------------------------useless



- (instancetype)init {
    self = [super init];
    if (self) {
        self.isRequested = NO;
    }
    return self;
}
- (void)dealloc {
    [self resetDataRequested];
    [self freeRequest];
}

+ (instancetype) sharedInstance {
    static ModelAppInformation* sharedHttp = nil;
    static dispatch_once_t onece_t;
    dispatch_once(&onece_t, ^{
        sharedHttp = [[ModelAppInformation alloc] init];
    });
    return sharedHttp;
}

// -- AppStore 版本号 (小数点格式)
- (NSString*) appStoreVersion {
    if (self.isRequested && self.appStoreInformation) {
        return [self.appStoreInformation objectForKey:@"version"];
    } else {
        return nil;
    }
}
// -- 更新信息
- (NSString*) appUpdatedDescription {
    if (self.isRequested && self.appStoreInformation) {
        return [self.appStoreInformation objectForKey:@"releaseNotes"];
    } else {
        return nil;
    }
}

// -- 是否查询到appstore信息
- (BOOL) appStoreInfoRequested {
    return self.isRequested;
}

// -- 开始查询appstore信息
- (void) requestAppStoreInfo {
    [self resetDataRequested];
    [self.httpRequest startAsynchronous];
}

#pragma mask 2 ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSData* data = [request responseData];
    if (data) {
        NSError* error;
        NSDictionary* responseDatas = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (!error && responseDatas) {
            NSArray* results = [responseDatas objectForKey:@"results"];
            if (results.count > 0) {
                self.appStoreInformation = [NSDictionary dictionaryWithDictionary:[results lastObject]];
                self.isRequested = YES;
            }
        }
    }
    [self freeRequest];
    
    if (self.isRequested) {
        [self postNotiOfAppStoreInfoRequested];
    }
}
- (void)requestFailed:(ASIHTTPRequest *)request {
    self.isRequested = NO;
    [self freeRequest];
}

#pragma mask 3 PRIVATE INTERFACE
// -- 释放http
- (void) freeRequest {
    [self.httpRequest clearDelegatesAndCancel];
    self.httpRequest = nil;
}
// -- reset data
- (void) resetDataRequested {
    self.appStoreInformation = nil;
    self.isRequested = NO;
}
// -- 发起通知:appstore信息已获取
- (void) postNotiOfAppStoreInfoRequested {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiKeyAppStoreInfoRequested object:nil];
}


#pragma mask 4 getter 
- (ASIFormDataRequest *)httpRequest {
    if (!_httpRequest) {
        NSString* urlString = @"http://itunes.apple.com/cn/lookup?id=1019367170"; // 1019367170(捷联通);
        _httpRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [_httpRequest setTimeOutSeconds:5];
        [_httpRequest setNumberOfTimesToRetryOnTimeout:3];
        [_httpRequest setDelegate:self];
    }
    return _httpRequest;
}

@end

//
//  HttpRequestT0CardList.h
//  JLPay
//
//  Created by jielian on 15/12/29.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HttpRequestT0CardList;

@protocol HttpRequestT0CardListDelegate <NSObject>

- (void) didRequestSuccess;
- (void) didRequestFail:(NSString*)failMessage;

@end



@interface HttpRequestT0CardList : NSObject

+ (instancetype) sharedInstance;

- (void) requestT_0CardListOnDelegate:(id<HttpRequestT0CardListDelegate>)delegate;
- (void) terminateRequesting;

- (NSInteger) countOfCardsRequested;
- (NSString*) cardRequestedAtIndex:(NSInteger)index;
- (NSString*) nameRequestedAtIndex:(NSInteger)index;
- (NSString*) stateRequestedAtIndex:(NSInteger)index;

@end

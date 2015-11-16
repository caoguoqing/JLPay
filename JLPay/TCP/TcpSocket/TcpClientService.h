//
//  TcpClientService.h
//  ALIVE
//
//  Created by gys on 14-6-14.
//  Copyright (c) 2014年 bookan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AsyncSocket.h"


@class TcpClientService;
@protocol wallDelegate <NSObject>

@required

-(void)receiveGetData:(NSString *)data method:(NSString *)str;

-(void)falseReceiveGetDataMethod:(NSString *)str;


@optional

@end


@interface TcpClientService : NSObject{
     AsyncSocket *asyncSocket;
}

@property (nonatomic, assign) id<wallDelegate> delegate;

@property(nonatomic,retain)NSString *orderInfoStr;

@property(nonatomic,retain)NSString *returnAllData;

@property(nonatomic,retain)NSString *tcpMethodStr;


+(TcpClientService *)getInstance;

-(void)sendOrderMethod:(NSString *)order IP:(NSString *)ip PORT:(UInt16)port Delegate:(id)selfdelegate method:(NSString *)methodStr;

-(void)sendWithoutWaitingOrderMethod:(NSString *)order IP:(NSString *)ip PORT:(UInt16)port Delegate:(id)selfdelegate method:(NSString *)methodStr;

// 释放socket
- (void) clearDelegateAndClose ;

// 连接状态
- (BOOL) isConnect;
@end

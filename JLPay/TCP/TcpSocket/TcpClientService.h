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

#pragma mask : add by fjl 20150731 #启动连接请求的回调:用来在外部开启超时功能
//- (void) didStartedWaitingForReadInTime:(int)otimeOut;

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
@end

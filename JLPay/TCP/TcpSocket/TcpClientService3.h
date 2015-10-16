//
//  TcpClientService.h
//  ALIVE
//
//  Created by gys on 14-6-14.
//  Copyright (c) 2014年 bookan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AsyncSocket.h"


@class TcpClientService3;
@protocol wall3Delegate <NSObject>

@required

-(void)receiveGetData:(NSString *)data method:(NSString *)methodName;

-(void)falseReceiveGetDataMethod:(NSString *)methodName;

-(void)falsedeviceNOtInLine:(NSString *)methodName;

@optional

-(void)receiveGetData:(NSString *)data method:(NSString *)methodName returnIp:(NSString *)ip;

@end


@interface TcpClientService3 : NSObject{
    //AsyncSocket *asyncSocket;
    
    BOOL connectOK;
}
@property (nonatomic, assign) id<wall3Delegate> delegate;

@property(nonatomic,retain)NSString *orderInfoStr;

@property(nonatomic,retain)NSString *returnAllData;
@property(nonatomic,retain)NSString *socketName;

@property(nonatomic,retain)NSString *udpIpStr;

@property(nonatomic,assign)UInt16 thePort;



+(TcpClientService3 *)getInstance;

-(void)sendOrderMethod:(NSString *)order IP:(NSString *)ip PORT:(UInt16)port method:(NSString *)methodStr Delegate:(id)selfdelegate;

-(void)sendOrderMethod:(NSString *)order IP:(NSString *)ip PORT:(UInt16)port method:(NSString *)methodStr Delegate:(id)selfdelegate receiveIp:(NSString *)receive;

@end

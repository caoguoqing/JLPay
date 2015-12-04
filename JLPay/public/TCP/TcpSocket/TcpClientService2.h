//
//  TcpClientService.h
//  ALIVE
//
//  Created by gys on 14-6-14.
//  Copyright (c) 2014年 bookan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AsyncSocket.h"


@class TcpClientService2;
@protocol wallDelegate2 <NSObject>

@required

-(void)receiveGetData2:(NSString *)data method:(NSString *)methodName;

-(void)falseReceiveGetDataMethod2:(NSString *)methodName;

@optional

@end


@interface TcpClientService2 : NSObject{
    AsyncSocket *asyncSocket;
    
    BOOL connectOK;
}
@property (nonatomic, assign) id<wallDelegate2> delegate;

@property(nonatomic,retain)NSString *orderInfoStr;

@property(nonatomic,retain)NSString *returnAllData;
@property(nonatomic,retain)NSString *socketName;


+(TcpClientService2 *)getInstance;

-(void)sendOrderMethod:(NSString *)order IP:(NSString *)ip PORT:(UInt16)port Delegate:(id)selfdelegate method:(NSString *)methodStr;



@end

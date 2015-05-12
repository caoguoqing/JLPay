//
//  TcpClientService.m
//  ALIVE
//
//  Created by gys on 14-6-14.
//  Copyright (c) 2014年 bookan. All rights reserved.
//

#import "TcpClientService2.h"


static TcpClientService2 *sharedObj = nil;

@implementation TcpClientService2

@synthesize orderInfoStr;
@synthesize returnAllData;
@synthesize delegate;
@synthesize socketName;



+(TcpClientService2 *)getInstance{
    @synchronized([TcpClientService2 class]){
        if(sharedObj ==nil){
            sharedObj = [[self alloc] init];
            
        }
    }
    return sharedObj;
}


//tcp
//建立连接
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    [self senMessage];
    [sock readDataWithTimeout:-1 tag:0];
}

//读取数据
-(void) onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    @try {
        NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.returnAllData=aStr;
        //NSLog(@"===%@",aStr);
        if ([delegate respondsToSelector:@selector(receiveGetData2: method:)]) {
//            [sock setDelegate:nil];
//            [sock disconnect];
//            asyncSocket=nil;
            [delegate receiveGetData2:aStr method:self.socketName];
        }
        
        NSData* aData= [aStr dataUsingEncoding: NSUTF8StringEncoding];
        [sock writeData:aData withTimeout:-1 tag:1];//99999999
        [sock readDataWithTimeout:-1 tag:0];
    }
    @catch (NSException *exception) {
        
        //asyncSocket=nil;
    }
    @finally {
        
    }
    
}

- (void)onSocket:(AsyncSocket *)sock didSecure:(BOOL)flag
{
    NSLog(@"onSocket:%p didSecure:YES", sock);
}
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, err);
    
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    @try {
        if ([delegate respondsToSelector:@selector(falseReceiveGetDataMethod:)]) {
//            [sock setDelegate:nil];
//            [sock disconnect];
//            asyncSocket=nil;
            NSLog(@"tcp连接失败======%@",self.socketName);
            [delegate falseReceiveGetDataMethod2:self.socketName];
        }
    }
    @catch (NSException *exception) {
//        [sock setDelegate:nil];
//        [sock disconnect];
//        asyncSocket=nil;
    }
    @finally {
        
    }
    //断开连接了
    NSLog(@"onSocketDidDisconnect:%p", sock);
}


-(void)senMessage{
    //设备匹配指令
    //NSString *msg = @"<XH:callin,018,43E>";
    NSData *data = [self.orderInfoStr dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:data withTimeout:-1 tag:1];
}

-(void)sendOrderMethod:(NSString *)order IP:(NSString *)ip PORT:(UInt16)port Delegate:(id)selfdelegate method:(NSString *)methodStr{
    //儿童锁关闭，才可以下发指令
        NSLog(@"ip====%@,设置端口port===%d",ip,port);
        self.delegate=selfdelegate;
        self.orderInfoStr=order;
        self.socketName=methodStr;
        
        //[SVProgressHUD dismiss];
        //[asyncSocket disconnect];    //断开tcp连接
        asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
    
        NSError *err = nil;
        [asyncSocket connectToHost:ip onPort:port error:&err];
        [asyncSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}


- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
    if (!asyncSocket) {
        asyncSocket=newSocket;
        NSLog(@"did accept new socket");
    }
}

- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket{
    NSLog(@"wants runloop for new socket.");
    return [NSRunLoop currentRunLoop];
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock{
    NSLog(@"will connect");
    return YES;
}


@end

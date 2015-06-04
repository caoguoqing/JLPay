//
//  TcpClientService.m
//  ALIVE
//
//  Created by gys on 14-6-14.
//  Copyright (c) 2014年 bookan. All rights reserved.
//

#import "TcpClientService3.h"
#import "PublicInformation.h"


@interface NSString (NSStringHexToBytes)
-(NSData*) hexToBytes ;

//- (NSString*) stringWithHexBytes1;
//- (NSString*)stringWithHexBytes2;
@end
@implementation NSString (NSStringHexToBytes)
-(NSData*) hexToBytes {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= self.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [self substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
@end;


static TcpClientService3 *sharedObj = nil;

@implementation TcpClientService3

@synthesize orderInfoStr;
@synthesize returnAllData;
@synthesize delegate;
@synthesize socketName;
@synthesize udpIpStr;
@synthesize thePort;


+(TcpClientService3 *)getInstance{
    @synchronized([TcpClientService3 class]){
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
    [sock canSafelySetDelegate];
    //设备匹配指令
    //NSData *data = [self.orderInfoStr dataUsingEncoding:NSUTF8StringEncoding];
    [sock writeData:[self.orderInfoStr hexToBytes] withTimeout:30 tag:1];
    [sock readDataWithTimeout:30 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag receiveIp:(NSString *)ip{
    NSLog(@"data==============%@,tag======%ld,ip======%@",data,tag,ip);
    NSString* aStr = [PublicInformation stringWithHexBytes2:data];
    NSData* aData= [aStr dataUsingEncoding: NSUTF8StringEncoding];
    [sock writeData:aData withTimeout:30 tag:1];//99999999
    [sock readDataWithTimeout:30 tag:0];
}

//读取数据
-(void) onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{

    NSLog(@"tag==========%ld",tag);
    @try {
        NSString* aStr = [PublicInformation stringWithHexBytes2:data];//[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"aStr======%@",aStr);
        self.returnAllData=aStr;
        if ([self.socketName isEqualToString:@"againCompare"]) {
            if ([delegate respondsToSelector:@selector(receiveGetData: method: returnIp:)]) {
                //NSLog(@"udp_ip========%@,aStr=========%@",self.udpIpStr,aStr);
                [sock setDelegate:nil];
                [sock disconnect];
                sock=nil;
                [delegate receiveGetData:aStr method:self.socketName returnIp:self.udpIpStr];
            }
        }else{
            if ([delegate respondsToSelector:@selector(receiveGetData: method:)]) {
                [sock setDelegate:nil];
                [sock disconnect];
                sock=nil;
                [delegate receiveGetData:aStr method:self.socketName];
            }
        }
        NSData* aData= [aStr dataUsingEncoding: NSUTF8StringEncoding];
        [sock writeData:aData withTimeout:30 tag:1];//99999999
        [sock readDataWithTimeout:30 tag:0];
    }
    @catch (NSException *exception) {
        
        sock=nil;
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
            [sock setDelegate:nil];
            [sock disconnect];
            sock=nil;
            NSLog(@"tcp连接失败======%@",self.socketName);
            [delegate falseReceiveGetDataMethod:self.socketName];
        }
    }
    @catch (NSException *exception) {
        [sock setDelegate:nil];
        [sock disconnect];
        sock=nil;
    }
    @finally {
        
    }
    //断开连接了
    NSLog(@"onSocketDidDisconnect:%p", sock);
}

-(void)sendOrderMethod:(NSString *)order IP:(NSString *)ip PORT:(UInt16)port method:(NSString *)methodStr Delegate:(id)selfdelegate{
    // [SVProgressHUD showWithStatus:@"数据加载中..."];
    @try {
        NSLog(@"ip====%@,设置端口port===%d====指令====%@",ip,port,order);
        self.delegate=selfdelegate;
        self.orderInfoStr=order;
        self.socketName=methodStr;
        
        AsyncSocket *asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
        //[asyncSocket disconnect];    //断开tcp连接
        NSError *err = nil;
        if (![asyncSocket connectToHost:ip onPort:port withTimeout:10 error:&err]) {

            [delegate falsedeviceNOtInLine:self.socketName];
        }else{
            
        }
        NSLog(@"err======%@",err);
        //[asyncSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    }
    @catch (NSException *exception) {
        NSLog(@"exception====%@",exception);
    }
    @finally {
        
    }
}

-(void)sendOrderMethod:(NSString *)order IP:(NSString *)ip PORT:(UInt16)port method:(NSString *)methodStr Delegate:(id)selfdelegate receiveIp:(NSString *)receive{
    @try {
            NSLog(@"ip====%@,设置端口port===%d====指令====%@",ip,port,order);
            self.delegate=selfdelegate;
            self.orderInfoStr=order;
            self.socketName=methodStr;
            self.udpIpStr=receive;
            self.thePort=port;
        
            AsyncSocket *asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
            //[asyncSocket moveToRunLoop:[NSRunLoop currentRunLoop]];
            //[asyncSocket disconnect];    //断开tcp连接
            NSError *err = nil;
            if (![asyncSocket connectToHost:ip onPort:port withTimeout:5 error:&err]) {

                [asyncSocket disconnect];
                [delegate falsedeviceNOtInLine:self.socketName];
            }else{
                
            }
        
            //[NSThread detachNewThreadSelector:@selector(_workerLoop:) toTarget:self withObject:asyncSocket];
            //[asyncSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
            //CFRunLoopRun();
    }
    @catch (NSException *exception) {
        NSLog(@"exception====%@",exception);
    }
    @finally {
        
    }
}

-(BOOL)canSafelySetDelegate {
    return YES;
}

-(void)_workerLoop:(AsyncSocket *) asyncSocket{
    [asyncSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}


- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket{
    /*
     if (!asyncSocket) {
     //asyncSocket=newSocket;
     NSLog(@"did accept new socket");
     }
     */
}

/*
- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket{
    NSLog(@"wants runloop for new socket.");
    return [NSRunLoop currentRunLoop];
}
*/

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock{
    NSLog(@"will connect");
    return YES;
}

@end

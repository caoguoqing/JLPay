//
//  TcpClientService.m
//  ALIVE
//
//  Created by gys on 14-6-14.
//  Copyright (c) 2014年 bookan. All rights reserved.
//

#import "TcpClientService.h"
#import "PublicInformation.h"


// --- 对类 NSString 进行扩展
@interface NSString (NSStringHexToBytes)
-(NSData*) hexToBytes ;

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

@end


static TcpClientService *sharedObj = nil;
static int readTimeOut = 60;    // 超时时间统一60s

@implementation TcpClientService

@synthesize orderInfoStr;
@synthesize returnAllData;
@synthesize delegate;
@synthesize tcpMethodStr;



+(TcpClientService *)getInstance{
    @synchronized([TcpClientService class]){
        if(sharedObj ==nil){
            sharedObj = [[self alloc] init];
            
        }
    }
    return sharedObj;
}


//tcp
//建立连接
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    [self senMessage];
    // 发送数据并等待返回:带参数超时
    [sock readDataWithTimeout:readTimeOut tag:0];
}

// 连接状态
- (BOOL) isConnect {
    return [asyncSocket isConnected];
}

//读取数据
-(void) onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString* aStr = [PublicInformation stringWithHexBytes2:data];
    self.returnAllData=aStr;
    [sock setDelegate:nil];
    [sock disconnect];
    sock=nil;
    if (delegate !=nil && [delegate respondsToSelector:@selector(receiveGetData: method:)]) {
        [delegate receiveGetData:aStr method:self.tcpMethodStr];
    }
}



- (void)onSocket:(AsyncSocket *)sock didSecure:(BOOL)flag
{
    NSLog(@"onSocket:%p didSecure:YES", sock);
}

/*
 * 错误处理的方法
 **/
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{    
    // 错误处理方法:
    [sock setDelegate:nil];
    [sock disconnect];
    sock=nil;
    NSString* errMessage = [err.userInfo valueForKey:NSLocalizedFailureReasonErrorKey];
    if (!errMessage) {
        errMessage = @"通讯超时!";
    }
    if (delegate && [delegate respondsToSelector:@selector(falseReceiveGetDataMethod:)]) {
        [delegate falseReceiveGetDataMethod:errMessage];
    }
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    //断开连接了
    NSLog(@"onSocketDidDisconnect:%p", sock);
    if (self.delegate && [self.delegate respondsToSelector:@selector(falseReceiveGetDataMethod:)]) {
        [self.delegate falseReceiveGetDataMethod:@"网络连接失败!"];
    }
}


-(void)senMessage{
    //设备匹配指令
    NSData *data = [self.orderInfoStr hexToBytes];
    [asyncSocket writeData:data withTimeout:readTimeOut tag:1];
}


-(void)sendOrderMethod:(NSString *)order IP:(NSString *)ip PORT:(UInt16)port Delegate:(id)selfdelegate method:(NSString *)methodStr{
    self.tcpMethodStr=methodStr;
    self.delegate=selfdelegate;
    self.orderInfoStr=order;
    if (asyncSocket != nil && [asyncSocket isConnected]) {
        [asyncSocket disconnect];
    }
    asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
    NSError *err = nil;
    
    if ([[ip componentsSeparatedByString:@","] count] > 0) {
        [asyncSocket connectToHost:ip onPort:port error:&err];
    }
}

// 发送方法2:不等待返回
-(void)sendWithoutWaitingOrderMethod:(NSString *)order IP:(NSString *)ip PORT:(UInt16)port Delegate:(id)selfdelegate method:(NSString *)methodStr{
    self.tcpMethodStr=methodStr;
    self.delegate=selfdelegate;
    self.orderInfoStr=order;
    if (asyncSocket != nil && [asyncSocket isConnected]) {
        [asyncSocket disconnect];
    }
    asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
    NSError *err = nil;
    
    if ([[ip componentsSeparatedByString:@","] count] > 0) {
        if ([asyncSocket connectToHost:ip onPort:port error:&err]) {
            // 发送成功后就关闭连接
            [asyncSocket setDelegate:nil];
            [asyncSocket disconnect];
            [asyncSocket release];
            asyncSocket = nil;
        }
    }
}

// 释放socket
- (void) clearDelegateAndClose {
    [self setDelegate:nil];
    [asyncSocket setDelegate:nil];
    [asyncSocket disconnect];
    [asyncSocket release];
    asyncSocket = nil;
}

@end

//
//  TcpClientService.m
//  ALIVE
//
//  Created by gys on 14-6-14.
//  Copyright (c) 2014年 bookan. All rights reserved.
//

#import "TcpClientService.h"
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

/*
- (NSString*) stringWithHexBytes1 {
    NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([self length] * 2)];
    const unsigned char *dataBuffer = [self bytes];
    int i;
    for (i = 0; i < [self length]; ++i) {
        [stringBuffer appendFormat:@"%02X", (unsigned long)dataBuffer[i]];
    }
    return [stringBuffer copy];
}
- (NSString*)stringWithHexBytes2 {
    static const char hexdigits[] = "0123456789ABCDEF";
    const size_t numBytes = [self length];
    const unsigned char* bytes = [self bytes];
    char *strbuf = (char *)malloc(numBytes * 2 + 1);
    char *hex = strbuf;
    NSString *hexBytes = nil;
    for (int i = 0; i<numBytes; ++i) {
        const unsigned char c = *bytes++;
        *hex++ = hexdigits[(c >> 4) & 0xF];
        *hex++ = hexdigits[(c ) & 0xF];
    }
    *hex = 0;
    hexBytes = [NSString stringWithUTF8String:strbuf];
    free(strbuf);
    return hexBytes;
}
*/


@end


static TcpClientService *sharedObj = nil;

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
    [sock readDataWithTimeout:60 tag:0];
}

//读取数据
-(void) onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString* aStr = [PublicInformation stringWithHexBytes2:data];
    self.returnAllData=aStr;
    if ([delegate respondsToSelector:@selector(receiveGetData: method:)]) {
        [sock disconnect];
        [sock setDelegate:nil];
        sock=nil;
        [delegate receiveGetData:aStr method:self.tcpMethodStr];
    }
    
    NSData* aData= [aStr dataUsingEncoding: NSUTF8StringEncoding];
    [sock writeData:aData withTimeout:60 tag:1];
    [sock readDataWithTimeout:60 tag:0];

//    NSLog(@"读取数据");
}

//

- (void)onSocket:(AsyncSocket *)sock didSecure:(BOOL)flag
{
    NSLog(@"onSocket:%p didSecure:YES", sock);
}
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    //NSLog(@"err=====%@",[err localizedDescription]);
    
    if ([delegate respondsToSelector:@selector(falseReceiveGetDataMethod:)]) {
        [sock disconnect];
        [sock setDelegate:nil];
        sock=nil;
        [delegate falseReceiveGetDataMethod:self.tcpMethodStr];
    }

    NSLog(@"onSocket:%p willDisconnectWithError:%@====tcp错误方法%@", sock, err,self.tcpMethodStr);
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    
    //断开连接了
    NSLog(@"onSocketDidDisconnect:%p", sock);
}


-(void)senMessage{
    //设备匹配指令
    NSData *data = [self.orderInfoStr hexToBytes];
    NSLog(@"发送data====%@",data);
    [asyncSocket writeData:data withTimeout:60 tag:1];
}


-(void)sendOrderMethod:(NSString *)order IP:(NSString *)ip PORT:(UInt16)port Delegate:(id)selfdelegate method:(NSString *)methodStr{
    //[SVProgressHUD showWithStatus:@"加载中..."];
    NSLog(@"ip=====%@,port========%d",ip,port);
    self.tcpMethodStr=methodStr;
    self.delegate=selfdelegate;
    self.orderInfoStr=order;
    [asyncSocket disconnect];
    asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
    NSError *err = nil;
    
    if ([[ip componentsSeparatedByString:@","] count] > 0) {
        [asyncSocket connectToHost:ip onPort:port error:&err];
        
    }
}



@end

//
//  ViewModelTCPEnquiry.m
//  JLPay
//
//  Created by jielian on 15/11/4.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ViewModelTCPEnquiry.h"
#import "ViewModelTCP.h"


@interface ViewModelTCPEnquiry()<ViewModelTCPDelegate>
{
    NSTimeInterval TCPCircleInterval;
    NSString* sTransType;
    NSString* sOrderCode;
    NSString* sMoney;
    NSInteger tagTCP;
}
@property (nonatomic, retain) NSTimer* timerTCPRequests;    // TCP轮询定时器
@property (nonatomic, strong) NSMutableArray* TCPNodes;     // TCP节点数组

@end


@implementation ViewModelTCPEnquiry

#pragma mask ---- 方法: 启动查询
- (void) TCPStartTransEnquiryWithTransType:(NSString*)transType andOrderCode:(NSString*)orderCode andMoney:(NSString*)money
{
    sTransType = transType;
    sOrderCode = orderCode;
    sMoney = money;
    // 启动TCP轮询定时器
    [self startTCPCircleTimer];
}


#pragma mask ---- ViewModelTCPDelegate
- (void)TCPResponse:(ViewModelTCP *)tcp withState:(BOOL)state andData:(NSDictionary *)responseData {
    if (state) {
        [self updatePayDoneResult:YES];
    } else {
        [self closeTCPNode:tcp];
        [self removeTCPNode:tcp];
    }
    // 失败就获取失败信息保存下来,回调时带出去 ..... need finish
}

#pragma mask ---- 查询成功后的清理工作及回调
- (void) cleanForEnquiryDone {
    if (self.payIsDone.boolValue) {
        [self terminateTCPEnquiry];
        // 成功回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(TCPEnquiryResult:withMessage:)]) {
            [self.delegate TCPEnquiryResult:YES withMessage:@"收款成功!"];
        }
    }
}

#pragma mask ---- 方法: 终止并清理定时器
- (void) terminateTCPEnquiry {
    // 关闭轮询计时器
    [self stopTCPCircleTimer];
    // 关闭所有TCP
    [self closeAllTCPNodes];
    // 清空所有TCP节点
    [self removeAllTCPNodes];
}


#pragma mask ---- 初始化
- (instancetype)init {
    self = [super init];
    if (self) {
        TCPCircleInterval = 3; // TCP轮询间隔
        tagTCP = 100;
    }
    return self;
}

#pragma mask ---- TCP轮询定时器
/* 创建并启动定时器 */
- (void) startTCPCircleTimer {
    self.timerTCPRequests = [NSTimer scheduledTimerWithTimeInterval:TCPCircleInterval target:self selector:@selector(oneceTCPEnquiry) userInfo:nil repeats:YES];
}
/* 停止定时器 */
- (void) stopTCPCircleTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.timerTCPRequests isValid]) {
            [self.timerTCPRequests invalidate];
            self.timerTCPRequests = nil;
        }
    });
}

#pragma mask ---- TCP节点数组
/* 追加TCP节点 */
- (void) appendTCPNode:(ViewModelTCP*)tcpHolder {
    NSLog(@"%@ <- %d",[self allTcpNodeTags], tcpHolder.tag);
    [self.TCPNodes addObject:tcpHolder];
}
/* 删除所有节点 */
- (void) removeAllTCPNodes {
    if (self.TCPNodes && self.TCPNodes.count > 0) {
        [self.TCPNodes removeAllObjects];
    }
}
/* 删除指定节点 */
- (void) removeTCPNode:(ViewModelTCP*)tcpHolder {
    ViewModelTCP* needDeleteTCP = nil;
    for (ViewModelTCP* tcp in self.TCPNodes) {
        if (tcp.tag == tcpHolder.tag) {
            needDeleteTCP = tcp;
        }
    }
    [self.TCPNodes removeObject:needDeleteTCP];
    NSLog(@"%@ -> %d",[self allTcpNodeTags], tcpHolder.tag);
}


/* 关闭指定的TCP节点 */
- (void) closeTCPNode:(ViewModelTCP*)tcpHolder {
    for (ViewModelTCP* tcp in self.TCPNodes) {
        if (tcp.tag == tcpHolder.tag) {
            if (tcpHolder && [tcpHolder isConnected]) {
                [tcpHolder TCPClear];
            }
        }
    }
}
/* 关闭所有节点TCP */
- (void) closeAllTCPNodes {
    for (ViewModelTCP* tcp in self.TCPNodes) {
        if ([tcp isConnected]) {
            [tcp TCPClear];
        }
    }
}

- (NSString*) allTcpNodeTags {
    NSMutableString* tags = [[NSMutableString alloc] init];
    [tags appendString:@"["];
    for (ViewModelTCP* tcp in self.TCPNodes) {
        [tags appendFormat:@"%d,",tcp.tag];
    }
    [tags appendString:@"]"];
    return tags;
}

#pragma mask ---- 查询结果标记
/* 更新标记 */
- (void) updatePayDoneResult:(BOOL)result {
    self.payIsDone = [NSNumber numberWithBool:result];
}


#pragma mask ---- PRIVATE INTERFACE
/* 超时失败停止 */
- (void) timeOutForTCPEnquiry {
    // 停止TCP轮询定时器
    [self stopTCPCircleTimer];
    // 清空TCP节点数组
    [self closeAllTCPNodes];
    [self removeAllTCPNodes];
    // 回调
    if (self.payIsDone.boolValue) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(TCPEnquiryResult:withMessage:)]) {
            [self.delegate TCPEnquiryResult:YES withMessage:@"收款成功!"];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(TCPEnquiryResult:withMessage:)]) {
            [self.delegate TCPEnquiryResult:NO withMessage:@"收款失败!"];
        }
    }
}
/* 发起一次交易结果查询 */
- (void) oneceTCPEnquiry {
    if (self.TCPNodes.count >= 5) { // TCP池中最多只能有5个
        return;
    }
    // 生成一个TCP
    ViewModelTCP* tcp = [[ViewModelTCP alloc] init];
    tcp.tag = tagTCP;
    tagTCP += 2;
    
    // TCP节点添加到TCP池
    [self appendTCPNode:tcp];
    
    // TCP请求
    [tcp TCPRequestWithTransType:sTransType andMoney:sMoney andOrderCode:sOrderCode andDelegate:self];
}

#pragma mask ---- getter
- (NSMutableArray *)TCPNodes {
    if (_TCPNodes == nil) {
        _TCPNodes = [[NSMutableArray alloc] init];
    }
    return _TCPNodes;
}
- (NSNumber *)payIsDone {
    if (_payIsDone == nil) {
        _payIsDone = [NSNumber numberWithBool:NO];
    }
    return _payIsDone;
}

@end

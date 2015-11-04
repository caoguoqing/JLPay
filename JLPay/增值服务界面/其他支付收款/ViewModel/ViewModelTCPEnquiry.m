//
//  ViewModelTCPEnquiry.m
//  JLPay
//
//  Created by jielian on 15/11/4.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import "ViewModelTCPEnquiry.h"
#import "ViewModelTCP.h"

// payIsDone 的观察者键
#define KEYPATH_PAYISDONE_CHANGED @"KEYPATH_PAYISDONE_CHANGED__"

@interface ViewModelTCPEnquiry()<ViewModelTCPDelegate>
{
    NSTimeInterval timeOutInterval;
    NSTimeInterval TCPCircleInterval;
    NSString* sTransType;
    NSString* sOrderCode;
    NSString* sMoney;
}
@property (nonatomic, retain) NSTimer* timerTimeOut;        // 超时定时器
@property (nonatomic, retain) NSTimer* timerTCPRequests;    // TCP轮询定时器
@property (nonatomic, strong) NSMutableArray* TCPNodes;     // TCP节点数组
@property (nonatomic, assign) NSNumber* payIsDone;          // 查询结果标记

@end


@implementation ViewModelTCPEnquiry

#pragma mask ---- 方法: 启动查询
- (void) TCPStartTransEnquiryWithTransType:(NSString*)transType andOrderCode:(NSString*)orderCode andMoney:(NSString*)money
{
    sTransType = transType;
    sOrderCode = orderCode;
    sMoney = money;
    // 启动超时定时器
    [self startTimeOutTimer];
    // 启动TCP轮询定时器
    [self startTCPCircleTimer];
}




#pragma mask ---- ViewModelTCPDelegate
//- (void)TCPResponseWithState:(BOOL)state andData:(NSDictionary *)responseData {
//    if (state) {
//        [self updatePayDoneResult:YES];
//    } else {
////        [tcp TCPClear];
////        [self removeTCPNode:tcp];
//    }
//    // 失败就获取失败信息保存下来,回调时带出去
//}
- (void)TCPResponse:(ViewModelTCP *)tcp withState:(BOOL)state andData:(NSDictionary *)responseData {
    if (state) {
        [self updatePayDoneResult:YES];
    } else {
//        [tcp TCPClear];
        [self removeTCPNode:tcp];
    }
    // 失败就获取失败信息保存下来,回调时带出去
}

#pragma mask ---- NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:KEYPATH_PAYISDONE_CHANGED] && object == self.payIsDone) {
        if (self.payIsDone.boolValue) {
            // 查询成功了,关闭超时计时器
            [self stopTimeOutTimer];
            // 关闭轮询计时器
            [self stopTCPCircleTimer];
            // 关闭所有TCP
            [self closeAllTCPNodes];
            // 清空所有TCP节点
            [self removeAllTCPNodes];
            // 回调
            NSLog(@"收款成功!");
            if (self.delegate && [self.delegate respondsToSelector:@selector(TCPEnquiryResult:withMessage:)]) {
                [self.delegate TCPEnquiryResult:YES withMessage:@"收款成功!"];
            }
        }
    }
}


#pragma mask ---- 初始化
- (instancetype)init {
    self = [super init];
    if (self) {
        timeOutInterval = 60; // 超时时间
        TCPCircleInterval = 5; // TCP轮询间隔
    }
    return self;
}



#pragma mask ---- 超时定时器
/* 创建并启动定时器 */
- (void) startTimeOutTimer {
    self.timerTimeOut = [NSTimer scheduledTimerWithTimeInterval:timeOutInterval target:self selector:@selector(timeOutForTCPEnquiry) userInfo:nil repeats:NO];
}
/* 停止定时器 */
- (void) stopTimeOutTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.timerTimeOut isValid]) {
            [self.timerTimeOut invalidate];
            self.timerTimeOut = nil;
        }
    });
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
    [self.TCPNodes addObject:tcpHolder];
    NSLog(@"TCP池中的节点数:[%lu]",self.TCPNodes.count);
}
/* 删除所有节点 */
- (void) removeAllTCPNodes {
    [self.TCPNodes removeAllObjects];
}
/* 删除指定节点 */
- (void) removeTCPNode:(ViewModelTCP*)tcpHolder {
    [self.TCPNodes removeObject:tcpHolder];
}
/* 关闭所有节点TCP */
- (void) closeAllTCPNodes {
    for (ViewModelTCP* tcp in self.TCPNodes) {
        if ([tcp isConnected]) {
            [tcp TCPClear];
        }
    }
}

#pragma mask ---- 查询结果标记
/* 更新标记 */
- (void) updatePayDoneResult:(BOOL)result {
    NSLog(@"查询结果更新:[%d]",result);
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
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    dispatch_async(dispatch_get_main_queue(), ^{
        // 生成一个TCP
        ViewModelTCP* tcp = [[ViewModelTCP alloc] init];
        // TCP请求
        NSLog(@"启动一次交易查询...");
        [tcp TCPRequestWithTransType:sTransType andMoney:sMoney andOrderCode:sOrderCode andDelegate:self];
        // TCP节点添加到TCP池
        [self appendTCPNode:tcp];
//    });
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
        [_payIsDone addObserver:self forKeyPath:KEYPATH_PAYISDONE_CHANGED options:NSKeyValueObservingOptionNew context:nil];
    }
    return _payIsDone;
}

@end

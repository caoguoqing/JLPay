//
//  BVC_vmTimer.m
//  JLPay
//
//  Created by jielian on 2016/11/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "BVC_vmTimer.h"
#import "Define_Header.h"


@interface BVC_vmTimer()

@property (nonatomic, strong) NSTimer* timerWaiting;
@property (nonatomic, strong) NSTimer* timerCircle;

@property (nonatomic, copy) void (^ timeOutBlock) (void);

@end

@implementation BVC_vmTimer

- (void)dealloc {
    [self stopCircleTimer];
    [self stopWaitingTimer];
}


- (void)timerWaitingForInterval:(NSInteger)interval handleWhenTimeOut:(void (^)(void))timeOutBlock
{
    self.timeOutBlock = timeOutBlock;
    [self stopWaitingTimer];
    
    self.timerWaiting = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(timeOutForWaiting:) userInfo:nil repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:self.timerWaiting forMode:NSRunLoopCommonModes];
    
}

- (void)stopWaitingTimer {
    if (self.timerWaiting && self.timerWaiting.isValid) {
        [self.timerWaiting invalidate];
        self.timerWaiting = nil;
    }
}


- (void)startCircleTimerWithTimecount:(NSInteger)interval {
    self.timeCount = interval;
    [self stopCircleTimer];
    
    self.timerCircle = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(circleCountingWithTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timerCircle forMode:NSRunLoopCommonModes];
}

- (void)stopCircleTimer {
    if (self.timerCircle && self.timerCircle.isValid) {
        [self.timerCircle invalidate];
        self.timerCircle = nil;
    }
}

# pragma mask 2 tools 

/* 等待超时的处理 */
- (void) timeOutForWaiting:(id) timer {
    if (self.timeOutBlock) {
        self.timeOutBlock();
    }
}

/* 计时器轮询定时器处理 */
- (void) circleCountingWithTimer:(id) timer {
    if (self.timeCount == 0) {
        [self stopCircleTimer];
        return ;
    }
    self.timeCount--;
}




@end

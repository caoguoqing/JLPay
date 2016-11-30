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
    NSLog(@"-------- BVC_vmTimer dealloc");
    [self stopCircleTimer];
    [self stopWaitingTimer];
}


- (void)timerWaitingForInterval:(NSInteger)interval handleWhenTimeOut:(void (^)(void))timeOutBlock
{
    self.timeOutBlock = timeOutBlock;
    [self stopWaitingTimer];
    
    NameWeakSelf(wself);
    self.timerWaiting = [NSTimer timerWithTimeInterval:interval repeats:NO block:^(NSTimer * _Nonnull timer) {
        if (wself.timeOutBlock) wself.timeOutBlock();
    }];
    
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
    
    NameWeakSelf(wself);
    self.timerCircle = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (wself.timeCount == 0) {
            [wself stopCircleTimer];
            return ;
        }
        wself.timeCount--;
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.timerCircle forMode:NSRunLoopCommonModes];
}

- (void)stopCircleTimer {
    if (self.timerCircle && self.timerCircle.isValid) {
        [self.timerCircle invalidate];
        self.timerCircle = nil;
    }
}

@end

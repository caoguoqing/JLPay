//
//  VMCheckNumTimer.m
//  JLPay
//
//  Created by jielian on 16/8/1.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMCheckNumTimer.h"

@implementation VMCheckNumTimer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timing = NO;
        self.timeCount = -1;
    }
    return self;
}

- (void)dealloc {
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)startTimer {
    [self stopTimer];
    
    self.timeCount = MAX_CheckNumTimeCount;
    self.timing = YES;
    [NSThread detachNewThreadSelector:@selector(addTimeToCurRunLoop) toTarget:self withObject:nil];
}

- (void)stopTimer {
    self.timeCount = -1;
    self.timing = NO;
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
}


# pragma mask 3 IBAction

- (void) timerRunning {
    if (self.timeCount >= 0) {
        self.timeCount --;
    } else {
        [self stopTimer];
    }
}

- (void) addTimeToCurRunLoop {
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [runLoop run];
}



# pragma mask 4 getter


- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerRunning) userInfo:nil repeats:YES];
    }
    return _timer;
}

@end

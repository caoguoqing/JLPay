//
//  BVC_vmTimer.h
//  JLPay
//
//  Created by jielian on 2016/11/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BVC_vmTimer : NSObject

/* 计时器 */
@property (nonatomic, assign) NSInteger timeCount;


/* 处理指定超时时间的事件
 *
 * @param interval:NSInteger                    超时时间
 * @param timeOutBlock:(void (^) (void))        超时后的处理
 */
- (void) timerWaitingForInterval:(NSInteger)interval
               handleWhenTimeOut:(void (^) (void))timeOutBlock;


- (void) stopWaitingTimer;


/* 启动超时计时器;计时时间到达会停止计时器
 *
 * @param interval:NSInteger                    计时时间
 */
- (void) startCircleTimerWithTimecount:(NSInteger)interval;

- (void) stopCircleTimer;

@end

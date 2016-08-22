//
//  VMCheckNumTimer.h
//  JLPay
//
//  Created by jielian on 16/8/1.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSInteger const MAX_CheckNumTimeCount = 60;

@interface VMCheckNumTimer : NSObject


- (void) startTimer;

- (void) stopTimer;




# pragma mask : private

@property (nonatomic, strong) NSTimer* timer;           /* 定时器 */

@property (nonatomic, assign) NSInteger timeCount;      /* 时间计时 */

@property (nonatomic, assign) BOOL timing;              /* 正在计时 */



@end

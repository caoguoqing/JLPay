//
//  Timer.h
//  smitsdk
//
//  Created by smit on 15/10/15.
//  Copyright (c) 2015年 smit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timer : NSObject
-(void)startCountdown:(double)seconds delay:(double)delay target:(id)target  selector:(SEL)didCountdownStop;
-(void)stopCountdown;
-(void)restartCountdown:(double)seconds delay:(double)delay target:(id)target  selector:(SEL)didCountdownStop;

- (void)startWithFireTime:(double)seconds interval:(NSTimeInterval)interval target:(id)target selector:(SEL)s repeats:(BOOL)rep;
-(void)stop;
-(void)restartWithFireTime:(double)seconds interval:(NSTimeInterval)interval target:(id)target selector:(SEL)s repeats:(BOOL)rep;
@end

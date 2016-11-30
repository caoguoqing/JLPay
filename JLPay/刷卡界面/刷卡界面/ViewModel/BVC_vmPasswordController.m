//
//  BVC_vmPasswordController.m
//  JLPay
//
//  Created by jielian on 2016/11/17.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "BVC_vmPasswordController.h"
#import "JLPasswordView.h"
#import <ReactiveCocoa.h>

@implementation BVC_vmPasswordController


- (RACCommand *)cmd_passwordInputting {
    if (!_cmd_passwordInputting) {
        @weakify(self);
        _cmd_passwordInputting = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [JLPasswordView showWithDoneClicked:^(NSString *password) {
                    @strongify(self);
                    self.passwordPin = password;
                    [subscriber sendCompleted];
                } orCancelClicked:^{
                    [subscriber sendError:nil];
                }];
                
                return nil;
            }] deliverOnMainThread] replayLast] materialize];
        }];
    }
    return _cmd_passwordInputting;
}

@end

//
//  MTransMoneyCache.m
//  JLPay
//
//  Created by jielian on 16/10/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "MTransMoneyCache.h"
#import <ReactiveCocoa.h>


@implementation MTransMoneyCache

+ (instancetype)sharedMoney {
    static MTransMoneyCache* transMoneyCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transMoneyCache = [[MTransMoneyCache alloc] init];
    });
    return transMoneyCache;
}

- (void)appendLastBitNumber:(NSInteger)bitNumber {
    if (bitNumber >= 10 || bitNumber < 0) {
        return;
    }
    NSInteger newMoneyUniteMinute = self.curMoneyUniteMinute * 10 + bitNumber;
    if ([self moneyUniteYuanFromUniteMinute:newMoneyUniteMinute] > self.maxMoneyLimit) {
        return;
    }
    self.curMoneyUniteMinute = newMoneyUniteMinute;
}

- (void)removeLastBitNumber {
    self.curMoneyUniteMinute = self.curMoneyUniteMinute / 10;
}

- (void)resetMoneyToZero {
    self.curMoneyUniteMinute = 0;
}



# pragma mask 3 private funcs

- (CGFloat) moneyUniteYuanFromUniteMinute:(NSInteger)uniteMinuteMoney {
    NSInteger integerPart = uniteMinuteMoney / 100;
    NSInteger floatPart = uniteMinuteMoney % 100;
    return (CGFloat)integerPart + (CGFloat)floatPart/100.f;
}

- (void) addKVOs {
    @weakify(self);
    RAC(self, curMoneyUniteYuan) = [RACObserve(self, curMoneyUniteMinute) map:^id(id value) {
        @strongify(self);
        return [NSNumber numberWithFloat:[self moneyUniteYuanFromUniteMinute:[value integerValue]]];
    }];
}



- (instancetype)init {
    self = [super init];
    if (self) {
        self.maxMoneyLimit = pow(10, 5);
        self.curMoneyUniteMinute = 0;
        [self addKVOs];
    }
    return self;
}




@end

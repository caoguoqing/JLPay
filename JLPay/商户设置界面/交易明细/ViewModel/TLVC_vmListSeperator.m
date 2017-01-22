//
//  TLVC_vmListSeperator.m
//  JLPay
//
//  Created by jielian on 2017/1/13.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "TLVC_vmListSeperator.h"
#import <ReactiveCocoa.h>



@implementation TLVC_mLSItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _datas = [NSMutableArray array];
        _spreaded = YES;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    TLVC_mLSItem* item = [TLVC_mLSItem allocWithZone:zone];
    item.title = self.title;
    item.datas = [self.datas mutableCopy];
    item.spreaded = self.spreaded;
    return item;
}

@end




@implementation TLVC_vmListSeperator


- (RACCommand *)cmd_seperating {
    if (!_cmd_seperating) {
        @weakify(self);
        _cmd_seperating = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                
                NSMutableArray* dates = [NSMutableArray array];
                TLVC_mLSItem* item = [TLVC_mLSItem new];
                item.title = @"some date other";
                // 将源数据按日期拆分到每个item的组里
                for (TLVC_mDetailMpos* node in self.originList) {
                    if (![node.instDate isEqualToString:item.title]) {
                        item = [TLVC_mLSItem new];
                        item.title = node.instDate;
                    }
                    [item.datas addObject:node];
                    if (![dates containsObject:item]) {
                        [dates addObject:item];
                    }
                }
                self.dataListPerSections = [dates copy];
                // 暂时不需要进行排序
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return _cmd_seperating;
}



@end

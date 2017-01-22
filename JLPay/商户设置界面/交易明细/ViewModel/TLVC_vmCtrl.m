//
//  TLVC_vmCtrl.m
//  JLPay
//
//  Created by jielian on 2017/1/13.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import "TLVC_vmCtrl.h"
#import "TLVC_mMonthsMaker.h"
#import <ReactiveCocoa.h>
#import "TLVC_vCell.h"
#import "TLVC_vHeadView.h"
#import "MLFilterView1Section.h"
#import "MLFilterView2Section.h"
#import "TLVC_vmListRequesterMpos.h"
#import "Define_Header.h"


@interface TLVC_vmCtrl()

/* 数据源: 月份组<YYYYMM> */
@property (nonatomic, strong) NSArray* monthList;
/* 序号: 选择的月份 */
@property (nonatomic, assign) NSInteger monthIndexSelected;

/* http访问器 */
@property (nonatomic, strong) TLVC_vmListRequesterMpos* mposRequester;


@end


@implementation TLVC_vmCtrl

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addKVO];
    }
    return self;
}

- (void) addKVO {
    @weakify(self);
    
# pragma mask ------ 绑定数据 -------
    /* 绑定月份选择 */
    RAC(self, month) = [RACObserve(self, monthIndexSelected) map:^id(id value) {
        @strongify(self);
        return [self.monthList objectAtIndex:[value integerValue]];
    }];
    
    /* 起始日期: 查询明细 */
    /* 终止日期: 查询明细 */
    [RACObserve(self, month) subscribeNext:^(NSString* month) {
        @strongify(self);
        NSString* yyyy = [month substringToIndex:4];
        NSString* mm = [month substringWithRange:NSMakeRange(4+1, 2)];
        self.mposRequester.queryBeginTime = [NSString stringWithFormat:@"%@%@01", yyyy,mm];
        self.mposRequester.queryEndTime = [[NSString stringWithFormat:@"%@%@", yyyy,mm] lastDayOfCurMonth];
    }];
    
    // 过滤器.源数据 <= http.查询数据
    RAC(self.filterCtrl, originList) = RACObserve(self.mposRequester, detailList);
    // 分组器.源数据 <= 过滤器.过滤数组
    RAC(self.seperatorCtrl, originList) = RACObserve(self.filterCtrl, filteredList);
    

    // 总金额
    RAC(self, totalMoney) = [RACObserve(self.seperatorCtrl, dataListPerSections) map:^id(NSArray* list) {
        NSInteger money = 0;
        for (TLVC_mLSItem* item in list) {
            for (TLVC_mDetailMpos* node in item.datas) {
                if ([node.txnNum isEqualToString:TLVC_TXNNUM_CONSUME] && node.cancelFlag == 0 && node.revsal_flag == 0) {
                    money += [node.amtTrans integerValue];
                }
            }
        }
        NSInteger yuanP = money / 100;
        NSInteger fenP = money % 100;
        return [NSString stringWithFormat:@"￥%ld.%02ld", yuanP, fenP];
    }];
    
    
# pragma mask ------ 流程监控 -------
    // 选完月份就刷新数据
    [RACObserve(self.mposRequester, queryEndTime) subscribeNext:^(id x) {
        @strongify(self);
        [self.cmd_dataRequesting execute:nil];
    }];
    
    // 选完选项就可以过滤
    [[RACObserve(self.filterCtrl, filteredIndexes) filter:^BOOL(NSArray* list) {
        return list && list.count > 0;
    }] subscribeNext:^(id x) {
        @strongify(self);
        [self.filterCtrl.cmd_filtering execute:nil];
    }];
    
    // 过滤完毕就可以开始拆分数据
    [RACObserve(self.filterCtrl, filteredList) subscribeNext:^(id x) {
        @strongify(self);
        [self.seperatorCtrl.cmd_seperating execute:nil];
    }];
    
    // 拆分好了数据就可以刷新了
    [RACObserve(self.seperatorCtrl, dataListPerSections) subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];

    // 重置了源数据就重置过滤组序号
    [RACObserve(self.mposRequester, detailList) subscribeNext:^(id x) {
        @strongify(self);
        [self.dataFilterView resetData];
    }];

}



# pragma mask 2 UITableViewDataSource

/* 分部数 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.seperatorCtrl.dataListPerSections.count;
}

/* 行数:每个分部 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TLVC_mLSItem* item = [self.seperatorCtrl.dataListPerSections objectAtIndex:section];
    if (item.spreaded) {
        return item.datas.count;
    } else {
        return 0;
    }
}

/* cell */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TLVC_vCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TLVC_vCell"];
    if (!cell) {
        cell = [[TLVC_vCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TLVC_vCell"];
    }
    TLVC_mDetailMpos* node = [[self.seperatorCtrl.dataListPerSections objectAtIndex:indexPath.section].datas objectAtIndex:indexPath.row];
    cell.titleLabel.text = node.txnNum;
    cell.subTitleLabel.text = [PublicInformation cuttingOffCardNo:node.pan];
    cell.contextLabel.text = [@"￥" stringByAppendingString:[PublicInformation dotMoneyFromNoDotMoney:node.amtTrans]];
    cell.subContextLabel.text = [self formatedTimeWithTime:node.instTime];
    if ([node.txnNum isEqualToString:TLVC_TXNNUM_CONSUME]) {
        cell.stateLabel.hidden = node.cancelFlag == 0 && node.revsal_flag == 0;
    } else {
        cell.stateLabel.hidden = YES;
    }
    cell.stateLabel.text = node.cancelFlag == 1 ? @"已撤销" : @"已冲正";
    return cell;
}


# pragma mask 2 UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TLVC_mDetailMpos* node = [[self.seperatorCtrl.dataListPerSections objectAtIndex:indexPath.section].datas objectAtIndex:indexPath.row];
    if (self.doDisplayDetailWithNode) {
        self.doDisplayDetailWithNode([node copy]);
    }
}

/* headerView */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TLVC_vHeadView* headView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TLVC_vHeadView"];
    if (!headView) {
        headView = [[TLVC_vHeadView alloc] initWithReuseIdentifier:@"TLVC_vHeadView"];
        headView.titleLabel.textColor = [UIColor colorWithHex:0x00a1dc alpha:1];
        [headView.spreadBtn setTitleColor:[UIColor colorWithHex:0x00a1dc alpha:1] forState:UIControlStateNormal];
    }
    TLVC_mLSItem* item = [self.seperatorCtrl.dataListPerSections objectAtIndex:section];
    headView.titleLabel.text = [self formatedMDayWithDate:item.title];
    headView.stateLabel.text = [NSString stringWithFormat:@"%ld笔", item.datas.count];
    headView.spreadBtn.transform = CGAffineTransformMakeRotation(item.spreaded ? 0 : - M_PI_2);
    
    @weakify(self);
    // 点击展开按钮: 执行展开动作
    [[[headView.spreadBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:headView.rac_prepareForReuseSignal] subscribeNext:^(UIButton* spreadBtn) {
        item.spreaded = !item.spreaded;
        [UIView animateWithDuration:0.2 animations:^{
            spreadBtn.transform = CGAffineTransformMakeRotation(item.spreaded ? 0 : - M_PI_2);
        } completion:^(BOOL finished) {
            @strongify(self);
            [self.tableView reloadData];
        }];
    }];
    return headView;
}



# pragma mask 3 tools 

- (NSString*) formatedTimeWithTime:(NSString*)time {
    return [NSString stringWithFormat:@"%@:%@:%@",
            [time substringWithRange:NSMakeRange(0, 2)],
            [time substringWithRange:NSMakeRange(2, 2)],
            [time substringWithRange:NSMakeRange(4, 2)]];
}

- (NSString*) formatedMDayWithDate:(NSString*)date {
    return [NSString stringWithFormat:@"%@月%@日",
            [date substringWithRange:NSMakeRange(4, 2)],
            [date substringWithRange:NSMakeRange(6, 2)]];
}




# pragma mask 4 getter

- (NSArray *)monthList {
    if (!_monthList) {
        _monthList = [TLVC_mMonthsMaker monthsAvilableList];
    }
    return _monthList;
}

- (RACCommand *)cmd_dataRequesting {
    return self.mposRequester.cmd_requesting;
}

- (RACCommand *)cmd_monthSelecting {
    if (!_cmd_monthSelecting) {
        @weakify(self);
        _cmd_monthSelecting = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                if (self.monthFilterView.isSpread) {
                    [self.monthFilterView hide];
                    [subscriber sendCompleted];
                } else {
                    [self.monthFilterView showWithItems:self.monthList onCompletion:^(NSInteger selectedIndex) {
                        @strongify(self);
                        self.monthIndexSelected = selectedIndex;
                        [subscriber sendCompleted];
                    } onCancel:^{
                        [subscriber sendCompleted];
                    }];
                }
                return nil;
            }] replayLast] materialize];
        }];
    }
    return _cmd_monthSelecting;
}

- (RACCommand *)cmd_dataFiltering {
    if (!_cmd_dataFiltering) {
        @weakify(self);
        _cmd_dataFiltering = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                if (self.dataFilterView.isSpread) {
                    [self.dataFilterView hideOnCompletion:nil];
                    [subscriber sendCompleted];
                } else {
                    [self.dataFilterView showOnCompletion:^(NSArray<NSArray<NSNumber *> *> *subSelectedArray) {
                                                  @strongify(self);
                                                  self.filterCtrl.filteredIndexes = subSelectedArray;
                                                  [subscriber sendCompleted];
                                              }
                                                  onCancel:^{
                                                      [subscriber sendCompleted];
                                                  }];
                }
                return nil;
            }] replayLast] materialize];
        }];
    }
    return _cmd_dataFiltering;
}

- (TLVC_vmListRequesterMpos *)mposRequester {
    if (!_mposRequester) {
        _mposRequester = [TLVC_vmListRequesterMpos new];
    }
    return _mposRequester;
}

- (TLVC_vmListFilter *)filterCtrl {
    if (!_filterCtrl) {
        _filterCtrl = [TLVC_vmListFilter new];
    }
    return _filterCtrl;
}


- (TLVC_vmListSeperator *)seperatorCtrl {
    if (!_seperatorCtrl) {
        _seperatorCtrl = [TLVC_vmListSeperator new];
    }
    return _seperatorCtrl;
}

@end

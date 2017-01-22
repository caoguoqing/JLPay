//
//  TLVC_vmCtrl.h
//  JLPay
//
//  Created by jielian on 2017/1/13.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TLVC_vmListSeperator.h"
#import "TLVC_vmListFilter.h"


@class MLFilterView1Section;
@class MLFilterView2Section;
@class RACCommand;
@class RACSignal;

@interface TLVC_vmCtrl : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView* tableView;

/* 月份: 显示(yyyy年mm月) */
@property (nonatomic, copy) NSString* month;
/* 命令: 选择月份 */
@property (nonatomic, strong) RACCommand* cmd_monthSelecting;
/* 筛选器: 月份(关联界面的筛选器) */
@property (nonatomic, weak) MLFilterView1Section* monthFilterView;


/* 数据源: 总金额 */
@property (nonatomic, copy) NSString* totalMoney;


/* 命令: 请求http数据 */
@property (nonatomic, weak) RACCommand* cmd_dataRequesting;


/* 命令: 过滤源数据 */
@property (nonatomic, strong) RACCommand* cmd_dataFiltering;
/* 筛选器: 数据(关联界面的筛选器) */
@property (nonatomic, weak) MLFilterView2Section* dataFilterView;


/* 过滤控制器 */
@property (nonatomic, strong) TLVC_vmListFilter* filterCtrl;

/* 数据分组器 */
@property (nonatomic, strong) TLVC_vmListSeperator* seperatorCtrl;

/* 点击cell显示详情的回调 */
@property (nonatomic, copy) void (^ doDisplayDetailWithNode) (TLVC_mDetailMpos* mposNode);

@end

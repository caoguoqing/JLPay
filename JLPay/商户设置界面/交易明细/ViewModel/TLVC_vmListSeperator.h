//
//  TLVC_vmListSeperator.h
//  JLPay
//
//  Created by jielian on 2017/1/13.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLVC_mDetailMpos.h"


@class RACCommand;


/* 分组节点 */
@interface TLVC_mLSItem : NSObject <NSCopying>

/* 标题: 日期 */
@property (nonatomic, copy) NSString* title;
/* 分组节点: TLVC_mDetailMpos */
@property (nonatomic, strong) NSMutableArray* datas;
/* 是否展开 */
@property (nonatomic, assign) BOOL spreaded;

@end



@interface TLVC_vmListSeperator : NSObject


/* 源数据: IN */
@property (nonatomic, weak) NSArray* originList;


/* 分部数据: 拆分后的: OUT */
@property (nonatomic, strong) NSArray<TLVC_mLSItem*>* dataListPerSections;


/* 命令: 执行拆分 */
@property (nonatomic, strong) RACCommand* cmd_seperating;

@end

//
//  TLVC_vmListFilter.h
//  JLPay
//
//  Created by jielian on 2017/1/13.
//  Copyright © 2017年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>


@class RACCommand;
@interface TLVC_vmListFilter : NSObject

/* 源数据: IN */
@property (nonatomic, weak) NSArray* originList;

/* 主选项数据: OUT */
@property (nonatomic, copy) NSArray* mainItems;

/* 副选项数据: OUT */
@property (nonatomic, copy) NSArray<NSArray*>* subItems;

/* 选中为YES,否则为NO,映射subItems的数组: IN */
@property (nonatomic, copy) NSArray<NSArray<NSNumber*>*>* filteredIndexes;

/* 过滤数据: OUT */
@property (nonatomic, copy) NSArray* filteredList;

/* 命令: 执行过滤 */
@property (nonatomic, strong) RACCommand* cmd_filtering;

@end

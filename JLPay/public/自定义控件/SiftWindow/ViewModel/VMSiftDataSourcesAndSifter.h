//
//  VMSiftDataSourcesAndSifter.h
//  JLPay
//
//  Created by jielian on 16/6/2.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef enum {
    TagOfSiftTBVMain,
    TagOfSiftTBVAssistant
}TagOfSiftTBV;


@interface VMSiftDataSourcesAndSifter : NSObject
<UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, copy) NSArray<NSString*> * mainDataSourcesList;                       // 主选项列表
@property (nonatomic, copy) NSArray<NSArray<NSString*>*> * assistantDataSourcesList;        // 副选项列表

@property (nonatomic, assign) NSInteger mainSelected;                                       // 点击序号-主
@property (nonatomic, assign) NSInteger assistantSelected;                                  // 点击序号-副

@property (nonatomic, strong) NSMutableArray<NSMutableArray<NSNumber*>*>* indexListSifted;  // 保存的已选择序号-二维

- (void) clearsSiftedIndexs;


@end

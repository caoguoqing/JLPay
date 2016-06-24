//
//  SiftViewController.h
//  JLPay
//
//  Created by jielian on 16/5/27.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMSiftDataSourcesAndSifter.h"




@interface SiftViewController : UIViewController

@property (nonatomic, copy) void (^ siftFinished) (NSArray<NSArray<NSNumber*>*> * indexListSifted);   // 选择完成的回调
@property (nonatomic, copy) void (^ siftCanceled) (void);


@property (nonatomic, strong) VMSiftDataSourcesAndSifter* siftDataSources;                      // 数据源和过滤器

@property (nonatomic, strong) UITableView* mainSectionTBV;                                      // 主选择器
@property (nonatomic, strong) UITableView* assistantSectionTBV;                                 // 副选择器

@property (nonatomic, strong) UIButton* sureButton;                                             // 确定
@property (nonatomic, strong) UIButton* resetButton;                                            // 重置


@end

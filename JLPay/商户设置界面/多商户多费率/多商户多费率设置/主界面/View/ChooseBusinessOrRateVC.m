//
//  ChooseBusinessOrRateVC.m
//  JLPay
//
//  Created by jielian on 16/8/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "ChooseBusinessOrRateVC.h"
#import "StepSegmentView.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"
#import <objc/runtime.h>
#import "MBProgressHUD+CustomSate.h"

#import "BR_chooseRateVC.h"
#import "BR_chooseBusinessVC.h"
#import "BR_chooseProvinceAndCityVC.h"




@interface ChooseBusinessOrRateVC()

@property (nonatomic, strong) StepSegmentView* stepSegView;

@property (nonatomic, strong) NSArray* selectedDisplayLabs;

@property (nonatomic, strong) UIBarButtonItem* doneSavingBtn;

@property (nonatomic, strong) UIButton* nextStepBtn;

@property (nonatomic, strong) UIButton* lastStepBtn;

@property (nonatomic, assign) NSInteger curShownVCIndex;


@end



@implementation ChooseBusinessOrRateVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHex:0xeeeeee alpha:1];
    [self loadSubviews];
    [self addKVOs];
}

- (void) loadSubviews {
    [self.navigationItem setRightBarButtonItem:self.doneSavingBtn];
    [self.view addSubview:self.stepSegView];
    [self.view addSubview:self.lastStepBtn];
    [self.view addSubview:self.nextStepBtn];
    
    for (UILabel* lab in self.selectedDisplayLabs) {
        [self.view addSubview:lab];
    }
    
    BR_chooseRateVC* chooseRateVC = [[BR_chooseRateVC alloc] init];
    chooseRateVC.dataSource.typeSelected = self.vmBRsaver.lastBusiOrRateInfo.typeSelected;
    chooseRateVC.dataSource.rateNameSelected = self.vmBRsaver.lastBusiOrRateInfo.rateNameSaved;
    [self addChildViewController:chooseRateVC];
    
    BR_chooseProvinceAndCityVC* chooseProvinceAndCityVC = [[BR_chooseProvinceAndCityVC alloc] init];
    chooseProvinceAndCityVC.dataSource.typeSelected = self.vmBRsaver.lastBusiOrRateInfo.typeSelected;
    chooseProvinceAndCityVC.dataSource.provinceNameSelected = self.vmBRsaver.lastBusiOrRateInfo.provinceNameSaved;
    chooseProvinceAndCityVC.dataSource.provinceCodeSelected = self.vmBRsaver.lastBusiOrRateInfo.provinceCodeSaved;
    chooseProvinceAndCityVC.dataSource.cityNameSelected = self.vmBRsaver.lastBusiOrRateInfo.cityNameSaved;
    chooseProvinceAndCityVC.dataSource.cityCodeSelected = self.vmBRsaver.lastBusiOrRateInfo.cityCodeSaved;
    [self addChildViewController:chooseProvinceAndCityVC];

    if ([self.vmBRsaver.lastBusiOrRateInfo.typeSelected isEqualToString:MB_R_Type_moreBusinesses]) {
        BR_chooseBusinessVC* chooseBusinessVC = [[BR_chooseBusinessVC alloc] init];
        chooseBusinessVC.dataSource.businessCode = self.vmBRsaver.lastBusiOrRateInfo.businessCodeSaved;
        chooseBusinessVC.dataSource.businessName = self.vmBRsaver.lastBusiOrRateInfo.businessNameSaved;
        chooseBusinessVC.dataSource.terminalCode = self.vmBRsaver.lastBusiOrRateInfo.terminalCodeSvaed;
        [self addChildViewController:chooseBusinessVC];
    }
}

- (void) addKVOs {
    @weakify(self);
    
    /* 切换了步骤: 同时切换子控制器界面 */
    [RACObserve(self.stepSegView, itemSelected) subscribeNext:^(NSNumber* itemSelected) {
        @strongify(self);
        
        /* 释放旧视图 */
        UIViewController* vc = [self.childViewControllers objectAtIndex:self.curShownVCIndex];
        if (vc) {
            [vc.view removeFromSuperview];
        }
        
        /* 添加新视图 */
        vc = [self.childViewControllers objectAtIndex:itemSelected.integerValue];
        [self.view addSubview:vc.view];
        
        /* 添加界面切换的动画效果 */
        CATransition* transAni = [CATransition animation];
        transAni.duration = 0.2;
        transAni.type = kCATransitionFade;
        [self.view.layer addAnimation:transAni forKey:nil];
        
        self.curShownVCIndex = itemSelected.integerValue;

        /* 重新布局 */
        [self.view updateConstraintsIfNeeded];
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    }];
    
    /* 绑定标题 */
    RAC(self, title) = RACObserve(self.vmBRsaver.lastBusiOrRateInfo, typeSelected);
    
    /* 绑定'下一步'按钮的标题 */
    [RACObserve(self.stepSegView, itemSelected) subscribeNext:^(NSNumber* itemSelected) {
        @strongify(self);
        if (itemSelected.integerValue == (self.stepSegView.titles.count - 1)) {
            [self.nextStepBtn setTitle:@"保存" forState:UIControlStateNormal];
        } else {
            [self.nextStepBtn setTitle:@"下一步" forState:UIControlStateNormal];
        }
    }];
    
    /* 绑定完成按钮的enable */
    RAC(self.doneSavingBtn, enabled) = RACObserve(self.vmBRsaver, saved);
    
    
    /* 绑定子控制器的选择的数据到主数据源 */
    BR_chooseRateVC* chooseRateVC = (BR_chooseRateVC*)[self.childViewControllers objectAtIndex:0];
    BR_chooseProvinceAndCityVC* chooseProvinceAndCityVC = (BR_chooseProvinceAndCityVC*)[self.childViewControllers objectAtIndex:1];
    BR_chooseBusinessVC* chooseBusinessVC = ([self.vmBRsaver.lastBusiOrRateInfo.typeSelected isEqualToString:MB_R_Type_moreBusinesses]) ? ((BR_chooseBusinessVC*)[self.childViewControllers objectAtIndex:2]) : (nil);

    
    /* ------------------ VV 值得绑定和更新 ------------------ */
    
    /* 绑定选择的费率类型; 监控值变更后的历史值清除 */
    RAC(self.vmBRsaver.lastBusiOrRateInfo, rateNameSaved) = [RACObserve(chooseRateVC.dataSource, rateNameSelected) filter:^BOOL(NSString* rateName) {
        /* 过滤功能用来监控费率的改变: 重置历史的商户or地区 */
        @strongify(self);
        if (![rateName isEqualToString:self.vmBRsaver.lastBusiOrRateInfo.rateNameSaved]) {
            if ([self.vmBRsaver.lastBusiOrRateInfo.typeSelected isEqualToString:MB_R_Type_moreBusinesses]) {
                chooseBusinessVC.dataSource.businessCode = nil;
                chooseBusinessVC.dataSource.businessName = nil;
                chooseBusinessVC.dataSource.terminalCode = nil;
            }
            else if ([self.vmBRsaver.lastBusiOrRateInfo.typeSelected isEqualToString:MB_R_Type_moreRates]) {
                chooseProvinceAndCityVC.dataSource.provinceCodeSelected = nil;
                chooseProvinceAndCityVC.dataSource.provinceNameSelected = nil;
                chooseProvinceAndCityVC.dataSource.cityCodeSelected = nil;
                chooseProvinceAndCityVC.dataSource.cityNameSelected = nil;
            }
        }
        return YES;
    }];
    
    RAC(self.vmBRsaver.lastBusiOrRateInfo, rateCodeSaved) = RACObserve(chooseRateVC.dataSource, rateCodeSelected);
    RAC(self.vmBRsaver.lastBusiOrRateInfo, provinceNameSaved) = RACObserve(chooseProvinceAndCityVC.dataSource, provinceNameSelected);
    RAC(self.vmBRsaver.lastBusiOrRateInfo, provinceCodeSaved) = RACObserve(chooseProvinceAndCityVC.dataSource, provinceCodeSelected);
    RAC(self.vmBRsaver.lastBusiOrRateInfo, cityCodeSaved) = RACObserve(chooseProvinceAndCityVC.dataSource, cityCodeSelected);
    
    RAC(self.vmBRsaver.lastBusiOrRateInfo, cityNameSaved) = [RACObserve(chooseProvinceAndCityVC.dataSource, cityNameSelected) filter:^BOOL(NSString* cityName) {
        /* 过滤功能用来监控费率的改变: 重置历史的商户 */
        @strongify(self);
        if (![cityName isEqualToString:self.vmBRsaver.lastBusiOrRateInfo.cityNameSaved]) {
            if ([self.vmBRsaver.lastBusiOrRateInfo.typeSelected isEqualToString:MB_R_Type_moreBusinesses]) {
                chooseBusinessVC.dataSource.businessCode = nil;
                chooseBusinessVC.dataSource.businessName = nil;
                chooseBusinessVC.dataSource.terminalCode = nil;
            }
        }
        return YES;
    }];
    
    
    if (chooseBusinessVC != nil) {
        RAC(self.vmBRsaver.lastBusiOrRateInfo, businessNameSaved) = RACObserve(chooseBusinessVC.dataSource, businessName);
        RAC(self.vmBRsaver.lastBusiOrRateInfo, businessCodeSaved) = RACObserve(chooseBusinessVC.dataSource, businessCode);
        RAC(self.vmBRsaver.lastBusiOrRateInfo, terminalCodeSvaed) = RACObserve(chooseBusinessVC.dataSource, terminalCode);
    }
    
    /* 绑定'下一步'按钮的enable属性 */
    RAC(self.nextStepBtn, enabled) = [[RACSignal merge:@[RACObserve(self.vmBRsaver.lastBusiOrRateInfo, rateNameSaved),
                                                         RACObserve(self.vmBRsaver.lastBusiOrRateInfo, cityCodeSaved),
                                                         RACObserve(self.vmBRsaver.lastBusiOrRateInfo, businessNameSaved),
                                                         RACObserve(self.stepSegView, itemSelected)]]
                                      map:^id(id value) {
                                          @strongify(self);
                                          const char* className = class_getName([value class]);
                                          if (strcmp(className, "__NSCFNumber") == 0) {
                                              if ([value integerValue] == 0) {
                                                  return @(self.vmBRsaver.lastBusiOrRateInfo.rateNameSaved && self.vmBRsaver.lastBusiOrRateInfo.rateNameSaved.length > 0);
                                              }
                                              else if ([value integerValue] == 1) {
                                                  return @(self.vmBRsaver.lastBusiOrRateInfo.cityCodeSaved && self.vmBRsaver.lastBusiOrRateInfo.cityCodeSaved.length > 0);
                                              }
                                              else if ([value integerValue] == 2) {
                                                  return @(self.vmBRsaver.lastBusiOrRateInfo.businessNameSaved && self.vmBRsaver.lastBusiOrRateInfo.businessNameSaved.length > 0);
                                              }
                                              else {
                                                  return @(NO);
                                              }
                                          } else {
                                              NSString* string = (NSString*)value;
                                              if (self.stepSegView.itemSelected == 0) {
                                                  return @(string && string.length > 0);
                                              }
                                              else if (self.stepSegView.itemSelected == 1) {
                                                  return @(string && string.length > 0);
                                              }
                                              else if (self.stepSegView.itemSelected == 2) {
                                                  return @(string && string.length > 0);
                                              }
                                              else {
                                                  return @(NO);
                                              }
                                          }
    }];
    
    RAC(self.lastStepBtn, enabled) = [RACObserve(self.stepSegView, itemSelected) map:^id(NSNumber* index) {
        return @(index.integerValue > 0);
    }];
    
    
    if (chooseBusinessVC) {
        RAC(chooseBusinessVC.dataSource, cityCode) = RACObserve(self.vmBRsaver.lastBusiOrRateInfo, cityCodeSaved);
        RAC(chooseBusinessVC.dataSource, rateType) = RACObserve(self.vmBRsaver.lastBusiOrRateInfo, rateCodeSaved);
    }
    
    
    
    /* 绑定选择的各子项的值到显示label */
    for (int i = 0; i < self.selectedDisplayLabs.count; i++) {
        UILabel* label = [self.selectedDisplayLabs objectAtIndex:i];
        
        /* 颜色透明度 */
        RAC(label, alpha) = [RACObserve(self.stepSegView, itemSelected) map:^id(NSNumber* index) {
            if (i <= index.intValue) {
                return @(1.f);
            } else {
                return @(0.5f);
            }
        }];
        
        if (i == 0) { /* 费率 */
            RAC(label, text) = [RACObserve(chooseRateVC.dataSource, rateNameSelected) map:^id(NSString* rateType) {
                if (rateType && rateType.length > 0) {
                    return rateType;
                } else {
                    return @"(无)";
                }
            }];
        }
        else if (i == 1) { /* 省市 */
            RAC(label, text) = [[RACSignal merge:@[RACObserve(chooseProvinceAndCityVC.dataSource, provinceNameSelected),
                                                  RACObserve(chooseProvinceAndCityVC.dataSource, cityNameSelected)]] map:^id(id value) {
                if (chooseProvinceAndCityVC.dataSource.provinceNameSelected) {
                    NSString* province = chooseProvinceAndCityVC.dataSource.provinceNameSelected;
                    NSString* city = (chooseProvinceAndCityVC.dataSource.cityNameSelected) ? (chooseProvinceAndCityVC.dataSource.cityNameSelected) : (@"");
                    return [NSString stringWithFormat:@"%@/%@", province, city];
                }
                else {
                    return @"(无)";
                }
            }];
            
        }
        else if (i == 2) { /* 商户 */
            RAC(label, text) = [RACObserve(chooseBusinessVC.dataSource, businessName) map:^id(NSString* businessName) {
                if (businessName && businessName.length > 0) {
                    return businessName;
                } else {
                    return @"(无)";
                }
            }];
        }
    }
    
    
}


- (void)updateViewConstraints {
    
    NameWeakSelf(wself);
    
    CGFloat heightBtn = [UIScreen mainScreen].bounds.size.height * 1/12.5;
    [self.lastStepBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(wself.view.mas_bottom).offset(0);
        make.left.mas_equalTo(wself.view.mas_left).offset(0);
        make.right.mas_equalTo(wself.view.mas_centerX).offset(0);
        make.height.mas_equalTo(heightBtn);
    }];
    

    
    [self.nextStepBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(wself.view.mas_bottom).offset(0);
        make.left.mas_equalTo(wself.lastStepBtn.mas_right).offset(0);
        make.right.mas_equalTo(wself.view.mas_right).offset(0);
        make.height.mas_equalTo(heightBtn);
    }];
    
    CGFloat heightDispLab = 14;
    CGFloat widthDispLab = [UIScreen mainScreen].bounds.size.width * (1.f/(CGFloat)self.selectedDisplayLabs.count);
    for (int i = 0; i < self.selectedDisplayLabs.count; i++) {
        UILabel* label = [self.selectedDisplayLabs objectAtIndex:i];
        [label mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(wself.view.mas_left).offset(i * widthDispLab);
            make.width.mas_equalTo(widthDispLab);
            make.top.mas_equalTo(wself.stepSegView.mas_bottom).offset(5);
            make.height.mas_equalTo(heightDispLab);
        }];
    }
    
    if (self.curShownVCIndex >= 0) {
        UIViewController* curChildVC = [self.childViewControllers objectAtIndex:self.curShownVCIndex];
        [curChildVC.view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(wself.stepSegView.mas_bottom).offset(heightDispLab + 10);
            make.bottom.mas_equalTo(wself.nextStepBtn.mas_top).offset(0);
            make.left.right.mas_equalTo(wself.view);
        }];
    }

    
    [super updateViewConstraints];
}


# pragma mask 2 IBAction

- (IBAction) doneWithSaving:(id)sender {
    if (self.doneWithSaved) {
        self.doneWithSaved();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) clickedNextBtn:(UIButton*)sender {
    /* 下一步 */
    if (self.stepSegView.itemSelected < self.stepSegView.titles.count - 1) {
        self.stepSegView.itemSelected ++;
    }
    /* 保存 */
    else if (self.stepSegView.itemSelected == self.stepSegView.titles.count - 1) {
        [self.vmBRsaver saving];
        NSString* title = [NSString stringWithFormat:@"已保存选择的%@!", self.vmBRsaver.lastBusiOrRateInfo.typeSelected];
        [MBProgressHUD showSuccessWithText:title andDetailText:nil onCompletion:^{
            
        }];
    }
}

- (IBAction) clickedLastBtn:(UIButton*)sender {
    if (self.stepSegView.itemSelected > 0) {
        self.stepSegView.itemSelected --;
    }
}


# pragma mask 4 getter


- (StepSegmentView *)stepSegView {
    if (!_stepSegView) {
        if ([self.vmBRsaver.lastBusiOrRateInfo.typeSelected isEqualToString:MB_R_Type_moreBusinesses]) {
            _stepSegView = [[StepSegmentView alloc] initWithTitles:@[@"费率", @"省/市", @"商户"]];
        } else {
            _stepSegView = [[StepSegmentView alloc] initWithTitles:@[@"费率", @"省/市"]];
        }
        _stepSegView.tintColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        _stepSegView.normalColor = [UIColor whiteColor];
        _stepSegView.itemSelected = 0;
        _stepSegView.frame = CGRectMake(0, 64 + 10, self.view.frame.size.width, 54);
    }
    return _stepSegView;
}

- (NSArray *)selectedDisplayLabs {
    if (!_selectedDisplayLabs) {
        NSMutableArray* labs = [NSMutableArray array];
        if ([self.vmBRsaver.lastBusiOrRateInfo.typeSelected isEqualToString:MB_R_Type_moreBusinesses]) {
            for (int i = 0; i < 3; i++) {
                UILabel* lab = [UILabel new];
                lab.font = [UIFont systemFontOfSize:10];
                lab.numberOfLines = 0;
                lab.minimumScaleFactor = 0.4;
                lab.adjustsFontSizeToFitWidth = YES;
                lab.textAlignment = NSTextAlignmentCenter;
                lab.textColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
                [labs addObject:lab];
            }
        } else {
            for (int i = 0; i < 2; i++) {
                UILabel* lab = [UILabel new];
                lab.font = [UIFont systemFontOfSize:10];
                lab.numberOfLines = 0;
                lab.minimumScaleFactor = 0.4;
                lab.adjustsFontSizeToFitWidth = YES;
                lab.textAlignment = NSTextAlignmentCenter;
                lab.textColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
                [labs addObject:lab];
            }
        }
        _selectedDisplayLabs = [NSArray arrayWithArray:labs];
    }
    return _selectedDisplayLabs;
}

- (UIBarButtonItem *)doneSavingBtn {
    if (!_doneSavingBtn) {
        _doneSavingBtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneWithSaving:)];
    }
    return _doneSavingBtn;
}

- (UIButton *)nextStepBtn {
    if (!_nextStepBtn) {
        _nextStepBtn = [UIButton new];
        _nextStepBtn.backgroundColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        _nextStepBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_nextStepBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextStepBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextStepBtn setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.6] forState:UIControlStateHighlighted];
        [_nextStepBtn setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.6] forState:UIControlStateDisabled];
        [_nextStepBtn addTarget:self action:@selector(clickedNextBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextStepBtn;
}

- (UIButton *)lastStepBtn {
    if (!_lastStepBtn) {
        _lastStepBtn = [UIButton new];
        _lastStepBtn.backgroundColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        _lastStepBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_lastStepBtn setTitle:@"上一步" forState:UIControlStateNormal];
        [_lastStepBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_lastStepBtn setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.6] forState:UIControlStateHighlighted];
        [_lastStepBtn setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.6] forState:UIControlStateDisabled];
        [_lastStepBtn addTarget:self action:@selector(clickedLastBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lastStepBtn;
}

- (VMMoreBusinessOrRateSaving *)vmBRsaver {
    if (!_vmBRsaver) {
        _vmBRsaver = [[VMMoreBusinessOrRateSaving alloc] init];
    }
    return _vmBRsaver;
}

@end

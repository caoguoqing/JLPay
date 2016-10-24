//
//  SU_ChooseProvinceAndCityVC.m
//  JLPay
//
//  Created by jielian on 16/7/7.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "SU_ChooseProvinceAndCityVC.h"
#import "Define_Header.h"
#import "Masonry.h"
#import <ReactiveCocoa.h>


@implementation SU_ChooseProvinceAndCityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择省市";
    [self loadSubviews];
    [self layoutSubviews];
    [self addKVOs];
}

- (void) loadSubviews {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableViewMain];
    [self.view addSubview:self.tableViewAssistant];
    [self.navigationItem setRightBarButtonItem:self.doneBarBtnItem];
    [self.navigationItem setLeftBarButtonItem:self.cancleBarBtnItem];
}

- (void) layoutSubviews {
    NameWeakSelf(wself);
    
    [self.tableViewMain mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.view.mas_left);
        make.right.equalTo(wself.view.mas_right).multipliedBy(0.35);
        make.top.equalTo(wself.view.mas_top).offset(64);
        make.bottom.equalTo(wself.view.mas_bottom);
    }];
    [self.tableViewAssistant mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.tableViewMain.mas_right);
        make.right.equalTo(wself.view.mas_right);
        make.top.equalTo(wself.tableViewMain.mas_top);
        make.bottom.equalTo(wself.tableViewMain.mas_bottom);
    }];
}

- (void) addKVOs {
    @weakify(self);
    RACSignal* sigProvinceSelected = RACObserve(self.vmProAndCityDataSource, provinceIndexPicked);
    RACSignal* sigCitySelected = RACObserve(self.vmProAndCityDataSource, cityIndexPicked);
    
    [[sigProvinceSelected deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableViewMain reloadData];
        [self.vmProAndCityDataSource resetCityDatasOnFinished:^{
            @strongify(self);
            [self.tableViewAssistant reloadData];
        }];
    }];
    
    [[sigCitySelected deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableViewAssistant reloadData];
    }];
    
    RAC(self.doneBarBtnItem, enabled) = [RACSignal combineLatest:@[sigProvinceSelected, sigCitySelected]
                                                          reduce:^id(NSNumber* provinceSelected, NSNumber* citySelected){
                                                              return @(provinceSelected.integerValue >= 0 && citySelected.integerValue >= 0);
    }];
    
}


# pragma mask 2 IBAction

- (IBAction) clickedDoneBtn:(UIBarButtonItem*)sender {
    if (self.doneSelected) {
        self.doneSelected(self.vmProAndCityDataSource.provinceNamePicked, self.vmProAndCityDataSource.provinceCodePicked,
                          self.vmProAndCityDataSource.cityNamePicked, self.vmProAndCityDataSource.cityCodePicked);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction) clickedCancelBtn:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

# pragma mask 4 getter

- (UITableView *)tableViewMain {
    if (!_tableViewMain) {
        _tableViewMain = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableViewMain.tag = VMSU_areaTypeProvince;
        _tableViewMain.delegate = self.vmProAndCityDataSource;
        _tableViewMain.dataSource = self.vmProAndCityDataSource;
        _tableViewMain.backgroundColor = [UIColor clearColor];
        _tableViewMain.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableViewMain;
}
- (UITableView *)tableViewAssistant {
    if (!_tableViewAssistant) {
        _tableViewAssistant = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableViewAssistant.tag = VMSU_areaTypeCity;
        _tableViewAssistant.delegate = self.vmProAndCityDataSource;
        _tableViewAssistant.dataSource = self.vmProAndCityDataSource;
        _tableViewAssistant.backgroundColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:0.4];
        _tableViewAssistant.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableViewAssistant;
}

- (VMProvinceAndCityChoose *)vmProAndCityDataSource {
    if (!_vmProAndCityDataSource) {
        _vmProAndCityDataSource = [[VMProvinceAndCityChoose alloc] init];
    }
    return _vmProAndCityDataSource;
}

- (UIBarButtonItem *)doneBarBtnItem {
    if (!_doneBarBtnItem) {
        _doneBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(clickedDoneBtn:)];
    }
    return _doneBarBtnItem;
}

- (UIBarButtonItem *)cancleBarBtnItem {
    if (!_cancleBarBtnItem) {
        _cancleBarBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(clickedCancelBtn:)];
    }
    return _cancleBarBtnItem;
}

@end

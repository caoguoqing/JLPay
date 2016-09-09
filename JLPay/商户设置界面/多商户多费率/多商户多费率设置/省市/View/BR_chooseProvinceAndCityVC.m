//
//  BR_chooseProvinceAndCityVC.m
//  JLPay
//
//  Created by jielian on 16/8/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "BR_chooseProvinceAndCityVC.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>
#import "Masonry.h"


@interface BR_chooseProvinceAndCityVC()

@property (nonatomic, strong) UITableView* tbvProvince;

@property (nonatomic, strong) UITableView* tbvCity;

@end

@implementation BR_chooseProvinceAndCityVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tbvProvince];
    [self.view addSubview:self.tbvCity];
    
    [self addKVOs];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    NameWeakSelf(wself);
    
    [self.dataSource updateProvincesOnFinished:^{
        [wself.tbvProvince reloadData];
        NSInteger provinceIndex = [wself.dataSource rowIndexOfProvinceSelected];
        if (provinceIndex >= 0) {
            [wself.tbvProvince scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:provinceIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }];
    
    if (self.dataSource.provinceCodeSelected && self.dataSource.provinceCodeSelected.length > 0) {
        [self.dataSource updateCitiesWithProvinceCode:self.dataSource.provinceCodeSelected onFinished:^{
            [wself.tbvCity reloadData];
            NSInteger cityIndex = [self.dataSource rowIndexOfCitySelected];
            if (cityIndex >= 0) {
                [wself.tbvCity scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:cityIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }];
    }
}


- (void) addKVOs {
    @weakify(self);
    [[RACObserve(self.dataSource, provinceCodeSelected) skip:1] subscribeNext:^(NSString* provinceCode) {
        @strongify(self);
        [self.dataSource updateCitiesWithProvinceCode:provinceCode onFinished:^{
            @strongify(self);
            [self.tbvCity reloadData];
        }];
    }];
}

- (void)updateViewConstraints {
    CGFloat widthProvince = self.view.frame.size.width * 0.4;
    NameWeakSelf(wself);
    [self.tbvProvince mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(wself.view);
        make.width.mas_equalTo(widthProvince);
    }];
    [self.tbvCity mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wself.tbvProvince.mas_right);
        make.top.bottom.right.mas_equalTo(wself.view);
    }];
    
    [super updateViewConstraints];
}

# pragma mask 4 getter

- (UITableView *)tbvProvince {
    if (!_tbvProvince) {
        _tbvProvince = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tbvProvince.backgroundColor = [UIColor colorWithHex:0xe5e5e5 alpha:1];
        _tbvProvince.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tbvProvince.tag = VMBR_ENUM_Province;
        _tbvProvince.dataSource = self.dataSource;
        _tbvProvince.delegate = self.dataSource;
    }
    return _tbvProvince;
}

- (UITableView *)tbvCity {
    if (!_tbvCity) {
        _tbvCity = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tbvCity.backgroundColor = [UIColor whiteColor];
        _tbvCity.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tbvCity.tag = VMBR_ENUM_City;
        _tbvCity.dataSource = self.dataSource;
        _tbvCity.delegate = self.dataSource;
    }
    return _tbvCity;
}

- (VMBR_chooseProvinceAndCity *)dataSource {
    if (!_dataSource) {
        _dataSource = [[VMBR_chooseProvinceAndCity alloc] init];
    }
    return _dataSource;
}

@end

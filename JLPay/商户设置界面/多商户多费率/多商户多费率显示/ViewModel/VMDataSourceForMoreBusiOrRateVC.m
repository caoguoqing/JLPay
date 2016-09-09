//
//  VMDataSourceForMoreBusiOrRateVC.m
//  JLPay
//
//  Created by jielian on 16/8/25.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMDataSourceForMoreBusiOrRateVC.h"
#import <ReactiveCocoa.h>
#import "Define_Header.h"




@implementation VMDataSourceForMoreBusiOrRateVC

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addKVOs];
    }
    return self;
}


- (void) addKVOs {
    /* 多选才成立 */
    RAC(self, moreBusinessesAndRates) = [RACObserve(self.dataSource, types) map:^id(NSArray* types) {
        return @(types.count > 1);
    }];

    RAC(self, typeSelected) = RACObserve(self.dataSource, typeSelected);
    RAC(self, hasSavedBusiOrRate) = RACObserve(self.dataSource, saved);
    
    RAC(self, rateNameSaved) = RACObserve(self.dataSource, rateNameSaved);
    RAC(self, rateCodeSaved) = RACObserve(self.dataSource, rateCodeSaved);
    RAC(self, businessNameSaved) = RACObserve(self.dataSource, businessNameSaved);
    RAC(self, businessCodeSaved) = RACObserve(self.dataSource, businessCodeSaved);
    RAC(self, terminalCodeSaved) = RACObserve(self.dataSource, terminalCodeSvaed);
    RAC(self, cityCodeSaved) = RACObserve(self.dataSource, cityCodeSaved);
    RAC(self, cityNameSaved) = RACObserve(self.dataSource, cityNameSaved);
    RAC(self, provinceCodeSaved) = RACObserve(self.dataSource, provinceCodeSaved);
    RAC(self, provinceNameSaved) = RACObserve(self.dataSource, provinceNameSaved);

}

# pragma mask 2 UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.types.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"celll"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"celll"];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.separatorInset = UIEdgeInsetsZero;
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    cell.textLabel.text = [self.dataSource.types objectAtIndex:indexPath.row];
    if ([cell.textLabel.text isEqualToString:self.typeSelected]) {
        cell.textLabel.textColor = [UIColor orangeColor];
    } else {
        cell.textLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
    }
    
    return cell;
}
# pragma mask 2 UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.dataSource.typeSelected = [self.dataSource.types objectAtIndex:indexPath.row];
    [tableView reloadData];
}


# pragma mask 4 getter

- (MBusiAndRateInfoReading *)dataSource {
    if (!_dataSource) {
        _dataSource = [[MBusiAndRateInfoReading alloc] init];
    }
    return _dataSource;
}


@end

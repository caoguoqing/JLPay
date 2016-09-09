//
//  VMBR_chooseRate.m
//  JLPay
//
//  Created by jielian on 16/8/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMBR_chooseRate.h"
#import "MBusiAndRateInfoReading.h"
#import "ModelBusinessInfoSaved.h"
#import "ModelRateInfoSaved.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>



@interface VMBR_chooseRate() 

@property (nonatomic, copy) NSArray* allRates;

@end


@implementation VMBR_chooseRate


- (instancetype)init {
    self = [super init];
    if (self) {
        @weakify(self);
        RAC(self, rateCodeSelected) = [RACObserve(self, rateNameSelected) map:^id(NSString* rateType) {
            @strongify(self);
            if ([self.typeSelected isEqualToString:MB_R_Type_moreBusinesses]) {
                return [ModelBusinessInfoSaved rateValueOnRateType:rateType];
            } else {
                return [ModelRateInfoSaved rateValueOnRateType:rateType];
            }
        }];
    }
    return self;
}


# pragma mask 2 UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allRates.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"VMBR_chooseRate_cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VMBR_chooseRate_cell"];
        cell.tintColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
    }
    cell.textLabel.text = [self.allRates objectAtIndex:indexPath.row];
    if ([cell.textLabel.text isEqualToString:self.rateNameSelected]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.textColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    return cell;
}

# pragma mask 2 UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.rateNameSelected = [self.allRates objectAtIndex:indexPath.row];
    [tableView reloadData];
}


# pragma mask 4 getter

- (NSArray *)allRates {
    if (!_allRates) {
        if ([self.typeSelected isEqualToString:MB_R_Type_moreBusinesses]) {
            _allRates = [ModelBusinessInfoSaved allRateTypes];
        }
        else if ([self.typeSelected isEqualToString:MB_R_Type_moreRates]) {
            _allRates = [ModelRateInfoSaved allRateTypes];
        }
        else {
            _allRates = [NSArray array];
        }
    }
    return _allRates;
}



@end

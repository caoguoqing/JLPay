//
//  VMBR_chooseProvinceAndCity.m
//  JLPay
//
//  Created by jielian on 16/8/30.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMBR_chooseProvinceAndCity.h"
#import "BRPC_chooseCell.h"
#import "Define_Header.h"
#import "MBusiAndRateInfoReading.h"
#import "MSqlAreaCode.h"
#import "MHttpAreaCode.h"


@interface VMBR_chooseProvinceAndCity()

@property (nonatomic, strong) NSArray* provinceDatas;

@property (nonatomic, strong) NSArray* cityDatas;

@end


@implementation VMBR_chooseProvinceAndCity


- (NSInteger)rowIndexOfProvinceSelected {
    if (self.provinceNameSelected && self.provinceNameSelected.length > 0) {
        NSInteger index = -1;
        for (int i = 0; i < self.provinceDatas.count; i++) {
            NSDictionary* node = [self.provinceDatas objectAtIndex:i];
            if ([[node objectForKey:@"name"] isEqualToString:self.provinceNameSelected]) {
                index = i;
                break;
            }
        }
        return index;
    } else {
        return -1;
    }
}

- (NSInteger)rowIndexOfCitySelected {
    if (self.cityNameSelected && self.cityNameSelected.length > 0) {
        NSInteger index = -1;
        for (int i = 0; i < self.cityDatas.count; i++) {
            NSDictionary* node = [self.cityDatas objectAtIndex:i];
            if ([[node objectForKey:@"name"] isEqualToString:self.cityNameSelected]) {
                index = i;
                break;
            }
        }
        return index;
    } else {
        return -1;
    }
}



- (void) updateProvincesOnFinished:(void (^) (void))finished {
    if ([self.typeSelected isEqualToString:MB_R_Type_moreBusinesses]) {
        self.provinceDatas = [NSArray arrayWithArray:[MSqlAreaCode allProvinces]];
        finished();
    }
    else if ([self.typeSelected isEqualToString:MB_R_Type_moreRates]) {
        NameWeakSelf(wself);
        [MHttpAreaCode getAllProvincesOnFinished:^(NSArray *allProvinces) {
            wself.provinceDatas = [NSArray arrayWithArray:allProvinces];
            finished();
        } onError:^(NSError *error) {
            
        }];
    }
}


- (void) updateCitiesWithProvinceCode:(NSString*)provinceCode onFinished:(void (^) (void))finished {
    if ([self.typeSelected isEqualToString:MB_R_Type_moreBusinesses]) {
        self.cityDatas = [NSArray arrayWithArray:[MSqlAreaCode allCitiesOnProvinceCode:provinceCode]];
        finished();
    } else {
        NameWeakSelf(wself);
        [MHttpAreaCode getAllCitiesWithProvinceCode:provinceCode onFinished:^(NSArray *allCities) {
            wself.cityDatas = [NSArray arrayWithArray:allCities];
            finished();
        } onError:^(NSError *error) {
            
        }];
    }
}

# pragma mask 2 UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == VMBR_ENUM_Province) {
        return (self.provinceDatas) ? (self.provinceDatas.count) : (0);
    } else {
        return (self.cityDatas) ? (self.cityDatas.count) : (0);
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == VMBR_ENUM_Province) {
        BRPC_chooseCell* cell = [tableView dequeueReusableCellWithIdentifier:@"provinceCell"];
        if (!cell) {
            cell = [[BRPC_chooseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"provinceCell"];
            cell.backgroundColor = [UIColor clearColor];
        }
        cell.textLabel.text = [[self.provinceDatas objectAtIndex:indexPath.row] objectForKey:@"name"];
        if ([cell.textLabel.text isEqualToString:self.provinceNameSelected]) {
            cell.brpc_selected = YES;
            cell.textLabel.textColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
            cell.backgroundColor = [UIColor whiteColor];
        } else {
            cell.brpc_selected = NO;
            cell.textLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.backgroundColor = [UIColor clearColor];
        }
        return cell;
    } else {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cityCell"];
        if (!cell) {
            cell = [[BRPC_chooseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cityCell"];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
        }
        cell.textLabel.text = [[self.cityDatas objectAtIndex:indexPath.row] objectForKey:@"name"];
        if ([cell.textLabel.text isEqualToString:self.cityNameSelected]) {
            cell.textLabel.textColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        } else {
            cell.textLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
        }
        return cell;
    }
}

# pragma mask 2 UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == VMBR_ENUM_Province) {
        NSString* provinceName = [[self.provinceDatas objectAtIndex:indexPath.row] objectForKey:@"name"];
        if (![provinceName isEqualToString:self.provinceNameSelected]) {
            self.provinceNameSelected = provinceName;
            self.provinceCodeSelected = [[self.provinceDatas objectAtIndex:indexPath.row] objectForKey:@"code"];
            self.cityCodeSelected = nil;
            self.cityNameSelected = nil;
        }
    } else {
        self.cityNameSelected = [[self.cityDatas objectAtIndex:indexPath.row] objectForKey:@"name"];
        self.cityCodeSelected = [[self.cityDatas objectAtIndex:indexPath.row] objectForKey:@"code"];
    }
    [tableView reloadData];
}

@end

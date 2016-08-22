//
//  VMProvinceAndCityChoose.m
//  JLPay
//
//  Created by jielian on 16/7/7.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMProvinceAndCityChoose.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>

@implementation VMProvinceAndCityChoose

- (void)resetCityDatasOnFinished:(void (^)(void))finished {
    if (self.provinceIndexPicked >= 0) {
        NSString* provinceCode = [[self.provinceListRequested objectAtIndex:self.provinceIndexPicked] objectForKey:kFieldNameKey];
        self.cityListRequested = [ModelAreaCodeSelector allCitiesSelectedAtProvinceCode:provinceCode];
    } else {
        self.cityListRequested = [NSArray array];
    }
    if (finished) finished();
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.provinceIndexPicked = -1;
        self.cityIndexPicked = -1;
        [self addKVOs];
    }
    return self;
}

- (void) addKVOs {
    @weakify(self);
    
    RAC(self, provinceNamePicked) = [RACObserve(self, provinceIndexPicked) map:^NSString* (NSNumber* selected) {
        @strongify(self);
        NSInteger index = selected.integerValue;
        if (index < 0) {
            return nil;
        } else {
            return [[[self.provinceListRequested objectAtIndex:index] objectForKey:kFieldNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
    }];
    
    RAC(self, provinceCodePicked) = [RACObserve(self, provinceIndexPicked) map:^NSString* (NSNumber* selected) {
        @strongify(self);
        NSInteger index = selected.integerValue;
        if (index < 0) {
            return nil;
        } else {
            return [[self.provinceListRequested objectAtIndex:index] objectForKey:kFieldNameKey];
        }
    }];
    
    RAC(self, cityNamePicked) = [RACObserve(self, cityIndexPicked) map:^NSString* (NSNumber* selected) {
        @strongify(self);
        NSInteger index = selected.integerValue;
        if (index < 0) {
            return nil;
        } else {
            return [[[self.cityListRequested objectAtIndex:index] objectForKey:kFieldNameValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
    }];
    
    RAC(self, cityCodePicked) = [RACObserve(self, cityIndexPicked) map:^NSString* (NSNumber* selected) {
        @strongify(self);
        NSInteger index = selected.integerValue;
        if (index < 0) {
            return nil;
        } else {
            return [[self.cityListRequested objectAtIndex:index] objectForKey:kFieldNameKey];
        }
    }];

}

# pragma maks 2 UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == VMSU_areaTypeProvince) {
        return self.provinceListRequested.count;
    } else {
        return self.cityListRequested.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = [self cellIdentifierWithTag:tableView.tag];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.tintColor = [UIColor whiteColor];
    }
    return cell;
}

# pragma maks 2 UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL cellIsSelected = (tableView.tag == VMSU_areaTypeProvince)?(self.provinceIndexPicked == indexPath.row):(self.cityIndexPicked == indexPath.row);
    NSArray* textArray = (tableView.tag == VMSU_areaTypeProvince)?(self.provinceListRequested):(self.cityListRequested);
    
    UIColor* normalTextColor = (tableView.tag == VMSU_areaTypeProvince)?([UIColor colorWithHex:HexColorTypeBlackBlue alpha:1]):([UIColor whiteColor]);
    UIColor* selectedTextColor = [UIColor whiteColor];
    UIColor* normalCellBackColor = (tableView.tag == VMSU_areaTypeProvince)?([UIColor clearColor]):([UIColor colorWithHex:HexColorTypeBlackBlue alpha:0.4]);
    UIColor* selectedCellBackColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:0.5];
    UIView* selectedBackView = [[UIView alloc] initWithFrame:cell.bounds];
    selectedBackView.backgroundColor = (cellIsSelected)?(selectedCellBackColor):(normalCellBackColor);
    
    cell.textLabel.font = [UIFont systemFontOfSize:[NSString resizeFontAtHeight:cell.frame.size.height scale:0.36]];
    cell.textLabel.textColor = (cellIsSelected)?(selectedTextColor):(normalTextColor);
    cell.accessoryType = (cellIsSelected)?(UITableViewCellAccessoryCheckmark):(UITableViewCellAccessoryNone);
    cell.backgroundView = selectedBackView;
    
    cell.textLabel.text = [[textArray objectAtIndex:indexPath.row] objectForKey:kFieldNameValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == VMSU_areaTypeProvince) {
        if (indexPath.row != self.provinceIndexPicked) self.cityIndexPicked = -1;
        self.provinceIndexPicked = indexPath.row;
    } else {
        self.cityIndexPicked = indexPath.row;
    }
}


- (NSString*) cellIdentifierWithTag:(NSInteger)tag {
    return (tag == VMSU_areaTypeProvince)?(@"provinceId"):(@"cityId");
}

# pragma mask 4 getter

- (NSArray *)provinceListRequested {
    if (!_provinceListRequested) {
        _provinceListRequested = [ModelAreaCodeSelector allProvincesSelected];
    }
    return _provinceListRequested;
}


@end

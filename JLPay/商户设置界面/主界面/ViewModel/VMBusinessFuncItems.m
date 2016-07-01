//
//  VMBusinessFuncItems.m
//  JLPay
//
//  Created by jielian on 16/6/20.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMBusinessFuncItems.h"
#import "Define_Header.h"
#import "MLoginSavedResource.h"
#import "BusinessInfoTableViewCell.h"
#import "NormalTableViewCell.h"
#import "MLoginSavedResource.h"

@implementation VMBusinessFuncItems


# pragma mask 1  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.funcItemTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* identifier = [self identifierForCellIndexPath:indexPath];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        if ([[self.funcItemTitles objectAtIndex:indexPath.row] isEqualToString:FuncItemTitleBusinessInfo]) {
            cell = [[BusinessInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        } else {
            cell = [[NormalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
    }
    
    /* 商户信息cell */
    if ([[self.funcItemTitles objectAtIndex:indexPath.row] isEqualToString:FuncItemTitleBusinessInfo]) {
        BusinessInfoTableViewCell* businessInfoCell = (BusinessInfoTableViewCell*)cell;
        businessInfoCell.labelUserId.text = [PublicInformation returnUserName];
        businessInfoCell.labelBusinessName.text = [PublicInformation returnBusinessName];
        businessInfoCell.labelBusinessNo.text = [PublicInformation returnBusiness];
        
        if ([MLoginSavedResource sharedLoginResource].checkedState == BusinessCheckedStateChecked) {
            businessInfoCell.labelCheckedState.hidden = YES;
        }
        else if ([MLoginSavedResource sharedLoginResource].checkedState == BusinessCheckedStateChecking) {
            businessInfoCell.labelCheckedState.hidden = NO;
            businessInfoCell.labelCheckedState.text = @"审核中";
        }
        else if ([MLoginSavedResource sharedLoginResource].checkedState == BusinessCheckedStateCheckRefused) {
            businessInfoCell.labelCheckedState.hidden = NO;
            businessInfoCell.labelCheckedState.text = @"审核拒绝";
        }
    }
    /* 商户信息cell */
    else {
        NormalTableViewCell* titleCell = (NormalTableViewCell*)cell;
        
        NSString* title = [self.funcItemTitles objectAtIndex:indexPath.row];
        if ([title isEqualToString:FuncItemTitleCodeScanning] ||
            [title isEqualToString:FuncItemTitleOrderDispatch] )
        {
            titleCell.iconLabel.text = [NSString fontAwesomeIconStringForEnum:[[self.iconsForTitles objectForKey:title] integerValue]];
            titleCell.iconLabel.font = [UIFont fontAwesomeFontOfSize:[@"ss" resizeFontAtHeight:54 scale:0.45]];
        } else {
            titleCell.iconLabel.text = [NSString stringWithIconFontType:[[self.iconsForTitles objectForKey:title] integerValue]];
            titleCell.iconLabel.font = [UIFont iconFontWithSize:[@"ss" resizeFontAtHeight:54 scale:0.45]];
        }
        titleCell.iconLabel.textColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
        
        titleCell.titleLabel.text = [self.funcItemTitles objectAtIndex:indexPath.row];
        titleCell.titleLabel.font = [UIFont systemFontOfSize:[@"ss" resizeFontAtHeight:54 scale:0.32]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}


# pragma mask 3 private funcs 

- (NSString*) identifierForCellIndexPath:(NSIndexPath*)indexPath {
    if ([[self.funcItemTitles objectAtIndex:indexPath.row] isEqualToString:FuncItemTitleBusinessInfo]) {
        return @"businessBasicInfoCell";
    } else {
        return @"normalTitleCell";
    }
}



# pragma mask 4 getter

- (NSMutableArray *)funcItemTitles {
    if (!_funcItemTitles) {
        _funcItemTitles = [NSMutableArray array];
        [_funcItemTitles addObject:FuncItemTitleTransList];
        [_funcItemTitles addObject:FuncItemTitleDeviceBinding];
//        [_funcItemTitles addObject:FuncItemTitleOrderDispatch];  /* 先屏蔽掉调单功能 */
        [_funcItemTitles addObject:FuncItemTitleCodeScanning];

        if ([MLoginSavedResource sharedLoginResource].N_business_enable || [MLoginSavedResource sharedLoginResource].N_fee_enable) {
            [_funcItemTitles addObject:FuncItemTitleRateSelecting];
        }
        if ([MLoginSavedResource sharedLoginResource].T_0_enable) {
            [_funcItemTitles addObject:FuncItemTitleCardChecking];
        }
        
        [_funcItemTitles addObject:FuncItemTitlePinModifying];
        [_funcItemTitles addObject:FuncItemTitleHelpAndUs];

    }
    return _funcItemTitles;
}

- (NSMutableDictionary *)iconsForTitles {
    if (!_iconsForTitles) {
        _iconsForTitles = [NSMutableDictionary dictionary];
        [_iconsForTitles setObject:@(IconFontType_billCheck) forKey:FuncItemTitleTransList];
        [_iconsForTitles setObject:@(IconFontType_bluetoothSearching) forKey:FuncItemTitleDeviceBinding];
        [_iconsForTitles setObject:@(FAdatabase) forKey:FuncItemTitleOrderDispatch];
        [_iconsForTitles setObject:@(FAQrcode) forKey:FuncItemTitleCodeScanning];
        [_iconsForTitles setObject:@(IconFontType_calculator) forKey:FuncItemTitleRateSelecting];
        [_iconsForTitles setObject:@(IconFontType_creditcard) forKey:FuncItemTitleCardChecking];
        [_iconsForTitles setObject:@(IconFontType_unlock) forKey:FuncItemTitlePinModifying];
        [_iconsForTitles setObject:@(IconFontType_setting_fill) forKey:FuncItemTitleHelpAndUs];

    }
    return _iconsForTitles;
}

- (NSMutableDictionary *)viewControllersForTitles {
    if (!_viewControllersForTitles) {
        _viewControllersForTitles = [NSMutableDictionary dictionary];
        [_viewControllersForTitles setObject:@"MyBusinessViewController" forKey:FuncItemTitleBusinessInfo];
        [_viewControllersForTitles setObject:@"TransDetailListViewController" forKey:FuncItemTitleTransList];
//        [_viewControllersForTitles setObject:@"DeviceSignInViewController" forKey:FuncItemTitleDeviceBinding];
        [_viewControllersForTitles setObject:@"DeviceBindingViewController" forKey:FuncItemTitleDeviceBinding];
        [_viewControllersForTitles setObject:@"RateChooseViewController" forKey:FuncItemTitleRateSelecting];
        [_viewControllersForTitles setObject:@"T_0CardListViewController" forKey:FuncItemTitleCardChecking];
        [_viewControllersForTitles setObject:@"ChangePinViewController" forKey:FuncItemTitlePinModifying];
        [_viewControllersForTitles setObject:@"HelperAndAboutTableViewController" forKey:FuncItemTitleHelpAndUs];
        [_viewControllersForTitles setObject:@"AccountReceivedViewController" forKey:FuncItemTitleOrderDispatch];
    }
    return _viewControllersForTitles;
}

@end

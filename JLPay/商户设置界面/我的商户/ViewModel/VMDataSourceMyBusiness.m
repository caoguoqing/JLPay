//
//  VMDataSourceMyBusiness.m
//  JLPay
//
//  Created by jielian on 16/5/5.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMDataSourceMyBusiness.h"





@implementation VMDataSourceMyBusiness

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}
- (void)dealloc {
    JLPrint(@"-----------------  VMDataSourceMyBusiness  dealloc  ------------------");
    [self stopRequest];
}

- (void)requestMyBusinessInfoOnFinished:(void (^)(void))finished onErrorBlock:(void (^)(NSError *))errorBlock {
    NameWeakSelf(wself);
    [self updateTitlesNeedDisplayedOnFilled:NO];
    [[MHttpBusinessInfo sharedVM] requestBusinessInfoOnFinished:^{
        NSInteger businessState = [[wself valueForTitleName:VMMyBusinessTitleState] integerValue];
        if (businessState == 8 || businessState == 2) { // ‘拒绝状态’
            self.businessState = VMDataSourceMyBusiCodeCheckRefuse;
        }
        else if (businessState == 1) {
            self.businessState = VMDataSourceMyBusiCodeChecking;
        }
        else {
            self.businessState = VMDataSourceMyBusiCodeChecked;
        }
        [wself updateTitlesNeedDisplayedOnFilled:YES];
        if (finished) finished();
    } onErrorBlock:^(NSError *error) {
        if (errorBlock) errorBlock(error);
    }];
}

- (void) stopRequest {
    [[MHttpBusinessInfo sharedVM] stopRequest];
}

# pragma mask 2 UITableViewDataSource
/*
 * 给'我的商户'提供数据源:表格数据
 * 给'商户信息修改'提供数据源:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.displayTitles.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* titlesAtSection = [self.displayTitles objectAtIndex:section];
    return titlesAtSection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray* cellTitles = [self.displayTitles objectAtIndex:indexPath.section];
    NSString* valueKey = [cellTitles objectAtIndex:indexPath.row];
    NSString* valueForTitle = [self valueForTitleName:valueKey];
    
    if (indexPath.section == 0) {
        NSString* cellIdentifier = @"userHeadTBVCellId";
        UserHeadImageTBVCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UserHeadImageTBVCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
        }
        cell.headImageView.image = [UIImage imageNamed:@"01_01"];
        cell.titleLabel.text = valueForTitle;
        return cell;
    }
    else if (indexPath.section == 1 && indexPath.row == 0 && [valueKey isEqualToString:VMMyBusinessTitleState]) { // 状态
        NSString* cellIdentifier = @"businessStateTBVCellId";
        BusinessStateTBVCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[BusinessStateTBVCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
        }
        cell.textLabel.text = valueKey;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];

        if (valueForTitle.integerValue == 1) {
            cell.stateLabel.text = @"审核中";
        }
        else if (valueForTitle.integerValue == 8 || valueForTitle.integerValue == 2) {
            cell.stateLabel.text = @"审核不通过";
        }
        else {
            cell.stateLabel.text = @"正常";
        }
        return cell;
    }
    else {
        NSString* cellIdentifier = @"normalTBVCellId";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
        }
        if ([valueKey isEqualToString:VMMyBusinessTitleIdNo]) {
            valueForTitle = [valueForTitle stringCutting4XingInRange:NSMakeRange(4, valueForTitle.length - 4 - 4)];
        }
        else if ([valueKey isEqualToString:VMMyBusinessTitleTelNo]) {
            valueForTitle = [valueForTitle stringCutting4XingInRange:NSMakeRange(3, valueForTitle.length - 3 - 4)];
        }
        else if ([valueKey isEqualToString:VMMyBusinessTitleSettleAccount]) {
            valueForTitle = [valueForTitle stringCuttingXingInRange:NSMakeRange(4, valueForTitle.length - 4 - 4)];
        }
        else if ([valueKey isEqualToString:VMMyBusinessTitleAddress]) {
            /* 查询地区: DB */
            NSDictionary* city = [ModelAreaCodeSelector citySelectedAtCityCode:valueForTitle];
            NSDictionary* province = [ModelAreaCodeSelector provinceSelectedAtProvinceCode:[city objectForKey:kFieldNameDescr]];
            valueForTitle = [NSString stringWithFormat:@"%@-%@",
                             [PublicInformation clearSpaceCharAtLastOfString:province[kFieldNameValue]],
                             [PublicInformation clearSpaceCharAtLastOfString:city[kFieldNameValue]]];
        }
        cell.textLabel.text = valueKey;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.text = valueForTitle;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.numberOfLines = 0;
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        if ([self valueForTitleName:VMMyBusinessTitleState].integerValue == 2) {
            return [[MLoginSavedResource sharedLoginResource] checkedRefuseReason];
        } else {
            return @"";
        }
    } else {
        return @"";
    }
}

- (NSString*) valueForTitleName:(NSString*)titleName {
    NSString* key = [self.titleAndDataKeys objectForKey:titleName];
    return [[MHttpBusinessInfo sharedVM].businessInfo objectForKey:key];
}



# pragma mask 3 private interface
- (void) updateTitlesNeedDisplayedOnFilled:(BOOL)filled {
    if (filled) {
        [self.displayTitles addObject:@[VMMyBusinessTitleUser]];
        
        switch (self.businessState) {
            case VMDataSourceMyBusiCodeChecked:
            {
                [self.displayTitles addObject:@[VMMyBusinessTitleState,VMMyBusinessTitleNumber]];
            }
                break;
            case VMDataSourceMyBusiCodeChecking:
            {
                [self.displayTitles addObject:@[VMMyBusinessTitleState]];

            }
                break;
            case VMDataSourceMyBusiCodeCheckRefuse:
            {
                [self.displayTitles addObject:@[VMMyBusinessTitleState]];

            }
                break;

            default:
                break;
        }
        
        [self.displayTitles addObject:@[VMMyBusinessTitleSettleAccount,VMMyBusinessTitleBankName]];
        [self.displayTitles addObject:@[VMMyBusinessTitleAddress,VMMyBusinessTitleTelNo]];
    } else {
        [self.displayTitles removeAllObjects];
    }
}


# pragma mask 4 getter

- (NSMutableArray *)displayTitles {
    if (!_displayTitles) {
        _displayTitles = [NSMutableArray array];
    }
    return _displayTitles;
}
- (NSMutableDictionary *)titleAndDataKeys {
    if (!_titleAndDataKeys) {
        _titleAndDataKeys = [NSMutableDictionary dictionary];
        [_titleAndDataKeys setObject:MHttpBusinessKeyMchntNm forKey:VMMyBusinessTitleUser];
        [_titleAndDataKeys setObject:MHttpBusinessKeyMchntNm forKey:VMMyBusinessTitleName];
        [_titleAndDataKeys setObject:MHttpBusinessKeyTelNo forKey:VMMyBusinessTitleTelNo];
        [_titleAndDataKeys setObject:MHttpBusinessKeySpeSettleDs forKey:VMMyBusinessTitleBankName];
        [_titleAndDataKeys setObject:MHttpBusinessKeySettleAcct forKey:VMMyBusinessTitleSettleAccount];
        [_titleAndDataKeys setObject:MHttpBusinessKeyAreaNo forKey:VMMyBusinessTitleAddress];
        [_titleAndDataKeys setObject:MHttpBusinessKeyIdentifyNo forKey:VMMyBusinessTitleIdNo];
        [_titleAndDataKeys setObject:MHttpBusinessKeyMchtStatus forKey:VMMyBusinessTitleState];
        [_titleAndDataKeys setObject:MHttpBusinessKeyMchtNo forKey:VMMyBusinessTitleNumber];

    }
    return _titleAndDataKeys;
}


@end

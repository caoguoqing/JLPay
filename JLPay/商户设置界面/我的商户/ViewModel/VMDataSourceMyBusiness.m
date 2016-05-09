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
    [[MHttpBusinessInfo sharedVM] requestBusinessInfoOnFinished:^{
        NSString* businessState = [wself valueForTitleName:VMMyBusinessTitleState];
        if (businessState.integerValue == 8 || businessState.integerValue == 2) { // ‘拒绝状态’，退出登录
            if (errorBlock) errorBlock([NSError errorWithDomain:@"" code:VMDataSourceMyBusiCodeCheckRefuse localizedDescription:@"商户审核拒绝"]);
        }
        else {
            if (businessState.integerValue != 1) { // '正常状态',要去掉标题 VMMyBusinessTitleState
                NSArray* section1Array = [wself.displayTitles objectAtIndex:1];
                if (section1Array.count == 1 && [section1Array[0] isEqualToString:VMMyBusinessTitleState]) {
                    [wself.displayTitles removeObjectAtIndex:1];
                }
            }
            if (finished) finished();
        }
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
        }
        cell.textLabel.text = valueKey;
        cell.detailTextLabel.text = @"修改";
        if (valueForTitle.integerValue == 1) {
            cell.stateLabel.text = @"审核中";
        }
        else if (valueForTitle.integerValue == 8 || valueForTitle.integerValue == 2) {
            cell.stateLabel.text = @"审核拒绝";
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else {
        NSString* cellIdentifier = @"normalTBVCellId";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        if ([valueKey isEqualToString:VMMyBusinessTitleIdNo]) {
            valueForTitle = [valueForTitle stringCuttingXingInRange:NSMakeRange(4, valueForTitle.length - 4 - 4)];
        }
        else if ([valueKey isEqualToString:VMMyBusinessTitleTelNo]) {
            valueForTitle = [valueForTitle stringCuttingXingInRange:NSMakeRange(3, valueForTitle.length - 3 - 4)];
        }
        else if ([valueKey isEqualToString:VMMyBusinessTitleSettleAccount]) {
            valueForTitle = [valueForTitle stringCuttingXingInRange:NSMakeRange(4, valueForTitle.length - 4 - 4)];
        }
        cell.textLabel.text = valueKey;
        cell.detailTextLabel.text = valueForTitle;
        return cell;
    }
}

- (NSString*) valueForTitleName:(NSString*)titleName {
    NSString* key = [self.titleAndDataKeys objectForKey:titleName];
    return [[MHttpBusinessInfo sharedVM].businessInfo objectForKey:key];
}



# pragma mask 4 getter

- (NSMutableArray *)displayTitles {
    if (!_displayTitles) {
        _displayTitles = [NSMutableArray array];
        [_displayTitles addObject:@[VMMyBusinessTitleUser]];
        [_displayTitles addObject:@[VMMyBusinessTitleState]];
        [_displayTitles addObject:@[VMMyBusinessTitleName,VMMyBusinessTitleNumber,VMMyBusinessTitleIdNo,VMMyBusinessTitleTelNo,VMMyBusinessTitleEmail]];
        [_displayTitles addObject:@[VMMyBusinessTitleBankName,VMMyBusinessTitleSettleAccount]];
        [_displayTitles addObject:@[VMMyBusinessTitleAddress]];
    }
    return _displayTitles;
}
- (NSMutableDictionary *)titleAndDataKeys {
    if (!_titleAndDataKeys) {
        _titleAndDataKeys = [NSMutableDictionary dictionary];
        [_titleAndDataKeys setObject:MHttpBusinessKeyUserName forKey:VMMyBusinessTitleUser];
        [_titleAndDataKeys setObject:MHttpBusinessKeyMchntNm forKey:VMMyBusinessTitleName];
        [_titleAndDataKeys setObject:MHttpBusinessKeyTelNo forKey:VMMyBusinessTitleTelNo];
        [_titleAndDataKeys setObject:MHttpBusinessKeyMail forKey:VMMyBusinessTitleEmail];
        [_titleAndDataKeys setObject:MHttpBusinessKeySpeSettleDs forKey:VMMyBusinessTitleBankName];
        [_titleAndDataKeys setObject:MHttpBusinessKeySettleAcct forKey:VMMyBusinessTitleSettleAccount];
        [_titleAndDataKeys setObject:MHttpBusinessKeyAddr forKey:VMMyBusinessTitleAddress];
        [_titleAndDataKeys setObject:MHttpBusinessKeyIdentifyNo forKey:VMMyBusinessTitleIdNo];
        [_titleAndDataKeys setObject:MHttpBusinessKeyMchtStatus forKey:VMMyBusinessTitleState];
        [_titleAndDataKeys setObject:MHttpBusinessKeyMchtNo forKey:VMMyBusinessTitleNumber];

    }
    return _titleAndDataKeys;
}


@end

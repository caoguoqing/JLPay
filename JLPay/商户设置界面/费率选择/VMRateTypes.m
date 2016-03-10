//
//  VMRateTypes.m
//  JLPay
//
//  Created by jielian on 16/3/10.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMRateTypes.h"
#import <UIKit/UIKit.h>
#import "ModelRateInfoSaved.h"

@interface VMRateTypes()
<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, copy) NSArray* rateTypes;
@end

@implementation VMRateTypes


#pragma mask 1 UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rateTypes.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellIdentifier = @"cellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.textLabel.text = [self.rateTypes objectAtIndex:indexPath.row];
    if ([cell.textLabel.text isEqualToString:self.rateTypeSelected]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
#pragma mask 1 UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.rateTypeSelected = [self.rateTypes objectAtIndex:indexPath.row];
    self.rateValueSelected = [ModelRateInfoSaved rateValueOnRateType:self.rateTypeSelected];
    [tableView reloadData];
}

#pragma mask 5 getter
- (NSArray *)rateTypes {
    if (!_rateTypes) {
        _rateTypes = [[ModelRateInfoSaved allRateTypes] copy];
    }
    return _rateTypes;
}
@end

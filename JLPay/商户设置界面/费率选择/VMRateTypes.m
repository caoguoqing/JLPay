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
#import "ModelBusinessInfoSaved.h"

@interface VMRateTypes()
<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, copy) NSArray* rateTypes;
@property (nonatomic, assign) VMRateType rateType;

@end

@implementation VMRateTypes

- (instancetype) initWithRateType:(VMRateType)rateType {
    self = [super init];
    if (self) {
        self.rateType = rateType;
    }
    return self;
}

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
        CGRect frame = [tableView rectForRowAtIndexPath:indexPath];
        frame.origin.x = frame.origin.y = 0;
        UIView* backView = [[UIView alloc] initWithFrame:frame];
        backView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.35];
        cell.selectedBackgroundView = backView;
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
    if (self.rateType == VMRateTypeRate) {
        self.rateValueSelected = [ModelRateInfoSaved rateValueOnRateType:self.rateTypeSelected];
    }
    else if (self.rateType == VMRateTypeBusinessRate) {
        self.rateValueSelected = [ModelBusinessInfoSaved rateValueOnRateType:self.rateTypeSelected];
    }
    [tableView reloadData];
}

#pragma mask 5 getter
- (NSArray *)rateTypes {
    if (!_rateTypes) {
        if (self.rateType == VMRateTypeRate) {
            _rateTypes = [[ModelRateInfoSaved allRateTypes] copy];
        }
        else if (self.rateType == VMRateTypeBusinessRate) {
            _rateTypes = [[ModelBusinessInfoSaved allRateTypes] copy];
        }
    }
    return _rateTypes;
}
@end

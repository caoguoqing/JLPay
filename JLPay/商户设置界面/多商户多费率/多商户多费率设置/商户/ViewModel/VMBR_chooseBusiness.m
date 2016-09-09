//
//  VMBR_chooseBusiness.m
//  JLPay
//
//  Created by jielian on 16/8/30.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMBR_chooseBusiness.h"
#import "MBR_HTTP_getBusiness.h"
#import "Define_Header.h"



@interface VMBR_chooseBusiness()


/* NSDictionary<mchtNo|mchtNm|termNo> */
@property (nonatomic, strong) NSArray* businessList;

@end

@implementation VMBR_chooseBusiness

- (NSInteger)rowBusinessIndexSelected {
    NSInteger index = -1;
    if (self.businessName && self.businessName.length > 0) {
        for (int i = 0; i < self.businessList.count; i++) {
            NSDictionary* node = [self.businessList objectAtIndex:i];
            if ([self.businessName isEqualToString:[node objectForKey:@"mchtNm"]]) {
                index = i;
                break;
            }
        }
    }
    return index;
}


- (void)getBusinessListOnFinished:(void (^)(void))finishedBlock onError:(void (^)(NSError *))errorBlock {
    NameWeakSelf(wslef);
    self.businessList = nil;
    [MBR_HTTP_getBusiness getBusinessListWithRateType:self.rateType andCityCode:self.cityCode onFinished:^(NSArray *businessList) {
        wslef.businessList = [NSArray arrayWithArray:businessList];
        if (finishedBlock) finishedBlock();
    } onError:^(NSError *error) {
        wslef.businessName = nil;
        wslef.businessCode = nil;
        if (errorBlock) errorBlock(error);
    }];

}

# pragma mask 2 UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.businessList) ? (self.businessList.count) : (0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"VMBR_chooseBusiness_cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VMBR_chooseBusiness_cell"];
        cell.tintColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
    }
    cell.textLabel.text = [[self.businessList objectAtIndex:indexPath.row] objectForKey:@"mchtNm"];
    if ([cell.textLabel.text isEqualToString:self.businessName]) {
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
    NSDictionary* node = [self.businessList objectAtIndex:indexPath.row];
    self.businessName = [node objectForKey:@"mchtNm"];
    self.businessCode = [node objectForKey:@"mchtNo"];
    self.terminalCode = [node objectForKey:@"termNo"];
    [tableView reloadData];
}

@end

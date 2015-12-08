//
//  SettlementInfoViewController.h
//  JLPay
//
//  Created by jielian on 15/12/7.
//  Copyright © 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettlementInfoViewController : UITableViewController

@property (nonatomic, strong) NSDictionary* settlementInformation;      // 结算信息


//@property (nonatomic, strong) NSString* stringOfTranType;               // 交易类型:消费、撤销、退货
//@property (nonatomic, strong) NSString* sIntMoney;                      // 无小数点格式金额
@property (nonatomic, strong) NSString* sFloatMoney;                    // 有小数点格式金额


@end

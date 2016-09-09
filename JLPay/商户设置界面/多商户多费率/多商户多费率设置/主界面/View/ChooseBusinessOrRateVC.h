//
//  ChooseBusinessOrRateVC.h
//  JLPay
//
//  Created by jielian on 16/8/29.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMMoreBusinessOrRateSaving.h"


@interface ChooseBusinessOrRateVC : UIViewController

@property (nonatomic, strong) VMMoreBusinessOrRateSaving* vmBRsaver;

@property (nonatomic, copy) void (^ doneWithSaved) (void);

@end
